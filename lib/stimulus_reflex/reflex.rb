# frozen_string_literal: true

ClientAttributes = Struct.new(:reflex_id, :reflex_controller, :xpath_controller, :xpath_element, :permanent_attribute_name, keyword_init: true)

class StimulusReflex::Reflex
  include ActiveSupport::Rescuable
  include ActiveSupport::Callbacks

  define_callbacks :process, skip_after_callbacks_if_terminated: true

  class << self
    def before_reflex(*args, &block)
      add_callback(:before, *args, &block)
    end

    def after_reflex(*args, &block)
      add_callback(:after, *args, &block)
    end

    def around_reflex(*args, &block)
      add_callback(:around, *args, &block)
    end

    private

    def add_callback(kind, *args, &block)
      options = args.extract_options!
      options.assert_valid_keys :if, :unless, :only, :except
      set_callback(*[:process, kind, args, normalize_callback_options!(options)].flatten, &block)
    end

    def normalize_callback_options!(options)
      normalize_callback_option! options, :only, :if
      normalize_callback_option! options, :except, :unless
      options
    end

    def normalize_callback_option!(options, from, to)
      if (from = options.delete(from))
        from_set = Array(from).map(&:to_s).to_set
        from = proc { |reflex| from_set.include? reflex.method_name }
        options[to] = Array(options[to]).unshift(from)
      end
    end
  end

  attr_reader :cable_ready, :channel, :url, :element, :selectors, :method_name, :broadcaster, :client_attributes, :logger

  alias_method :action_name, :method_name # for compatibility with controller libraries like Pundit that expect an action name

  delegate :connection, :stream_name, to: :channel
  delegate :controller_class, :flash, :session, to: :request
  delegate :broadcast, :broadcast_message, to: :broadcaster
  delegate :reflex_id, :reflex_controller, :xpath_controller, :xpath_element, :permanent_attribute_name, to: :client_attributes
  delegate :render, to: :controller_class

  def initialize(channel, url: nil, element: nil, selectors: [], method_name: nil, params: {}, client_attributes: {})
    @channel = channel
    @url = url
    @element = element
    @selectors = selectors
    @method_name = method_name
    @params = params
    @broadcaster = StimulusReflex::PageBroadcaster.new(self)
    @logger = StimulusReflex::Logger.new(self)
    @client_attributes = ClientAttributes.new(client_attributes)
    @cable_ready = StimulusReflex::CableReadyChannels.new(stream_name)
    self.params
  end

  def request
    @request ||= begin
      uri = URI.parse(url)
      path = ActionDispatch::Journey::Router::Utils.normalize_path(uri.path)
      query_hash = Rack::Utils.parse_nested_query(uri.query)
      mock_env = Rack::MockRequest.env_for(uri.to_s)

      mock_env.merge!(
        "rack.request.query_hash" => query_hash,
        "rack.request.query_string" => uri.query,
        "ORIGINAL_SCRIPT_NAME" => "",
        "ORIGINAL_FULLPATH" => path,
        Rack::SCRIPT_NAME => "",
        Rack::PATH_INFO => path,
        Rack::REQUEST_PATH => path,
        Rack::QUERY_STRING => uri.query
      )

      env = connection.env.merge(mock_env)

      middleware = StimulusReflex.config.middleware

      if middleware.any?
        stack = middleware.build(Rails.application.routes)
        stack.call(env)
      end

      req = ActionDispatch::Request.new(env)

      path_params = Rails.application.routes.recognize_path_with_request(req, url, req.env[:extras] || {})
      path_params[:controller] = path_params[:controller].force_encoding("UTF-8")
      path_params[:action] = path_params[:action].force_encoding("UTF-8")

      req.env.merge(ActionDispatch::Http::Parameters::PARAMETERS_KEY => path_params)
      req.env["action_dispatch.request.parameters"] = req.parameters.merge(@params)

      puts "@params #{@params.inspect}"
      puts "path_params #{path_params.inspect}"
      puts "req.parameters #{req.parameters.inspect}"
      Rails.logger.debug("@params #{@params.inspect}")
      Rails.logger.debug("path_params #{path_params.inspect}")
      Rails.logger.debug("req.parameters #{req.parameters.inspect}")

      req.tap { |r| r.session.send :load! }
    end
  end

  def morph(selectors, html = "")
    case selectors
    when :page
      raise StandardError.new("Cannot call :page morph after :#{broadcaster.to_sym} morph") unless broadcaster.page?
    when :nothing
      raise StandardError.new("Cannot call :nothing morph after :selector morph") if broadcaster.selector?
      @broadcaster = StimulusReflex::NothingBroadcaster.new(self) unless broadcaster.nothing?
    else
      raise StandardError.new("Cannot call :selector morph after :nothing morph") if broadcaster.nothing?
      @broadcaster = StimulusReflex::SelectorBroadcaster.new(self) unless broadcaster.selector?
      broadcaster.append_morph(selectors, html)
    end
  end

  def controller
    @controller ||= begin
      controller_class.new.tap do |c|
        c.instance_variable_set :"@stimulus_reflex", true
        instance_variables.each { |name| c.instance_variable_set name, instance_variable_get(name) }
        c.set_request! request
        c.set_response! controller_class.make_response!(request)
      end
    end
  end

  def process(name, *args)
    reflex_invoked = false
    result = run_callbacks(:process) {
      public_send(name, *args).tap { reflex_invoked = true }
    }
    @halted ||= result == false && !reflex_invoked
    result
  end

  # Indicates if the callback chain was halted via a throw(:abort) in a before_reflex callback.
  # SEE: https://api.rubyonrails.org/classes/ActiveSupport/Callbacks.html
  # IMPORTANT: The reflex will not re-render the page if the callback chain is halted
  def halted?
    !!@halted
  end

  def default_reflex
    # noop default reflex to force page reloads
  end

  def params
    @_params ||= ActionController::Parameters.new(request.parameters)
  end

  def dom_id(record_or_class, prefix = nil)
    "#" + ActionView::RecordIdentifier.dom_id(record_or_class, prefix).to_s
  end
end

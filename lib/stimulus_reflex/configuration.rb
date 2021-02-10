# frozen_string_literal: true

module StimulusReflex
  class Configuration
    attr_accessor :on_failed_sanity_checks, :parent_channel, :logging, :middleware

    DEFAULT_LOGGING = proc { "[#{session_id}] #{operation_counter.magenta} #{reflex_info.green} -> #{selector.cyan} via #{mode} Morph (#{operation.yellow})" }

    def initialize
      @on_failed_sanity_checks = :exit
      @parent_channel = "ApplicationCable::Channel"
      @logging = DEFAULT_LOGGING
      @middleware = ActionDispatch::MiddlewareStack.new
    end
  end
end

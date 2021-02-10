# frozen_string_literal: true

require "action_cable"
require "action_view"
require "action_dispatch"
require "nokogiri"
require "cable_ready"
require "zeitwerk"

module StimulusReflex
  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end

    alias_method :config, :configuration
  end
end

loader = Zeitwerk::Loader.for_gem
loader.collapse("#{__dir__}/stimulus_reflex/broadcasters")
loader.collapse("#{__dir__}/generators")
loader.setup
loader.eager_load

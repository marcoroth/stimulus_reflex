# frozen_string_literal: true

require "action_cable"
require "nokogiri"
require "cable_ready"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.collapse("#{__dir__}/stimulus_reflex/broadcasters")
loader.collapse("#{__dir__}/generators")
loader.setup
loader.eager_load

module StimulusReflex
  class Engine < Rails::Engine
    initializer "stimulus_reflex.sanity_check" do
      SanityChecker.check!
    end
  end
end

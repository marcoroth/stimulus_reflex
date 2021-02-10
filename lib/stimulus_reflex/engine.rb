# frozen_string_literal: true

module StimulusReflex
  class Engine < Rails::Engine
    initializer "stimulus_reflex.sanity_check" do
      SanityChecker.check! unless Rails.env.production?
    end
  end
end

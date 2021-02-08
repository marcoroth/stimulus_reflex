module StimulusReflex
  class Engine < Rails::Engine
    isolate_namespace StimulusReflex

    initializer "stimulus_reflex.sanity_check" do
      SanityChecker.check! unless Rails.env.production?
    end
  end
end

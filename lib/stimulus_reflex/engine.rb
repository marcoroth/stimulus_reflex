module StimulusReflex
  class Engine < Rails::Engine
    isolate_namespace StimulusReflex

    initializer "stimulus_reflex.sanity_check" do
      SanityChecker.check! if Rails.env.development?
    end
  end
end

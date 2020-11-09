# frozen_string_literal: true

# require 'cable_ready/test_helpers'

module CableReady
  module TestHelpers
    def assert_dom_operation
      # ...
    end

    def assert_adjacent_test
      # ...
    end

    def assert_adjacent_html
      # ...
    end

    def assert_adjacent_text
      # ...
    end

    def assert_inner_html
      # ...
    end

    def assert_outer_html
      # ...
    end
  end
end

module StimulusReflex
  module TestHelpers
    include CableReady::TestHelpers

    def stimulate(target, element, options)
      # Reflex.call(target)
    end

    def assert_morph
      # ...
    end

    def assert_no_morph
      # ...
    end

    def assert_page_morph
      # ...
    end

    def assert_selector_morph
      # ...
    end

    def assert_nothing_morph
      # ...
    end
  end
end

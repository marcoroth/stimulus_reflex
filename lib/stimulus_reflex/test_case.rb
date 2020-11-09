# frozen_string_literal: true

require 'active_support/test_case'

module StimulusReflex
  class TestCase < ActiveSupport::TestCase
    include StimulusReflex::TestHelpers
  end
end


# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require "minitest/mock"
require "rails"
require "active_model"
require "active_record"
require "action_controller"
require "pry"
require "rails/test_help"

require_relative "../lib/stimulus_reflex"
require_relative "../test/dummy/config/environment"

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path("../db/migrate", __dir__)

ActionCable::Server::Base.config.cable = { adapter: "test" }
ActionCable::Server::Base.config.logger = Logger.new(nil)

require_relative "../app/channels/stimulus_reflex/channel"

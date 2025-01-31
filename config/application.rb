require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"
#
Dir["./lib/middleware/*.rb"].each do |file|
  require file
end

Dir["./lib/modules/*.rb"].each do |file|
  require file
end

Dir["./lib/classes/*.rb"].each do |file|
  require file
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DiffusionMarketplace
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.active_job.queue_adapter = :sidekiq

    config.middleware.use NTLMAuthentication if ENV['VAEC_ENV'] == 'true'
    config.middleware.use HeadersFilter if ENV['RAILS_ENV'] == 'production'

    # Reroute exceptions to custom logic
    config.exceptions_app = self.routes
    config.tinymce.install = :compile
    config.tinymce.install = :copy
  end
end

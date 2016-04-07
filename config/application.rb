require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'open-uri'
require 'phantomjs'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Dotenv::Railtie.load

module MusicFestival
  class Application < Rails::Application
    if Rails.env.production?
        redis_url = ENV["REDIS_URL"]
    else
        redis_url = "redis://localhost:6379"
    end

    config.cache_store = :redis_store, redis_url, { expires_in: 2.hours }
    config.session_store = :redis_store, redis_url, { 'foo': 'bar'}


    config.encoding = 'utf-8'
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
  end
end

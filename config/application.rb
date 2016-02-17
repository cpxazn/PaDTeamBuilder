require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PadTeamBuilder
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
	config.vote_new_user_interval = 1 #Number of months in between before voting again
	config.vote_display_default = 3 #Number of months prior to include in score
	config.vote_weighted_avg = [[0,4,0.5],[4,6,0.2],[6,8,0.15],[8,10,0.08],[10,12,0.04],[12,0,0.03]] #Not being used
	config.vote_display_max = 24 #Max months to display in graphs
	config.vote_display_eom = true #Set to true to pull data from eof instead of current date
	config.vote_list_max = 15 #Max number of votes to list in index
	config.vote_rating_max = 10 #Max number of votes to list in index
	config.monster_list_max = 90 #Max number of monsters to list in index
	config.img_path_awakenings = "/static/img/awakenings/" #Path to awakening .png
	config.img_path_monsters = "http://padherder.com" #Path to APIs
  end
end

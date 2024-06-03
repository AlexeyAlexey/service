require 'spec_helper'

ENV['SERVICE_APP_ENV'] ||= 'test'

require_relative '../config/environment'

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if ServiceApp.env == 'production'


RSpec.configure do |config|

end

# require 'dotenv'
# Dotenv.load

ENV['SERVICE_APP_ENV'] ||= 'development'
# ENV['RACK_ENV'] = ENV['SERVICE_APP_ENV']

require_relative 'application'

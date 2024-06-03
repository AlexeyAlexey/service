# frozen_string_literal: true

require 'thor'

require_relative "service/version"
require_relative "service/cli"

module Service
  class Error < StandardError; end
  # Your code goes here...
end

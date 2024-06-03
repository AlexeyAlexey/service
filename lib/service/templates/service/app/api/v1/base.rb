require_relative 'hello_world'

module API
  module V1
    class Base < Grape::API
      version 'v1', using: :path
      format :json
      # prefix :api

      mount API::V1::HelloWorld
    end
  end
end

module API
  module V1
    class HelloWorld < Grape::API

      resource :hello_world do

        desc 'Returns Hello World'
        get '/' do
          # present {}, with: API::Entities::HelloWorld

          { message: 'Hello World' }
        end

        get '/db_version' do
          { message: ActiveRecord::Base.connection.execute('SELECT VERSION();').values.flatten.first }
        end
      end
    end
  end
end

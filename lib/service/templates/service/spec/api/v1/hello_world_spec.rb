require 'service_helper'

describe API::V1::HelloWorld do
  include Rack::Test::Methods

  def app
    API::V1::HelloWorld
  end

  context 'GET /hello_world' do
    it 'returns an message' do
      get '/v1/hello_world'

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to include({ 'message' => 'Hello World' })
    end
  end
end

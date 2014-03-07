require 'sinatra/base'
require 'json'
require 'oauth2'

def new_client
  OAuth2::Client.new(
    ENV['HS_OAUTH_ID'],
    ENV['HS_OAUTH_SECRET'],
    :site => 'https://www.hackerschool.com'
  )
end

class DoorbotApp
  get '/' do
    "<a href='/login'>Login</a>"
  end

  get '/login' do
    client = new_client
    redirect client.auth_code.authorize_url(:redirect_uri => 'http://localhost:5000/oauth_callback')
  end

  get '/oauth_callback' do
    client = new_client
    token = client.auth_code.get_token(params[:code], :redirect_uri => 'http://localhost:5000/oauth_callback', :headers => {'Authorization' => 'Basic some_password'})
    token.get('/api/v1/people/me.json').body.to_s + "\n#{token.token}"
  end
end
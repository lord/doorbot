require 'sinatra/base'
require 'json'
require 'oauth2'
require 'net/http'

$counter = 0

def new_client
  OAuth2::Client.new(
    ENV['HS_OAUTH_ID'],
    ENV['HS_OAUTH_SECRET'],
    :site => 'https://www.hackerschool.com'
  )
end

class DoorbotApp < Sinatra::Base
  configure do
    enable :sessions
  end

  get '/' do
    if logged_in?
      erb :unlock
    else
      "<a href='/login'>Login</a>"
    end
  end

  get '/login' do
    client = new_client
    redirect client.auth_code.authorize_url(:redirect_uri => "#{ENV['HS_OAUTH_CALLBACK']}/oauth_callback")
  end

  get '/oauth_callback' do
    client = new_client
    token = client.auth_code.get_token(params[:code], :redirect_uri => "#{ENV['HS_OAUTH_CALLBACK']}/oauth_callback")
    session[:user] = JSON.parse(token.get('/api/v1/people/me.json').body)['id']
    redirect to('/')
  end

  post '/unlock' do
    halt "Please <a href='/login'>login</a>." unless logged_in?

    $counter += 1
    counter = $counter # in case of multi-threading
    hash = Digest::SHA2.new << counter.to_s + 'tuehnoschhrs189072398nthna'
    uri = URI("http://10.0.3.240/#{"%09d" % counter}/#{hash}")
    res = Net::HTTP.post_form(uri, {})
    res.body
  end

  def logged_in?
    ! session[:user].nil?
  end
end
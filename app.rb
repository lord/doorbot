require 'sinatra/base'
require 'sinatra/activerecord'
require 'json'
require 'oauth2'
require 'net/http'
require 'twilio-ruby'

def new_oauth_client
  OAuth2::Client.new(
    ENV['HS_OAUTH_ID'],
    ENV['HS_OAUTH_SECRET'],
    :site => 'https://www.hackerschool.com'
  )
end

def new_twilio_client
  return Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']
end

def unlock
  uri = URI("http://10.0.3.240/opendoor")
  Net::HTTP.post_form(uri, {})
end

class User < ActiveRecord::Base
  validates_presence_of :school_id
end

class DoorbotApp < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  configure do
    enable :sessions
  end

  get '/' do
    if logged_in?
      erb :unlock, locals: {user_number: current_user.phone}
    else
      "<a href='/login'>Login</a>"
    end
  end

  get '/login' do
    client = new_oauth_client
    redirect client.auth_code.authorize_url(:redirect_uri => "#{ENV['HS_OAUTH_CALLBACK']}/oauth_callback")
  end

  post '/update_user' do
    if params[:phone] && logged_in?
      user = current_user
      user.phone = params[:phone]
      user.save
    end
    redirect to('/')
  end

  get '/oauth_callback' do
    client = new_oauth_client
    token = client.auth_code.get_token(params[:code], :redirect_uri => "#{ENV['HS_OAUTH_CALLBACK']}/oauth_callback")
    school_id = JSON.parse(token.get('/api/v1/people/me.json').body)['id']
    session[:user] = school_id
    unless User.where(school_id: school_id).exists?
      User.create(school_id: school_id)
    end
    redirect to('/')
  end

  post '/unlock' do
    halt "Please <a href='/login'>login</a>." unless logged_in?

    unlock
    redirect to('/')
  end

  def logged_in?
    ! session[:user].nil?
  end

  def current_user
    unless session[:user].nil?
      User.where(school_id: session[:user]).first
    end
  end
end

require './config/environments'
require 'omniauth-twitter'
require 'twitter'
require 'sidekiq/api'
set :protection, except: :session_hijacking


get '/' do
  # Look in app/views/index.erb
  erb :index
end

post '/tweets' do
  # Look in app/views/index.erb
  # puts params
  user = User.find_by_nickname(session[:admin])
  @jid = user.tweet(params[:tweet])
  p "=====this is jid====="
  p @jid
  p "=====end====="
  erb :result, layout: false
end


configure do
  enable :sessions
end

helpers do
  def admin?
    session[:admin]
  end
end

get '/public' do
  "This is the public page - everybody is welcome!"
end

get '/private' do
  halt(401,'Not Authorized') unless admin?
  "This is the private page - members only"
end

get '/login' do
  session[:admin] = true

  redirect to("/auth/twitter")
end

get '/logout' do
  session[:admin] = nil
  "You are now logged out"
end

get '/auth/twitter/callback' do
  env['omniauth.auth'] ? session[:admin] = true : halt(401,'Not Authorized')
  "You are now logged in"
  p env['omniauth.auth']
  @user = User.find_or_create(env['omniauth.auth'])
  session[:admin] = @user.nickname
  redirect '/'
end

get '/auth/failure' do
  params[:message]
end

post '/tweet_later' do
  halt(401,'Not Authorized') unless admin?
  @user = User.find_by(nickname: session[:admin])
  job_id = @user.post_tweet_later!(params[:tweet_msg1], params[:time])
  redirect "/status/#{job_id}"
end


get '/status/:job_id' do
  job_id = params[:job_id]
  @complete = job_is_complete(params[:job_id]).to_s
  erb :job_status
end
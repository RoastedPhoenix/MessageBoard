require 'bundler'
Bundler.require
DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://db/main.db')
require './models.rb'
use Rack::Session::Cookie, :key => 'rack.session',
    :expire_after => 2592000,
    :secret => SecureRandom.hex(64)
get '/' do

  @users = User.all

  erb :signup
end

get '/incorrectlogin' do

  @users = User.all

  erb :incorrectlogin
end

get '/home' do
  @threads = Threads.all
  @user = User.first(:id => session[:uid])
  @username = @user.username
  @users = User.all
  erb :home
end

post '/account/signin' do
  redirect '/Login'
end

get '/Login' do
  @users = User.all

  erb :login
end

post '/user/create' do
  session[:posts] = []
  @u = User.new
  @u.username = params[:username]
  @username = params[:username]
  password = params[:password]
  @u.password = BCrypt::Password.create(password)
  @u.save
  @users = User.all
  session[:uid] = @u.id

  redirect '/home'
end

post '/user/login' do
  session[:posts] = []
  user_exist = false
  @username = params[:username]
  User.all do |user|
    if user.username == params[:username]
      user_exist = true
    end
  end
  if user_exist
    @u = User.first(:username => params[:username])
    if BCrypt::Password.new(@u.password) == params[:password].to_s
      session[:uid] = @u.id
      redirect '/home'
    else
      redirect '/incorrectlogin'
    end
  else
    redirect '/incorrectlogin'
  end
end
post '/create/thread' do
  @t = Threads.new
  @t.thread_name = params[:thread]
  @t.save
  session[:tid] = @t.thread_id
  redirect "/Thread"
end

post '/goto/thread' do
  session[:tid] = params[:thread]
  redirect '/Thread'
end

get '/Thread' do
  @user = User.first(:id => session[:uid])
  @username = @user.username
  @users = User.all
  @thread = Threads.first(:thread_id => session[:tid])
  @posts = Posts.all
  erb :Thread
end

post '/create/post' do
  @u = User.first(:id => session[:uid])
  @t = Threads.first(:thread_id => session[:tid])
  @threadname = @t.thread_name
  @username = @u.username
  @p = Posts.new
  @p.thread_overlord = @threadname
  @p.user_overlord = @username
  @p.actual_post = params[:make_post]
  @p.save
  redirect '/Thread'
end

post '/user/find' do
  session[:ouid] = User.first(:username => params[:other_user])
  redirect '/userpage'
end

get '/userpage' do
  @user = User.first(:id => session[:uid])
  @username = @user.username
  @other_user = session[:ouid]
  @other_user_posts = []
  @posts = Posts.all
  @posts.each do |post|
    @post_maker = post.user_overlord
    if @post_maker == @other_user.username
      @other_user_posts.push post
    end
  end
  erb :userpage
end

get '/signout'do
  session[:uid] = nil
  redirect '/'
end
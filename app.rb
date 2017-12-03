#encoding: UTF-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello Stranger!'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb '<h2>Main Page</h2>'
end

get '/about' do
  erb :about
end

get '/visit' do
  erb :form_add
end

get '/contacts' do
  erb :contacts
end

post '/add' do
    @master = params[:master]
    @user_name = params[:client]
    @phone     = params[:client_phone]
    @date_time = params[:date_time]
    @color = params[:color]
    @title = 'Thank you!'
    @message = "Dear #{@user_name}, we'll be wait for you at #{@date_time}, your master is #{@master} "
    file = File.open './public/users.txt', 'a'
    file.write "#{@master} color: #{@color}| User: #{@user_name}, Phone: #{@phone}, Date and time: #{@date_time}\n"
    file.close
    erb :message
end

get '/clients' do
  file = File.open './public/users.txt', 'r'
#    if @login == 'admin' && @password == 'secret'
    @message = 'Welcome to admin zone'
    @users = File.read("./public/users.txt")
    erb :file
   @users.close
#  end
end

get '/login/form' do
  erb :login_form
end

post '/login/attempt' do
  session[:identity] = params['username']
  if params['username'] == 'admin' && params['password'] == 'secret'
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from
  else 
    redirect '/login/form'
  end
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end

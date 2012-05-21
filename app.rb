require 'sinatra'
require 'rack-flash'

get '/' do
  haml :index, locals: { content: "Testing" }
end

get '/books/?' do
  haml :books, format: :html5
end


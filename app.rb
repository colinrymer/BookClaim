require 'sinatra'
require 'sinatra/config_file'
require 'data_mapper'
require 'net/http'
require 'json'
require 'curb'
require 'haml'

enable :logging

config_file 'config.yml'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite3::memory:")

class Book
  include DataMapper::Resource

  property :id,           Serial
  property :title,        String
  property :authors,      String
  property :description,  Text
  property :thumbnail,    String

end

helpers do
  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic Realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    # TODO: Use database for authentication here
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['admin', 'admin']
  end

  def partial(page, options={})
    haml page.to_sym, options.merge!(:layout => false)
  end

  def logger
    request.logger
  end
end

get '/' do
  haml :index, locals: { content: "Testing" }
end

get '/admin/?' do
  protected!
  haml :admin, locals: { apikey: settings.apikey }
end

get '/books/?' do
  haml :books, locals: { content: "Testing books" }
end

post '/book_search/?' do
  # TODO: This shouldn't redirect to admin, it should be general
  redirect '/admin' unless defined? query
  apikey = settings.apikey
  query = request.params["q"]

  resp = Curl::Easy.perform("https://www.googleapis.com/books/v1/volumes?q=" + URI.encode(query) + "&key=" + apikey)
  resp = JSON.parse(resp.body_str)

  # TODO: This shouldn't load admin by default, it should be general
  haml :admin, locals: { apikey: apikey, books: resp["items"], query: query }
end

post '/add_book/?' do
  Book.auto_migrate!

  book = Book.new
  book.title       = request.params["title"]
  book.authors     = request.params["authors"].join(", ")
  book.description = request.params["description"]
  book.thumbnail   = request.params["thumbnail"]

  book.save
end

get '/book_search/?' do
  request.params.inspect
end

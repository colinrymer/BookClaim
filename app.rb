require 'sinatra'
require 'sinatra/config_file'
require './lib/database'
require 'net/http'
require 'json'
require 'curb'
require 'haml'

enable :logging, :sessions

config_file 'config.yml'

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

  def partial(page, options={}, locals={})
    haml page.to_sym, options.merge!(:layout => false), locals
  end

  def logger
    request.logger
  end
end

get '/' do
  haml :index
end

get '/admin/?' do
  protected!
  @route = { method: "DELETE", action: "/books"}
  haml :admin, locals: { apikey: settings.apikey }
end

get '/books/?' do
  @route = { method: "POST", action: "/claims"}
  haml :books
end

post '/claims/?' do
  Claim.auto_migrate!

  claim = Claim.create({ # TODO: make this first_or_create and use PUT
      book_id: params[:book_id],
      name:    params[:name],
      note:    params[:note]
  })

  if claim
    logger.info("Added claim: " + claim.inspect)
  else
    logger.info("Failed adding claim with params: " + params.inspect)
  end
end

post '/books/?'  do
  Book.auto_migrate!

  book = Book.create({
    title:       params["title"],
    authors:     params["authors"].join(","), # TODO: figure out how these are being received
    description: params["description"],
    thumbnail:   params["thumbnail"]
  })

  if books
    logger.info("Added book: " + book.inspect)
  else
    logger.info("Failed adding book with params: " + params.inspect)
  end
end

delete '/books/:id/?' do
  Book.get(params[:id]).destroy
end

get '/book_search/?' do
  logger.info(params.inspect)
  # TODO: This shouldn't redirect to admin, it should return JSON parsed on the client side
  redirect '/admin' unless defined? params[:q]

  @action = "/add_book"
  @query = params[:q]

  resp = Curl::Easy.perform("https://www.googleapis.com/books/v1/volumes?q=" + URI.encode(@query) + "&key=" + settings.apikey)
  resp = JSON.parse(resp.body_str)
  @books = resp["items"]

  # TODO: This shouldn't load admin by default, it should be general
  @route = { method: "POST", action: "/books" }
  haml :admin
end

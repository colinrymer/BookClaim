require 'data_mapper'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, ENV["DATABASE_URL"] || "sqlite3::memory:")

class Book
  include DataMapper::Resource

  property :id,           Serial
  property :title,        String
  property :authors,      String
  property :description,  Text
  property :thumbnail,    String

end

class User
  include DataMapper::Resource

  property :id,           Serial
  property :username,     String
  property :password,     String
  property :admin,        Boolean
end

DataMapper.finalize.auto_upgrade!
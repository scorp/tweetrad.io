#!/usr/bin/env ruby

# application config
require File.join(File.dirname(__FILE__), '..', 'boot')

class TweetRadio < Sinatra::Base
  include App::WebConfiguration
  
  # admin home
  get "/" do
    erb :index
  end
  
  get "/tweets.json" do
    halt 400 unless params[:query]
    query = params[:query] 
    listing = get_listing(query)
    JSON.pretty_generate(listing)
  end
  
  
  private
  
  def get_listing(query)
    q = Query.find_by_query(query)
    unless q 
      q = Query.create({:query => query})
    end
    folder = S3Folder.new(query)
    folder.listing.map{|key|
      {
        "url"           => key.public_link,
        "last-modified" => Time.parse(key.headers["last-modified"]),
        "tweet"         => JSON.parse(key.meta_headers["job"])
      }
    }
  end
  
end

# start it up if we are in dev mode
TweetRadio.run! if TweetRadio.development?
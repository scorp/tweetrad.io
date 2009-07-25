require 'common'
class Searcher
  SEARCHER_SLEEP = 5
  
  class InvalidQueryException < Exception
    @message = "invalid query provided"
  end
  
  attr_reader :queue, :query
  
  def initialize(query=nil)
    raise InvalidQueryException unless query
    @query = query
    @queue = WorkQueue.new(query)
    @uuid = UUID.new.generate
  end

  # daemon loop for executing the searcher
  def go
    loop do
      begin
        search
        Kernel.sleep SEARCHER_SLEEP
      rescue
        App.log.error($!.message)
      end
    end
  end
  
  # execute the search and run its actions
  def search()
    results = []
    page = 1
    loop do
      results = fetch_page(page).select{ |result| result.id > last_twid}
      results.each{|result| add_to_queue(result)}
      break unless results.size > 0
      page += 1
    end 
  end

  # add a conversion job to the queue
  def add_to_queue(result)
    @last_twid = result.id
    @queue.push(ConversionJob.new({
      "queue_id"          => @queue.id,
      "twid"              => result.id,
      "from_user_id"      => result.from_user_id,
      "to_user_id"        => result.to_user_id,
      "from_user"         => result.from_user,
      "to_user"           => result.to_user,
      "profile_image_url" => result.profile_image_url,
      "iso_language_code" => result.iso_language_code,
      "text"              => result.text,
      "created_at"        => result.created_at
    }).to_json)
  end
  
  def last_twid
    @last_twid || 0
  end
  
  private 
  
  # fetch a page of results from the twitter search api
  def fetch_page(page)
    @client ||= Grackle::Client.new(:api=>:search)
    @client.search.json?(:q=>@query, :since_id=>last_twid || 0, :rpp=>100, :page=>page).results
  end
  
end
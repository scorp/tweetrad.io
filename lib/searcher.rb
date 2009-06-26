require 'common'
class Searcher
  class InvalidQueryException < Exception
    @message = "invalid query provided"
  end
  
  attr_reader :queue, :query
  
  def initialize(query=nil)
    raise InvalidQueryException unless query
    @query = query
    @queue = WorkQueue.new(query)
  end
  
  # execute the search and run its actions
  def search()
    results = []
    page = 1
    loop do
      results = fetch_page(@query, page).select{ |result| result.id > last_twid}
      results.each{|result| add_to_queue(result)}
      break unless results.size > 0
      page += 1
    end 
  end

  # add a conversion job to the queue
  def add_to_queue(result)
    @queue.push(ConversionJob.new(result))
  end
  
  private 
  
  # fetch a page of results from the twitter search api
  def fetch_page(page)
    @client ||= Grackle::Client.new(:api=>:search)
    @client.search.json?(:q=>@query, :since_id=>last_twid, :rpp=>100, :page=>page).results
  end
  
end
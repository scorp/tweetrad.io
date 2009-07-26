class Searcher
  RESULTS_PER_PAGE = 50
  
  attr_reader :queue, :query

  def query=(query)
    return unless query
    @query = query
    @queue = WorkQueue.new(query)
  end

  # execute the search and run its actions
  def search()
    @query_status = Query.for_queue(@queue)
    unless @query && @query_status
      return
    end

    total   = 0
    results = []
    page = 1

    @last_twid = @query_status.last_twid

    loop do
      # App.log.info("last_twid: " + @last_twid.to_s)
      results = fetch_page(page).select{|result| 
        if result.id.to_i > @last_twid
          App.log.info("result is #{result.id.to_i} greater than" + @last_twid.to_s)
          true
        end
      }
      results.each{|result| add_to_queue(result)}
      total += results.size
      # unless results.size > 0
      update_query_status(total)
      break
      # end
      # page += 1
    end 
  end
  
  # update the query status
  def update_query_status(total)
    @query_status.last_twid = @last_twid
    @query_status.last_run = Time.now.utc
    @query_status.last_result_count = total
    @query_status.save!
  end

  # add a conversion job to the queue
  def add_to_queue(result)
    @last_twid = @last_twid > result.id ? @last_twid : result.id
    App.log.info("pushing job to queue #{@queue.name}:\n#{result.text}\n#{"-"*80}")
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
  
  private 
  
  # fetch a page of results from the twitter search api
  def fetch_page(page)
    @client ||= Grackle::Client.new(:api=>:search)
    @client.search.json?(:q=>@query, :since_id=>@last_twid || 0, :rpp=>RESULTS_PER_PAGE, :page=>page).results
  end
  
end
class Query < ActiveRecord::Base

  # randomly select a query to process
  # TODO: add a weighting algorithm
  def self.choose
    queries = Query.all
    return false if queries.empty?
    queries[rand(queries.size)].query
  end
  
  # return the query for a given queue
  def self.for_queue(queue)
    return false unless queue
    Query.find_by_query(queue.name) 
  end
  
end
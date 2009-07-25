require 'common'
class WorkQueue
  
  attr_reader :id, :name
  
  class << self
    # get a connection to sqs
    def connection
      RightAws::SqsGen2.new(
        App.aws_access_id, 
        App.aws_secret_key
      )
    end
    
  end
    
  # constructor
  def initialize(queue_name)
    @name = queue_name
    @id   = Digest::MD5.hexdigest(@name)
  end
  
  # get the queue
  def get_sqs_queue
    @queue ||= RightAws::SqsGen2::Queue.create(self.class.connection, name, true)
  end
  
  # add a job to the queue
  def push(job)
    get_sqs_queue.send_message(job)
  end
  
  def pop
    get_sqs_queue.pop
  end
  
  # get the number of jobs in the queue
  def size
    get_sqs_queue.size
  end
  
  # purge the messages in the queue
  def flush
    get_sqs_queue.clear
  end
  
end
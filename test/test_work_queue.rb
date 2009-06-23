require File.join(File.dirname(__FILE__), 'test_setup')
require 'work_queue'

class WorkQueueTest < Test::Unit::TestCase
  context "the work queue class" do
    should "be able to connect to sqs" do
      assert_equal WorkQueue.connection.class, RightAws::SqsGen2
    end
  end
  
  context "a work queue instance" do
    
    setup do
      @queue = WorkQueue.new("test")
    end
    
    should "have a queue name" do
      assert_equal @queue.name, "test"
    end
    
    should "have access to an sqs queue" do
      assert_equal @queue.get_sqs_queue.class, RightAws::SqsGen2::Queue
    end
    
    should "be able to accept new jobs" do
      assert_equal @queue.push("do this").class, RightAws::SqsGen2::Message
    end
    
    should "be able to pop off a work item" do
      message = @queue.pop
      assert_equal message.class, RightAws::SqsGen2::Message
      assert_equal message.to_s, "do this"
    end
    
  end

end
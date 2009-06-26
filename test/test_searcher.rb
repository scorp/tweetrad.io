require File.join(File.dirname(__FILE__), 'test_setup')
require 'searcher'

class SearcherTest < Test::Unit::TestCase
  
  context "a searcher instance" do
    
    setup do
      @searcher = Searcher.new("test")
    end
    
    should "should not be created without a query" do
      assert_raises Searcher::InvalidQueryException do
        Searcher.new
      end
    end
    
    should "create a work queue" do
      assert @searcher.queue
    end
    
    
    
    
    
  end
end
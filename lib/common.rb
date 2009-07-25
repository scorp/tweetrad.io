# libraries
require 'rubygems'
require 'right_aws'
require 'grackle'
require 'json'
require 'uuid'
require 'ruby-debug'

# application constants
APP_ROOT       = File.dirname(__FILE__)

class App
  AWS_ACCESS_ID  = "1GD12SM2VVKC1EYS5XR2"
  AWS_SECRET_KEY = "+mAu07yxj2Zwzv5eFixKB9N+jbBZQfRry0PXPKGv"
  
  class << self
    
    # return the apps platform
    def platform
      case RUBY_PLATFORM
        when /darwin/
          "osx"
        when /linux/
          "linux"
      end
    end
    
    def log
      @log ||= Logger.new(STDOUT)
    end
    
    # ============
    # = AWS KEYS =
    # ============
    def aws_access_id
      AWS_ACCESS_ID
    end
    
    def aws_secret_key
      AWS_SECRET_KEY
    end
    
    def aws_bucket
      "tweetrad.io"
    end
    
    # ===================
    # = Twitter/Grackle =
    # ===================
    
  end
  
end

# load path
Dir.glob(File.join(APP_ROOT, "**", "*.rb")).each do |lib|
  require lib
end
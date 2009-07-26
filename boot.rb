# libraries
require 'rubygems'
require 'daemons'
require 'right_aws'
require 'grackle'
require 'json'
require 'uuid'
require 'optparse'
require 'active_record'
require 'ruby-debug'

# application constants
APP_ROOT       = File.join(File.dirname(__FILE__)) unless defined? APP_ROOT

class App
  # constants for AWS
  AWS_ACCESS_ID  = "1GD12SM2VVKC1EYS5XR2" unless defined? AWS_ACCESS_ID
  AWS_SECRET_KEY = "+mAu07yxj2Zwzv5eFixKB9N+jbBZQfRry0PXPKGv" unless defined? AWS_SECRET_KEY
  
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
    
    # ===========
    # = Logging =
    # ===========
    # basic logger
    def log
      @log ||= Logger.new(STDOUT)
    end
    
    # exception handler
    def log_exception(ex=$!, message=nil)
      log.error("*"*80)
      log.error(message) if message
      log.error(ex.message)
      log.error("*"*80)
      log.error(ex.backtrace.join("\n"))
      log.error("*"*80)
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
  end
end

# load path
Dir.glob(File.join(APP_ROOT, "lib", "**", "*.rb")).each do |lib|
  begin
    require lib
  rescue 
    App.log_exception
  end
end
# libraries
require 'rubygems'
require 'right_aws'

# application constants
APP_ROOT       = File.dirname(__FILE__)

# load path
$:.unshift(*Dir.glob(File.join(APP_ROOT)))

class ApplicationConfiguration
  AWS_ACCESS_ID  = "1GD12SM2VVKC1EYS5XR2"
  AWS_SECRET_KEY = "+mAu07yxj2Zwzv5eFixKB9N+jbBZQfRry0PXPKGv"
  
  class << self
    
    # ============
    # = AWS KEYS =
    # ============
    def aws_access_id
      AWS_ACCESS_ID
    end
    
    def aws_secret_key
      AWS_SECRET_KEY
    end
    
  end
  
end
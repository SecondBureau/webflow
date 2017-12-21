module Webflow
  module Configuration
    
    mattr_writer :token
    
    def configure
      yield self
    end
    
    def token
      @@token ||= 'SET ME IN config/initializers/webflow.rb'
    end
    
  end
end

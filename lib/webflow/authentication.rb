module Webflow
  class Authentication
    
    class AuthenticationError < StandardError; end
    
    include Singleton
    
    def self.token
      self.instance.token
    end
    
    def token
      Rails.logger.error "\e[31m[WEBFLOW]\033[0m Token not set. Check initializer" if Webflow.token.blank?
      Webflow.token
    end
    
  end
  
end
module Webflow
  class Client
    
    class RateLimitError < StandardError; end
    class ValidationError < StandardError; end
    
    ATTRIBUTES = []
    
    attr_accessor :id
    
    def initialize(params=nil)
      load(params) unless params.nil?
      cast
    end
    
    def self.reload
      @@collection = @@object = nil
      self
    end
    
    def self.get(url)
      response = Webflow.connexion.get do |req|
        req.url url
      end
      
      if response.status.eql?(200)
        JSON.parse(response.body) 
      else
        raise_rate_limit_error response
        Rails.logger.error "\e[31m[WEBFLOW]\033[0m Error #{response.status}" 
        Rails.logger.debug "\e[36m[WEBFLOW]\033[0m #{response.inspect}" 
      end
    end
    
    def save
      id.nil? ? create : update
    end
    
    def post(url, data)
      response = Webflow.connexion.post do |req|
        req.url url
        req.headers['Content-Type'] = 'application/json'
        req.body = data.to_json
      end
      if response.status.eql?(200)
        JSON.parse(response.body) 
      else
        raise_rate_limit_error response
        raise_validation_error response
        Rails.logger.error "\e[31m[WEBFLOW]\033[0m Error #{response.status}" 
        Rails.logger.debug "\e[36m[WEBFLOW]\033[0m #{response.inspect}"
      end
    end
    
    def put(url, data)
      response = Webflow.connexion.put do |req|
        req.url url
        req.headers['Content-Type'] = 'application/json'
        req.body = data.to_json
      end
      if response.status.eql?(200)
        JSON.parse(response.body) 
      else
        raise_rate_limit_error response
        raise_validation_error response
        Rails.logger.error "\e[31m[WEBFLOW]\033[0m Error #{response.status}" 
        Rails.logger.debug "\e[36m[WEBFLOW]\033[0m #{response.inspect}"
      end
    end
    
    # https://developers.webflow.com/#errors
    def self.error_codes
    {
      [400, SyntaxError]        =>  'Request body was incorrectly formatted. Likely invalid JSON being sent up.',
      [400, InvalidAPIVersion]  =>  'Requested an invalid API version',
      [400, UnsupportedVersion] =>  'Requested an API version that in unsupported by the requested route',
      [400, NotImplemented]     =>  'This feature is not currently implemented',
      [400, ValidationError]    =>  'Validation failure (see err field in the response)',
      [400, Conflict]           =>  'Request has a conflict with existing data.',
      [401, Unauthorized]       =>  'Provided access token is invalid or does not have access to requested resource',
      [404, NotFound]           =>  'Requested resource not found',
      [429, RateLimit]          =>  'The rate limit of the provided access_token has been reached. Please have your application respect the X-RateLimit-Remaining header we include on API responses.',
      [500, ServerError]        =>  'We had a problem with our server. Try again later.',
      [400, UnknownError]       =>  'An error occurred which is not enumerated here, but is not a server error.',
    }
    end
    
    private
  
    def load(params)
      self.id ||= params.delete("_id")
      self.class::ATTRIBUTES.each do |att|
        send("#{att}=", params.delete(att)) if params.include?(att)
      end
    end
    
    def cast
      self.createdOn = Time.parse(createdOn) rescue nil if self.respond_to?(:createdOn)
    end
    
    #TODO
    #refactoring
    
    def self.raise_rate_limit_error(response)
      if response.status.eql?(429) || (response.status.eql?(400) && JSON.parse(response.body)['name'].eql?('RateLimit'))
        raise RateLimitError, response.inspect
      end
    end
    
    def raise_rate_limit_error(response)
      self.class.raise_rate_limit_error response
    end
    
    def self.raise_validation_error(response)
      if response.status.eql?(400)
        problems = JSON.parse(response.body)['problems']
        raise ValidationError, problems.is_a?(Array) ? problems.join(' - ') : problems.to_s
      end
    end
    
    def raise_validation_error(response)
      self.class.raise_validation_error response
    end
        
  end
end

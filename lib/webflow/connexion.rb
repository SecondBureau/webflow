require 'faraday'

module Webflow
  module Connexion
    
    API_ENDPOINT = 'https://api.webflow.com'
    
    def connexion
      get_connexion
    end
    
    private
    
    def get_connexion
      Faraday.new(url: API_ENDPOINT) do |conn|
        conn.request  :url_encoded
        conn.response :logger do |logger|
          logger.filter(/(api_key=)(\w+)/,'\1[REMOVED]')
        end
        conn.authorization(:Bearer, Webflow::Authentication.token)
        conn.adapter  Faraday.default_adapter
        conn.headers['Accept-Version'] = '1.0.0'
     end
    end
  end
  
end
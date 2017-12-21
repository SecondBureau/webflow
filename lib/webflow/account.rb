class Webflow::Account < Webflow::Client
  
  ATTRIBUTES = %w(createdOn grantType lastUsed sites orgs users rateLimit status)
  
  attr_accessor *ATTRIBUTES
  
  def self.info
    @@object ||= self.new(get("/info"))
  end
  
  def cast
    super
    self.lastUsed = Time.parse(lastUsed) rescue nil
  end
  
end
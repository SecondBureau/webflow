class Webflow::Site < Webflow::Client
  
  ATTRIBUTES = %w(createdOn name shortName lastPublished previewUrl timezone database)
  
  attr_accessor *ATTRIBUTES
  
  def self.all
    @@collection ||= get("/sites").inject([]) do |sites, site|
      sites << self.new(site)
    end
  end
  
  def self.find_by_id(id)
    @@object ||= {}
    @@object[id] ||= self.new(get"/sites/#{id}")
  end
  
  def collections
    Webflow::Collection.all(id)
  end
  
  private
  
  def cast
    super
    self.lastPublished = Time.parse(lastPublished) rescue nil
  end
  
end

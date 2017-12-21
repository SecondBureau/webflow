class Webflow::Collection < Webflow::Client
  
  class SiteNotFoundError < StandardError ; end
    
  ATTRIBUTES = %w(lastUpdated createdOn name slug singularName fields)
  
  attr_accessor *ATTRIBUTES
  attr_accessor :site_id
  
  def self.all(site_id=nil)
    @@collection ||= {}
    if site_id.nil?
      Webflow::Account.info.sites.inject([]) do |c,o|
        c << self.all(o)
      end.flatten
    else
      @@collection[site_id] ||= get("/sites/#{site_id}/collections").inject([]) do |c, o|
        c << self.new(o.merge(site_id: site_id))
      end
    end
  end
  
  def self.find_by_id(id)
    @@object ||= {}
    @@object[id] ||= self.new(get"/collections/#{id}")
  end
  
  def items
    Webflow::Item.all(id)
  end
  
  private 
  
  def load(params)
    super
    self.site_id = params[:site_id]
  end
  
  def cast
    super
    self.lastUpdated = Time.parse(lastUpdated) rescue nil
  end

end
class Webflow::Item < Webflow::Client
  
  class CollectionNotFoundError < StandardError ; end
    
  ATTRIBUTES = %w(name slug)
  
  DEFAULT_FIELDS = ["name", "slug", "_archived", "_draft", "created-on", "updated-on", "published-on", "created-by", "updated-by", "published-by"]
  
  attr_accessor *ATTRIBUTES
  attr_accessor :archived, :draft, :collection_id
  attr_accessor :updatedOn, :createdOn, :publishedOn, :updatedBy, :createdBy, :publishedBy
  attr_accessor :fields
  
  # TODO
  # refactoring
  def initialize(params=nil)
    self.collection_id  = params.delete(:collection_id)
    self.collection_id  = params.delete("_cid") if params.include?('_cid')
    if collection_id.present?
      att = attributes.dup
      singleton_class.class_eval { attr_accessor *att } 
    end
    if params.present?
      load(params) 
      cast
    end
  end
  
  def self.fieldnames(collection_id)
    @@fieldsnames ||= {}
    @@fieldsnames[collection_id] ||= (Webflow::Collection.find_by_id(collection_id).fields.collect{|_| _['slug']} - DEFAULT_FIELDS)
  end
  
  def attributes
    self.class.fieldnames(collection_id).collect{|m| m.underscore}
  end
  
  def self.all(collection_id=nil)
    @@collection ||= {}
    if collection_id.nil?
    else
      @@collection[collection_id] ||= get_items(collection_id)
    end
  end
  
  def self.get_items(collection_id, offset=nil, limit=nil)
    response = get("/collections/#{collection_id}/items")
    # TODO total collection > 100
    response['items'].inject([]) do |c, o|
      c << self.new(o)
    end
  end
  
  def self.get_item(collection_id, id)
    response = get("/collections/#{collection_id}/items/#{id}")
    new response['items'].first
  end
  
  def self.find_by_id(params)
    id            = params.delete(:id)
    collection_id = params.delete(:collection_id)
    @@object ||= {}
    @@object[Digest::MD5.hexdigest("#{id}-#{collection_id}") ] ||= get_item(collection_id, id)
  end
  
  def data
    (ATTRIBUTES + self.attributes).inject({}) { |h,e| h[e.dasherize] = send(e) ; h}
  end
  
  def create
    item = post("/collections/#{collection_id}/items?live=true", {live: true, fields: data.merge("_archived":false, "_draft":false)})
    self.id = item["_id"]
  end
  
  def update
    item = put("/collections/#{collection_id}/items/#{id}", fields: data.merge("_archived":false, "_draft":false))
    self.id
  end
  
  private 
  
  def fields(params)
    self.class.fieldnames(collection_id).each do |slug|
      self.send "#{slug.underscore}=", params.delete(slug)
    end
  end
  
  def load(params)
    super
    self.archived       = params.delete("_archived")
    self.draft          = params.delete("_draft")
    self.updatedOn      = params.delete("updated-on")
    self.createdOn      = params.delete("created-on")
    self.publishedOn    = params.delete("published-on")
    self.updatedBy      = params.delete("updated-by")
    self.createdBy      = params.delete("created-by")
    self.publishedBy    = params.delete("published-by")
    fields(params)
  end
  
  def cast
    super
    self.updatedOn    = Time.parse(updatedOn) rescue nil
    self.createdOn    = Time.parse(createdOn) rescue nil
    self.publishedOn  = Time.parse(publishedOn) rescue nil
    
  end

end
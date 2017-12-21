class Webflow::Item < Webflow::Client
  
  class CollectionNotFoundError < StandardError ; end
    
  ATTRIBUTES = %w(name slug)
  
  DEFAULT_FIELDS = ["name", "slug", "_archived", "_draft", "created-on", "updated-on", "published-on", "created-by", "updated-by", "published-by"]
  
  attr_accessor *ATTRIBUTES
  attr_accessor :archived, :draft, :collection_id
  attr_accessor :updatedOn, :createdOn, :publishedOn, :updatedBy, :createdBy, :publishedBy
  attr_accessor :fields
  
  def self.fieldnames(collection_id)
    @@fieldsnames ||= {}
    @@fieldsnames[collection_id] ||= (Webflow::Collection.find_by_id(collection_id).fields.collect{|_| _['slug']} - DEFAULT_FIELDS)
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
  
  def self.find_by_id(id, collection_id)
    @@object ||= {}
    @@object[Digest::MD5.hexdigest("#{id}-#{collection_id}") ] ||= self.new(get"/collections/:#{collection_id}/items/#{id}")
  end
  
  def data
    (ATTRIBUTES + self.class.fieldnames(collection_id)).inject({}) { |h,e| h[e] = send(e) ; h}
  end
  
  def create
    puts data.inspect
    item = post("/collections/#{collection_id}/items", fields: data.merge("_archived":false, "_draft":false))
    self.id = item["_id"]
  end
  
  def save
    puts data.inspect
    item = put("/collections/#{collection_id}/items/{id}", fields: data.merge("_archived":false, "_draft":false))
  end
  
  private 
  
  def fields(params)
    self.class.fieldnames(collection_id).each do |slug|
      key = slug.underscore
      instance_variable_set("@#{key}", params.delete(slug))
      self.class.send(:define_method, key) { instance_variable_get("@#{key}") }
    end
  end
  
  def load(params)
    super
    self.archived       = params.delete("_archived")
    self.draft          = params.delete("_draft")
    self.collection_id  = params.delete("_cid") if params.include?('_cid')
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
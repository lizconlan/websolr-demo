require 'indextank'
require 'yaml'
require 'time'

require 'solr'

class Indexer
  attr_reader :conn
  
  def initialize
    if ENV['WEBSOLR_URL']
      url = ENV['WEBSOLR_URL']
    else
      url = YAML::load(File.read("config/websolr.yml"))[:websolr_url]
    end
    @conn = Solr::Connection.new(url, :autocommit => :on)
  end
  
  def add_document(seg_id, doc, text, categories, index=nil)
    doc[:id] = seg_id
    doc[:text] = ""
    doc[:timestamp] = ""
    doc[:members] = ""
    
    p doc.inspect
    
    p ""
    p @conn.inspect
    
    @conn.add(doc)
  end
end
require 'yaml'
require 'time'

require 'sunspot'
require 'models/snippet'

class Indexer
  def initialize
    Sunspot.config.solr.url = ENV['WEBSOLR_URL'] || YAML::load(File.read("config/websolr.yml"))[:websolr_url]
  end
  
  def add_document(seg_id, doc, text, categories, index=nil)
    snippet = Snippet.new(seg_id)
    
    snippet.text = text
    snippet.title = doc[:title]
    snippet.volume = doc[:volume]
    snippet.members = doc[:members] #could be done better
    snippet.chair = doc[:chair]
    snippet.subject = doc[:subject]
    snippet.url = doc[:url]
    snippet.house = doc[:house]
    snippet.section = doc[:section]
    snippet.published_at = doc[:timestamp] #shouldn't just store a timestamp
    
    Sunspot.index(snippet)
    Sunspot.commit
  end
end
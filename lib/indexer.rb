require 'yaml'
require 'time'

require 'models/snippet'
require 'sunspot'

class Indexer
  attr_reader :conn
  
  def initialize
    unless ENV['WEBSOLR_URL']
      ENV['WEBSOLR_URL'] = YAML::load(File.read("config/websolr.yml"))[:websolr_url]
    end
    
    Sunspot.setup(Snippet) do
      text :title, :description, :stored => true
      string :author_name
      integer :blog_id
      integer :category_ids
      float :average_rating, :using => :ratings_average
      time :published_at
    end
  end
end
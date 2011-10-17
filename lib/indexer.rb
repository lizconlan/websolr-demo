require 'indextank'
require 'yaml'
require 'time'

require 'sunspot_rails'

require 'models/snippet'


class Indexer
  def initialize    
    unless ENV['WEBSOLR_URL']
      ENV['WEBSOLR_URL'] = YAML::load(File.read("config/websolr.yml"))[:websolr_url]
    end
  end
end
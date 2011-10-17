require 'solr_mapper'
include SolrMapper

class Snippet
  include SolrMapper::SolrDocument
  
  if ENV['WEBSOLR_URL']
    bind_service_url(ENV['WEBSOLR_URL'])
  else
    bind_service_url(YAML::load(File.read("config/websolr.yml"))[:websolr_url])
  end
end
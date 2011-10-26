require 'sinatra'
require 'json'
require 'uri'
require 'cgi'
require 'open-uri'

WEBSOLR_URL = ENV['WEBSOLR_URL'] || YAML::load(File.read("config/websolr.yml"))[:websolr_url]

helpers do
  def facets_to_hash_array(facets)
    hash_array = []
    name = ""
    facets.each_with_index do |facet, pos|
      if pos.modulo(2) == 0
        name = facet
      else
        hash_array << {:name => name, :count => facet}
      end
    end
    hash_array
  end
end

get '/' do
  @q = params[:q]
	@section_filter = params[:section]
	
	if @q
	  # cache_control :public, :max_age => 600
	  url = WEBSOLR_URL + "/select/?q=text_texts:#{CGI::escape(@q)}&facet=true&facet.mincount=1&facet.field=section_ss&wt=json&indent=true"
	  
	  if @section_filter
	    url = "#{url}&fq=section_ss:%22#{CGI::escape(@section_filter)}%22"
	  end
	  
	  buffer = open(url, "UserAgent" => "Ruby-ExpandLink").read
      result = JSON.parse(buffer)
      @docs = result['response']['docs']
      @section_facets = facets_to_hash_array(result['facet_counts']['facet_fields']['section_ss'])
    end
    
	haml :index
end
  
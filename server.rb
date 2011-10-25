require 'sinatra'
require 'json'
require 'uri'
require 'cgi'
require 'open-uri'

WEBSOLR_URL = ENV['WEBSOLR_URL'] ||  YAML::load(File.read("config/websolr.yml"))[:websolr_url]

get '/' do
    @q = params[:q]
	if @q
	  # cache_control :public, :max_age => 600
	  buffer = open(WEBSOLR_URL + "/select/?q=text_texts:#{CGI::escape(@q)}&facet=true&facet.mincount=1&facet.field=section_ss&wt=json&indent=true", "UserAgent" => "Ruby-ExpandLink").read
      result = JSON.parse(buffer)
      @docs = result['response']['docs']
      @section_facets = fix_facets(result['facet_counts']['facet_fields']['section_ss'])
    end
    
	haml :index
end

private
  def fix_facets(facets)
    fixed = []
    name = ""
    facets.each_with_index do |facet, pos|
      if pos.modulo(2) == 0
        name = facet
      else
        fixed << {:name => name, :count => facet}
      end
    end
    fixed
  end
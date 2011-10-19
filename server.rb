require 'sinatra'
require 'json'
require 'open-uri'

WEBSOLR_URL = ENV['WEBSOLR_URL'] ||  YAML::load(File.read("config/websolr.yml"))[:websolr_url]

get '/' do
    @q = params[:q]
	if @q
	  # cache_control :public, :max_age => 600
	  buffer = open(WEBSOLR_URL + "/select/?q=text_texts:#{@q}&wt=json&indent=true", "UserAgent" => "Ruby-ExpandLink").read
      result = JSON.parse(buffer)
      @docs = result['response']['docs']
    end
    
	haml :index

end


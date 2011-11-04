require 'sinatra'
require 'json'
require 'cgi'
require 'open-uri'
require 'yaml'

WEBSOLR_URL = ENV['WEBSOLR_URL'] || YAML::load(File.read("config/websolr.yml"))[:websolr_url]

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  
  def url_segments_line(house, section, date, url, separator=" &rsaquo; ")
    parse_date = Date.parse(date)
    url_parts = url.split("/")
    house_text = "#{house} Hansard"
    house_link = "http://www.parliament.uk/business/publications/hansard/#{house.downcase}/"
    date_text = parse_date.strftime("%d %b %Y")
    
    date_link = "http://www.parliament.uk/business/publications/hansard/#{house.downcase()}/by-date/?d=#{parse_date.day}&m=#{parse_date.month}&y=#{parse_date.year}"
    section_end = ""
    if url_parts.last =~ /(\d*\.htm)/
      page = $1
      section_end = url_parts.last.split("#").first.gsub(page, "0001.htm")
    end
    section_link = "#{url_parts[0..url_parts.length-2].join("/")}/#{section_end}"

    [	"<a href='#{house_link}' title='#{house_text}: home page'>#{house_text}</a>", 
    	"<a href='#{date_link}' title='#{house_text}: #{date_text}'>#{date_text}</a>",
    	"<a href='#{section_link}' title='#{section}: #{date_text}'>#{section}</a>"
    	].join(separator)
    
  end
  
  def page_info
    info = "#{(@page.to_i-1)*10+1} to"
    if (@page.to_i-1)*10+10 < @found
      info = "#{info} #{(@page.to_i-1)*10+10}"
    else
      info = "#{info} #{@found}"
    end
    info
  end
  
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
	@page = params[:p]
	if @page.to_i < 1
	  @page = 1 
	else
	  @page = @page.to_i
	end
	
	if @q
	  if @q.strip.gsub("+", " ").split(" ").count > 1
	    query = ("\"#{@q}\"").squeeze('"')
	  else
	    query = @q
	  end
	  
	  url = WEBSOLR_URL + "/select/?q=text_texts:#{CGI::escape(query)}&facet=true&facet.mincount=1&facet.field=section_ss&wt=json&hl.fragsize=200&hl=true&hl.fl=text_texts"
	  
	  if @section_filter
	    url = "#{url}&fq=section_ss:%22#{CGI::escape(@section_filter)}%22"
	  end
	  
	  if @page > 1
	    url = "#{url}&start=#{(@page.to_i-1)*10}"
	  end
	  
	  unless CGI::escape(query).empty?
	    buffer = open(url).read
        result = JSON.parse(buffer)
        @found = result['response']['numFound']
        @docs = result['response']['docs']
        @highlights = result['highlighting']
        @section_facets = facets_to_hash_array(result['facet_counts']['facet_fields']['section_ss'])
      else
        redirect to('/')
      end
    end
    
	haml :index
end
  

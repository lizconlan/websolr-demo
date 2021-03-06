require 'sinatra'
require 'json'
require 'cgi'
require 'open-uri'
require 'yaml'

WEBSOLR_URL = ENV['WEBSOLR_URL'] || YAML::load(File.read("config/websolr.yml"))[:websolr_url]

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  
  def top_and_tail(result_highlights_array)
    
    return_text = ''
	result_highlights_text = result_highlights_array['text_texts'].to_s.gsub(/^[\.|\)]/, '').strip
    
    return_text << '... ' unless /^([A-Z]|<)/ =~ result_highlights_text[0,1]
    
    return_text << result_highlights_text          
    
    return_text << ' ...' unless result_highlights_text[-1..-1] == '.' 
    
    return_text
  end
  
  def url_segments_line(house, section, date, url, department = '')
  
    parse_date = Date.parse(date)
    url_parts = url.split('/')
    date_text = parse_date.strftime("%d %b %Y")
    date_link = "http://www.parliament.uk/business/publications/hansard/#{house.downcase()}/by-date/?d=#{parse_date.day}&m=#{parse_date.month}&y=#{parse_date.year}"
    section_end = ''
    
    if url_parts.last =~ /(\d*\.htm)/
      page = $1
      section_end = url_parts.last.split('#').first.gsub(page, '0001.htm')
    end
    
    section_link = [url_parts[0..url_parts.length-2].join('/'),section_end].join('/')
    
    breadcrumbs = "<a href='#{date_link}'>#{house} Hansard #{date_text}</a> &rsaquo; <a href='#{section_link}'>#{section}</a>"

    breadcrumbs << ' &rsaquo; ' << department.gsub(' and ',' & ') if department
    
	breadcrumbs
  end
  
  def page_info
    prev_page = @page.to_i-1
    prev_page_long_range = prev_page*10+10
    
    info = [prev_page*10+1, 'to']
    
    if prev_page_long_range < @found
      info << prev_page_long_range
    else
      info << @found
    end
    
    info.join(' ')
  end
  
  def prepare_title(text, word)
    text.gsub(/#{word}.?\b/i, '<strong>\0</strong>').gsub(':', ' -')
  end
  
  def prepare_contributors(members_array)
    
    members_array_length = members_array.length
    
    if members_array_length == 1
      contributors_text = 'Contributor: '
    else
      contributors_text = 'Contributors: '
    end
    
    if members_array_length > 3
      if members_array_length == 4
        contributors_text << members_array.join(', ') << ' and one other'
      else
        contributors_text << members_array[0,3].join(', ') << ' and ' << (members_array_length - 3).to_s << ' others'
      end
    else
      contributors_text << members_array.join(', ') 
    end
        
    contributors_text
    
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
	  
	  url = WEBSOLR_URL + "/select/?q=text_texts:#{CGI::escape(query)}&fq=type:Snippet&facet=true&facet.mincount=1&facet.field=volume_ss&facet.field=section_ss&facet.field=house_ss&wt=json&hl.fragsize=150&hl=true&hl.fl=text_texts"
	  
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
        @results = result['response']['docs']
        @highlights = result['highlighting']
        @section_facets = facets_to_hash_array(result['facet_counts']['facet_fields']['section_ss'])
      else
        redirect to('/')
      end
    end
    
	haml :index, :format => :html5
end
  

class Snippet < ActiveRecord::Base
  serialize :members, Array
  
  searchable do
    string  :title
    text    :text, :stored => true
    string  :url
    string  :part
    string  :volume
    string  :columns
    string  :chair
    string  :section
    string  :house
    string  :members, :multiple => true
    time    :published_at
  end
end
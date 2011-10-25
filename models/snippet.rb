require 'sunspot'

class Snippet
  attr_reader :id
  attr_accessor :title, :text, :volume, :columns, :part, :members, :chair, :subject, :url, :house, :section, :published_at
    
  Sunspot.setup(Snippet) do
    string :title, :stored => true
    string :volume, :part, :stored => true
    text :members, :stored => true
    text :text, :stored => true
    string :chair, :stored => true
    string :subject, :stored => true
    string :url, :stored => true
    string :house, :stored => true
    string :section, :stored => true
    time :published_at, :stored => true
  end
  
  def initialize(id)
    @id = id
  end
end

class InstanceAdapter < Sunspot::Adapters::InstanceAdapter
   def id
     @instance.id
   end
 end

 class DataAccessor < Sunspot::Adapters::DataAccessor
   def load(id)
     nil
   end
 end
 
Sunspot::Adapters::DataAccessor.register(DataAccessor, Snippet)
Sunspot::Adapters::InstanceAdapter.register(InstanceAdapter, Snippet)
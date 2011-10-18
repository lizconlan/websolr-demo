require 'sunspot'

class Snippet
  attr_accessor :title, :description, :_id
  
  Sunspot.setup(Snippet) do
    text :title, :description, :stored => true
  end
end

class InstanceAdapter < Sunspot::Adapters::InstanceAdapter
   def id
     nil
   end
 end

 class DataAccessor < Sunspot::Adapters::DataAccessor
   def load(id)
     nil
   end
 end
 
Sunspot::Adapters::DataAccessor.register(DataAccessor, Snippet)
Sunspot::Adapters::InstanceAdapter.register(InstanceAdapter, Snippet)
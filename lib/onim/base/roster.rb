module Onim
  
  class Base

    # list of contacts on the user's list
    class Roster
      
      attr_accessor :contacts

      # initialize with an empty array
      def initialize
        @contacts = []
      end

      # adds contact to the list
      def add_contact(contact)
        @contacts << contact
      end

      # find item with given jid on the list
      def [](jid)        
        @contacts.find {|c| c.jid == jid} || Contact.new(jid,jid)       
      end
       
    end
    
  end
  
end
module Onim
  
  class Base
    
    class Roster
      
      attr_accessor :contacts
      
      def initialize
        @contacts = []
      end
      def add_contact(contact)
        @contacts << contact
      end
      def [](jid)        
        @contacts.find {|c| c.jid == jid} || Contact.new(jid,jid)       
      end
    end
    
  end
  
end
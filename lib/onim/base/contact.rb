module Onim
  class Base
    class Contact
      attr_accessor :jid
      attr_accessor :name    
      attr_accessor :group
      attr_accessor :presence

      def initialize(jid,name,options)
        @name = name
        @jid = jid
        @presence = options[:presence] || :unavailable
        @group = options[:group]
      end

      def pure_jid
        @jid.split('/')[0]            
      end
    end
  end
end
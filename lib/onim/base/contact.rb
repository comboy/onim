require 'tempfile'
require 'base64'

module Onim
  class Base
    class Contact
      attr_accessor :jid
      attr_accessor :name    
      attr_accessor :group
      attr_accessor :presence
      attr_accessor :status

      def initialize(jid,name,options={})
        @name = name
        @jid = jid
        @presence = options[:presence] || :unavailable
        @group = options[:group]
        @status = options[:group]
#        if @vcard = options[:vcard]
#          if @vcard["PHOTO/TYPE"] && @vcard["PHOTO/BINVAL"]
#           @image_file = Tempfile.new('avatar')
#           @image_file.write Base64.decode64(@vcard["PHOTO/BINVAL"])
#           @image_file.close
#           puts "photo saved to #{@image_file.path}"
#           
#          end
#        end
        
      end

      def pure_jid
        @jid.split('/')[0]            
      end
      
      def vcard=(vcard)
        puts "vcard ==="
      end
      
      def image_file
        @image_file ? @image_file.path : nil
      end
      
    end
  end
end
require 'tempfile'
require 'base64'

module Onim
  class Base
    class Contact      
      class Resource
        
        attr_accessor :name
        attr_accessor :presence
        attr_accessor :status
      
        def initialize(name,presence,status)
          @name = name
          @presence = presence
          @status = status
        end
        
      end
      
      attr_accessor :jid
      attr_accessor :name    
      attr_accessor :group

      def initialize(jid,name,options={})
        @name = name
        @jid = jid       
        @group = options[:group]
        @resources = {}
      end

      def pure_jid
        @jid.split('/')[0]            
      end
      
      def vcard=(vcard)        
        @vcard = vcard
        if @vcard["PHOTO/TYPE"] && @vcard["PHOTO/BINVAL"]
           @image_file = File.open(File.join(Onim.conf_dir,'avatars_cache',@jid),'w')
           @image_file.write Base64.decode64(@vcard["PHOTO/BINVAL"])
           @image_file.close
           puts "photo saved to #{@image_file.path}"           
        end
      end
      
      def image_file
        @image_file ? @image_file.path : nil
      end
      
      def has_image?
        !@image_file.nil?
      end
      
      def highest_resource
        # as for now just choose the random one
        @resources.empty? ?
          nil :
          @resources.find { true }[1]
      end
      
      def update_presence(resource,presence,status)
        if res = @resources[resource]
          res.presence = presence
          res.status = status
        else
          @resources[resource] = Resource.new resource, presence, status
        end
      end
      
      def presence
        highest_resource ?
          highest_resource.presence :
          :unavailable        
      end
      
      def status
        highest_resource ?
          highest_resource.status :
          ''                
      end
      
    end # Contact
  end # Base
end # Onum

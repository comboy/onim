require 'tempfile'
require 'base64'

module Onim
  class Base

    # Class represening single contact on the roster used to pass info about
    # contacts between engine. base and gui
    class Contact

      # Represents resource for given contact
      # Contact can has many resources
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

      # Initilaziation
      def initialize(jid,name,options={})
        @name = name
        @jid = jid       
        @group = options[:group]
        @resources = {}
      end

      # Jid with resource stripped
      def pure_jid
        @jid.split('/')[0]            
      end

      # Set vcard for given contact
      # Method alse decodes avatar and saves it to the disk
      def vcard=(vcard)        
        @vcard = vcard
        if @vcard["PHOTO/TYPE"] && @vcard["PHOTO/BINVAL"]
           @image_file = File.open(File.join(Onim.conf_dir,'avatars_cache',@jid),'w')
           @image_file.write Base64.decode64(@vcard["PHOTO/BINVAL"])
           @image_file.close
           puts "photo saved to #{@image_file.path}"           
        end
      end

      # Returns path to avatar saved on disk (if any)
      def image_file
        @image_file ? @image_file.path : nil
      end

      # true if contact has an avatar
      def has_image?
        !@image_file.nil?
      end

      # Choose resorce with highest priority
      def highest_resource
        # as for now just choose the random one
        @resources.empty? ?
          nil :
          @resources.find { true }[1]
      end

      # Updates resource presence
      def update_presence(resource,presence,status)
        if res = @resources[resource]
          res.presence = presence
          res.status = status
        else
          @resources[resource] = Resource.new resource, presence, status
        end
      end

      # Returns symbol with current presence name
      def presence
        highest_resource ?
          highest_resource.presence :
          :unavailable        
      end

      # Status of the cantact
      def status
        highest_resource ?
          highest_resource.status :
          ''                
      end
      
    end # Contact
  end # Base
end # Onum

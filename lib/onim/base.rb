module Onim
  class Base
    
    attr_accessor :roster
    attr_accessor :config
    
    def initialize
      @logger = Logger.new File.join(Onim::PATH,"test.log")
      @config = Config.new self
      @roster = Roster.new
      @engine = Engine.new self
      @gui = Gui.new self
      
      Thread.new do 
        @engine.connect
      end
      @gui.show
    end
    
    def update_roster_item(item)
      @gui.item_update item
    end
    
    def roster_items=(items)
      @roster.contacts = items
      @gui.set_roster_items @roster.contacts
    end
    
    def message_received(jid,text)
      puts "base: message received"
      # XXX like this it's not possible for gui to tell which resorce sent it      
      @gui.message_received strip_jid(jid), text
    end

    def send_message(jid,text)
      @engine.send_message jid,text
    end
    
    def item_presence_change(jid,presence,status)
      debug("item presence change: #{jid} | #{presence} | #{status}")      
      pure_jid, resource = jid.split('/')
      item = @roster[pure_jid]
      item.update_presence(resource,presence,status)
      @gui.item_update item
    end
    
    def set_presence(presence,status='')
      @engine.set_presence(presence,status)
    end
    
    def auth_failure
      @gui.show_error("Niepoprawne dane logowania do serwera jabbera")
      Gui::Account.new self, true
    end
    
    def connect
      @engine.connect
    end
    
    def homedir
      File.join(::Onim::PATH,"tmp")
    end
        
    def debug(text)
      @logger.info text 
    end
    
    protected
    
    def strip_jid(jid)
      jid.split('/')[0]
    end
    
  end
end 

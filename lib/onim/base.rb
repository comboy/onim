module Onim

  # Base controller
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

    # Called when roster item needs to be updatet
    # for example it's vcard was updated
    def update_roster_item(item)
      @gui.item_update item
    end

    # Roster initialization
    def roster_items=(items)
      @roster.contacts = items
      @gui.set_roster_items @roster.contacts
    end

    # Called when message is received
    def message_received(jid,text)
      puts "base: message received"
      # XXX like this it's not possible for gui to tell which resorce sent it      
      @gui.message_received strip_jid(jid), text
    end

    # Sends the message
    def send_message(jid,text)
      @engine.send_message jid,text
    end

    # called whon contact status is changing
    def item_presence_change(jid,presence,status)
      debug("item presence change: #{jid} | #{presence} | #{status}")      
      pure_jid, resource = jid.split('/')
      item = @roster[pure_jid]
      item.update_presence(resource,presence,status)
      @gui.item_update item
    end

    # Sets own presence
    def set_presence(presence,status='')
      @engine.set_presence(presence,status)
    end

    # Called whon self presence was changed suceessfuly
    def presence_changed(presence,status)
      @gui.presence_changed(presence,status)
    end

    # Called on authentication error
    def auth_failure
      @gui.show_error("Niepoprawne dane logowania do serwera jabbera")
      Gui::Account.new self, true
    end

    # Connect to the server
    def connect
      @engine.connect
    end

    # WTF ? ;p
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

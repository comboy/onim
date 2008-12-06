module Onim
  class Base
    
    attr_accessor :roster
    
    def initialize
      @logger = Logger.new File.join(Onim::PATH,"test.log")
      @roster = Roster.new
      @engine = Engine.new self
      @gui = Gui.new self
      @engine.connect
      @gui.show
    end
    
    def roster_items=(items)
      @roster.contacts = items
      @gui.set_roster_items @roster.contacts
    end
    
    def message_received(jid,text)
      puts "base: message received"
      @gui.message_received jid, text
    end
    
    def send_message(jid,text)
      @engine.send_message jid,text
    end
    
    def item_presence_change(jid,presence,status)
      debug("item presence change: #{jid} | #{presence} | #{status}")
      @gui.item_presence_change(jid,presence,status)
    end
    
    def set_presence(presence,status='')
      @engine.set_presence(presence,status)
    end
        
    def debug(text)
      @logger.info text 
    end
  end
end 

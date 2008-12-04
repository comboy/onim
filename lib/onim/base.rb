module Onim
  class Base
    
    def initialize
      @logger = Logger.new File.join(Onim::PATH,"test.log")
      @engine = Engine.new self
      @gui = Gui.new self
      @engine.connect
      @gui.show
    end
    
    def roster_items=(items)
      @gui.set_roster_items items
    end
    
    def message_received(jid,text)
      puts "base: message received"
      @gui.message_received jid, text
    end
    
    def send_message(jid,text)
      @engine.send_message jid,text
    end
    
    def item_presence_change(jid,presence,status)
      @gui.item_presence_change(jid,presence,status)
    end
    
    def debug(text)
      @logger.info text 
    end
  end
end 

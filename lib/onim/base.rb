module Onim
  class Base
    
    def initialize
      @engine = Engine.new self
      @gui = Gui.new self
      #@engine.connect
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
  end
end 
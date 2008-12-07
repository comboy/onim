require 'pango'

module Onim
  class Gui  
    class Message
            
      def initialize(gui,contact)
        @gui = gui
        debug "Message.new"
        @contact = contact        
        create_window
      end
      
      def add_message(text,name=nil)
        debug "add message"
        @talk.buffer.insert  @talk.buffer.end_iter,"#{name || @contact.name}:  ", @nickname_tag
        @talk.buffer.insert  @talk.buffer.end_iter, "#{text}\n"
      end
      
      def window
        @window || create_window
      end
      
      protected

      def create_window
        debug "creating contact windew"
        @glade = GladeXML.new(Onim::PATH+'gui/message.glade', nil, 'window_message')      
        @window = @glade['window_message']
        debug "WINDOW CLASS: #{@window.class}"        
        @window.set_default_size 400,300    
        @window.title = 'Rozmowa z '+ @contact.name
        
        @window.show
        @talk = @glade['textview_talk']
        @input = @glade['textview_input']
        @input.signal_connect('key-press-event') do |textview,event|
          if event.keyval == Gdk::Keyval::GDK_Return
            send_message
          end
        end
        @window.signal_connect("destroy") do  |window|
          debug "message close"
          @window = nil
        end
        @nickname_tag = @talk.buffer.create_tag('nickname', 'weight' => Pango::FontDescription::WEIGHT_BOLD)
        @bla_tag = @input.buffer.create_tag('nickname', 'weight' => Pango::FontDescription::WEIGHT_BOLD)
         @input.buffer.insert @input.buffer.end_iter,"eooeu",@bla_tag
    
        @window
      end

      def send_message
        text = @input.buffer.text
        debug "sraaaaaakaaaaaaaaaaaa"+@input.buffer.get_slice(nil,nil,true)
        add_message text, 'Ja'
        @gui.base.send_message @contact.jid, text
        @input.buffer.text = ''
        debug "seeeeeeend"
      end
      
      def debug(text)
        @gui.debug("Message: #{text}")
      end
    end
  end
end

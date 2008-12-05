require 'pango'

module Onim
  class Gui
    class Message
      
      def initialize(gui,contact)
        @gui = gui
        @contact = contact
        debug "creating contact windew"
        debug @contact
        @glade = GladeXML.new(Onim::PATH+'gui/message.glade', nil, 'window_message')      
        @window = @glade['window_message']
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
        @nickname_tag = @talk.buffer.create_tag('nickname', 'weight' => Pango::FontDescription::WEIGHT_BOLD)
      end
      
      def add_message(text,name=nil)
        debug "add message"
        @talk.buffer.insert  @talk.buffer.end_iter,"#{name || @contact.name}:  ", @nickname_tag
        @talk.buffer.insert  @talk.buffer.end_iter, "#{text}\n"
      end
      
      protected

      def send_message
        text = @input.buffer.text
        add_message text, 'Ja'
        @gui.base.send_message @contact.jid, text
        @input.buffer.text = ''
      end
      
      def debug(text)
        @gui.debug("Message: #{text}")
      end
    end
  end
end

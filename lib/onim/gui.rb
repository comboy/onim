require 'gtk2'
require 'libglade2'


module Onim
  class Gui
    
    attr_accessor :base
    
    def initialize(base)            
      @base = base
      debug "GUI intialization"
      # Load main window
      @glade = GladeXML.new(Onim::PATH+'gui/main.glade', nil, 'window_main')      
      @main = @glade['window_main']
      @main.set_default_size 200,500
      @main.signal_connect("destroy") do  |window|
        Gtk.main_quit
      end

      # Load contacts lists and create columns
      @contacts = @glade['treeview_contacts']      
      %w{Icon Contact}.each_with_index do |name,index| 
        if name == 'Icon'
          renderer = Gtk::CellRendererPixbuf.new          
          @contacts.append_column(Gtk::TreeViewColumn.new(name, renderer, :pixbuf => index+1, 'background-gdk' => 3))
        else
          renderer = Gtk::CellRendererText.new
          @contacts.append_column(@bla = Gtk::TreeViewColumn.new(name, renderer, :markup => index+1, 'background-gdk' => 3))
        end
      end
      @contacts.expander_column = @bla
      @contacts.signal_connect('row-activated') { 
        |view,path,column| contact_click @contacts.model.get_iter(path)[0]
        
      }
      
      # Load status select
      @status_select = @glade['combobox_status']
#      renderer = Gtk::CellRendererText.new
#      @status_select.append_column(Gtk::TreeViewColumn.new('wow', renderer, :text => 0))
      available_statuses = Gtk::TreeStore.new(String)      
      %w{Dostępny Zajęty Niedostępny}.each do |item|
        x = available_statuses.append nil
        x.set_value(0,item)
      end
      @status_select.model = available_statuses
      @status_select.set_active 0
      
      @message_windows = {}
    end
    
    def show
      @main.show
      Gtk.main
    end
    
    def sm
      message_window = Message.new self, {:name => 'wou'}
    end
    
    def contact_click(contact)
      message_window_for(contact.jid).window
    end
    
    def message_window_for(jid)
      unless @message_windows[jid]
        debug "creating new message window"
        debug "jid: #{jid} contact: [#{@base.roster[jid]}]"
        @message_windows[jid] = Message.new self, @base.roster[jid]
        debug "oooooo"
      end      
      @message_windows[jid]
    end
    
    def message_received(jid,text)
      debug "message received from #{jid}"
      window = message_window_for(jid)
      debug "add msg"
      window.add_message(text)
    end
    
    def item_presence_change(jid,presence,status)
      debug "item presence changing for #{jid}"
      # FIXME
      jid = jid.split("/n")[0]
      @contacts_rows[jid].set_value(1,image_for_presence(presence))
      @contacts_rows[jid].set_value(2,"watta "+@contacts_rows[jid][2].split("\n")[0]+"\n<i>#{status}</i>")
      @contacts_rows[jid].set_value(4,presence.to_s[0].chr+@contacts_rows[jid][4][1..-1])
 end
    
    def set_roster_items(items)
      @contacts_rows = {}
      
      contacts_model = Gtk::TreeStore.new(Hash,Gdk::Pixbuf,String,Gdk::Color,String)
      #items = [{:name => 'ueoau', :jid => 'ueoueo'},{:name => 'ueoa', :jid => 'euooeu'}]
      @groups_rows = {}
      items.each do |item|        
        item.group = 'dupa' unless item.group
        if item.group
          if @groups_rows[item.group]
            parent = @groups_rows[item.group]
          else            
            parent = contacts_model.append nil
            parent.set_value(0,nil)
            parent.set_value(1,nil)
            parent.set_value(2,item.group)
            max_color = 255*255
            parent.set_value(3,Gdk::Color.new(max_color,max_color,max_color*0.8))
            @groups_rows[item.group] = parent
            parent.set_value(4,item.group)
          end
        else
          parent = nil
        end
        
        x = contacts_model.append parent
        
        @contacts_rows[item.jid] = x
        x.set_value(0,item)
        x.set_value(1,image_for_presence(item.presence))
        x.set_value(2,"#{item.name}\n")
#        x.set_value(3,item.presence)
        x.set_value(3,nil)
        presence_sort = item.presence.to_s[0].chr
        debug "presence sort: #{presence_sort}"
        x.set_value(4,presence_sort+(item.name|| ''))


      end
      
      contacts_model.set_sort_column_id(4)
      @contacts.model = contacts_model
      #@contacts.expand_all
    end
    
    def debug(text)
      base.debug("Gui: #{text}")
    end
    
    protected
    
    def image_for_presence(presence)
      debug "image for presence #{presence} :: #{presence.class}"
        image = case presence
        when :unavailable then 'user_offline.gif'
        when :available then 'user_online.gif'
        else 'user_dnd.gif'
        end      
        Gdk::Pixbuf.new(Onim::PATH+'gui/images/'+image)
    end
  end
end

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
          @contacts.append_column(Gtk::TreeViewColumn.new(name, renderer, :pixbuf => index+1, 'background-gdk' => 7))
        else
          renderer = Gtk::CellRendererText.new
          @contacts.append_column(Gtk::TreeViewColumn.new(name, renderer, :markup => index+1, 'background-gdk' => 7))
        end
        #renderer.font = "bold" if index == 5
      end
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
      #puts "contact click"
      #pp contact
      #jid = contact[:jid]
      #jid = jid.split('/')[0]
      window = message_window_for(contact.jid)
    end
    
    def message_window_for(jid)
      unless @message_windows[jid]
        debug "chhhhh"
        @message_windows[jid] = Message.new self, @base.roster[jid]
        debug "oooooo"
      end      
      @message_windows[jid]
    end
    
    def message_received(jid,text)
      debug "message received from #{jid}"
      #jid = jid.split('/')[0]
      window = message_window_for(jid)
      #pp @contacts_data
      debug "add msg"
      window.add_message(text)
    end
    
    def item_presence_change(jid,presence,status)
      @contacts_rows[jid].set_value(1,Gdk::Pixbuf.new(Onim::PATH+'gui/images/'+'user_online.gif'))
    end
    # 
    # items:
    # { :name => 'John',
    #   :jid => 'john@example.com'Cell }
    #
    #
    def set_roster_items(items)
      @contacts_rows = {}
      
      contacts_model = Gtk::TreeStore.new(Hash,Gdk::Pixbuf,String,Symbol)
      #issues = []
      #issues = redmine.project_issues project_id, @assignee_filter, @status_filter
      #items = [{:name => 'ueoau', :jid => 'ueoueo'},{:name => 'ueoa', :jid => 'euooeu'}]
      #pp issues      
      items.each do |item|
        status = item.presence
        x = contacts_model.append nil
        @contacts_rows[item.jid] = x
        x.set_value(0,item)
        image = case status
        when :unavailable then 'user_offline.gif'
        when :online then 'user_online.gif'
        else 'user_dnd.gif'
        end
        x.set_value(1,Gdk::Pixbuf.new(Onim::PATH+'gui/images/'+image))
        x.set_value(2,"<b>item.name</b>\noeueoueo")
        x.set_value(3,status)
#        @contacts.model.insert(nil,@contacts.model.iter_first,[{},'ueoa','euee','aaaa'])
      end
      
      @contacts.model = contacts_model
    end
    
    def debug(text)
      base.debug("Gui: #{text}")
    end
  end
end

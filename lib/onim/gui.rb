require 'gtk2'
require 'libglade2'


module Onim
  class Gui
    
    attr_accessor :base
    
    def initialize(base)            
      @base = base
      
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
        renderer = Gtk::CellRendererText.new
        #renderer.font = "bold" if index == 5
        @contacts.append_column(Gtk::TreeViewColumn.new(name, renderer, :text => index+1, 'background-gdk' => 7))
      end
      @contacts.signal_connect('row-activated') { 
        |view,path,column| contact_click @contacts.model.get_iter(path)
        
      }
      
      
      @message_windows = {}
    end
    
    def show
      @main.show
      #sm
      set_roster_items []
      Gtk.main
    end
    
    def sm
      message_window = Message.new self, {:name => 'wou'}
    end
    
    def contact_click(contact)
      puts "contact click"
      pp contact
    end
    
    def message_window_for(jid)
      unless @message_windows[jid]
        @message_windows[jid] = Message.new self, @contacts_data[jid]
      end      
      @message_windows[jid]
    end
    
    def message_received(jid,text)
      puts "GUI: message received from #{jid}"
      window = message_window_for(jid)
      pp @contacts_data
      jid = jid.split('/')[0]
      puts "add msg"
      @message_windows[jid].add_message(text)
    end
    
    # 
    # items:
    # { :name => 'John',
    #   :jid => 'john@example.com'Cell }
    #
    #
    def set_roster_items(items)
      @contacts_data = {}
      
      contacts_model = Gtk::TreeStore.new(Hash,String,String,Symbol)
      #issues = []
      #issues = redmine.project_issues project_id, @assignee_filter, @status_filter
      items = [{:name => 'ueoau', :jid => 'ueoueo'},{:name => 'ueoa', :jid => 'euooeu'}]
      #pp issues
      items.each do |item|
        @contacts_data[item[:jid]] = item
        x = contacts_model.append nil
        x.set_value(0,{})
        x.set_value(1,'o')
        x.set_value(2,item[:name])
        x.set_value(3,:unavailable)
#        @contacts.model.insert(nil,@contacts.model.iter_first,[{},'ueoa','euee','aaaa'])
      end
      
      @contacts.model = contacts_model
    end
  end
end
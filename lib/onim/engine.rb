
require 'xmpp4r'
require 'xmpp4r/roster'

module Onim
  class Engine
    include Jabber
    #Jabber::debug = true 
    
    def initialize(base)
      @base = base
    end
    
    def send_message(jid,text)
      m = Message.new(jid, text)
      @client.send m
    end
    
    def connect
      Thread.new do
        
      begin
        
      puts "setting up.."
      cl = Client.new(JID::new('kompotek@jabster.pl'))
      @client = cl
      puts "connect"
      cl.connect
      puts "auth"
      cl.auth 'bociankowo'
      puts "done"
      cl.send(Presence.new.set_type(:available))
      
     #cl.presence_updates do |friend, old_presence, new_presence|
     #  puts "Received presence update from #{friend.to_s}: #{new_presence}"
     #end
     
     # user1 sends the message "do you like Tofu?"
     #cl.received_messages do |message|
     #  puts "Received message from #{message.from}: #{message.body}"
   # end
    

    @roster = Roster::Helper.new cl
    mainthread = Thread.current
 
    @roster.add_query_callback { |iq|
      mainthread.wakeup
    }
    Thread.stop
          items =  []
          
          @roster.groups.each { |group|
            if group.nil?
              puts "*** Ungrouped ***"
            else
              puts "*** #{group} ***"
            end
            
            @roster.find_by_group(group).each { |item|
              puts "- #{item.iname} (#{item.jid})"
              items << {:name => item.iname, :jid => item.jid.to_s}
            }
            
            print "\n"
          }
          
          @base.roster_items = items
      
      puts "set presence"
      cl.send(Presence.new)
      puts "www"
      mainthread = Thread.current
      cl.add_message_callback do |m|
        if m.type != :error
          puts "engine, received"
          @base.message_received(m.from.to_s,m.body)
          puts "engine, done"
          m2 = Message.new(m.from, "You sent: #{m.body}")
          m2.type = m.type
          cl.send(m2)
          if m.body == 'exit'
            m2 = Message.new(m.from, "Exiting ...")
            m2.type = m.type
            cl.send(m2)
            mainthread.wakeup
          end
        end
      end
      Thread.stop
      #pp @roster.items

      rescue Exception => e
        puts e
        puts e.backtrace
      end
      end
    end
  end
end
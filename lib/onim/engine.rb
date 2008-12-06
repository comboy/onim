require 'rubygems'
require 'xmpp4r'
require 'xmpp4r/roster'

module Onim
  class Engine
    
    attr_accessor :base
    
    #include Jabber
    #Jabber::debug = true 
    
    def initialize(base)
      @base = base
    end
    
    def send_message(jid,text)
      m = Jabber::Message.new(jid, text)
      m.set_type :chat
      @client.send m
    end
    
    def connect
      Thread.new do
        
      begin
        
      debug "setting up.."
      #cl = Jabber::Client.new(Jabber::JID::new('kompotek@jabster.pl'))
      cl = Jabber::Client.new(Jabber::JID::new('kacper.ciesla@gmail.com'))
      @client = cl
      debug "connect"
      cl.connect
      debug "auth"
      #cl.auth 'bociankowo'
      cl.auth 'mrthnwrds7'
      debug "done"
      
      
          
      

    @roster = Jabber::Roster::Helper.new cl
              
    @roster.add_presence_callback do |item,oldpres,pres|
      pres = Jabber::Presence.new unless pres
      oldpres = Jabber::Presence.new unless oldpres

            
      #base.debug "presence change: #{pres.from} : #{pres.type.inspect }: #{pres.status.to_s}"     
      #base.debug "mmmmmmmm #{pres.show} ===== #{pres.priority} <"     
      #pres = oldpres
      #base.debug "OLD presence change: #{pres.from} : #{pres.type.inspect} #{pres.status.to_s}"     
      #base.debug "OLD mmmmmmmm #{pres.show} (#{pres.show.class}) ===== #{pres.priority} <"     
            
      status = pres.status.to_s
      presence = pres.show || :available
      jid = item.jid
      # XXX unavaliable
      presence = :unavailable if pres.status.to_s == 'unavailable'
      base.item_presence_change(jid.to_s,presence,status)
    end
          
    mainthread = Thread.current
 
    @roster.add_query_callback { |iq|
      mainthread.wakeup
    }
    Thread.stop
          items =  []
          
          @roster.groups.each { |group|
            if group.nil?
              debug "*** Ungrouped ***"
            else
              debug "*** #{group.inspect} ***"
            end
            
            @roster.find_by_group(group).each { |item|
              debug "- #{item.iname} (#{item.jid})"
              #items << {:name => item.iname, :jid => item.jid.to_s}
              items << Base::Contact.new(item.jid.to_s, item.iname, :group => group)
            }
            
            debug "\n"
          }
          
          @base.roster_items = items
      
      puts "set presence"
      cl.send(Jabber::Presence.new)
      puts "www"
      mainthread = Thread.current
      cl.add_message_callback do |m|
        if m.type != :error
          debug "message received from #{m.from} type #{m.type}"
          @base.message_received(m.from.to_s,m.body)
        end
      end
      Thread.stop
      #pp @roster.items
      cl.send(Presence.new.set_type(:available))

      rescue Exception => e
        #puts e
        #puts e.backtrace
        debug "EXCEPTION !!! #{e}"
        debug e.backtrace
      end
      end
    end
    
    protected
      def debug(text)
        base.debug("Base: #{text}")
      end
  end
end

require 'rubygems'
require 'xmpp4r'
require 'xmpp4r/roster'
require 'xmpp4r/vcard'

module Onim
  class Engine
    
    attr_accessor :base
    
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
      debug "setting up.. jid #{base.config[:account_jid]}"    
      cl = Jabber::Client.new(Jabber::JID::new(base.config[:account_jid]))
      @client = cl
      begin
        debug "connect"
        cl.connect
        debug "auth"
        cl.auth base.config[:account_password]
        # XXX proper exception types (including Jabber::ClientAuthenticationFailure)
      rescue Exception => ex        
        @base.auth_failure        
      end
      
      @roster = Jabber::Roster::Helper.new cl              
      @roster.add_presence_callback do |item,oldpres,pres|
        pres = Jabber::Presence.new unless pres
        oldpres = Jabber::Presence.new unless oldpres            
        status = pres.status.to_s
        presence = pres.show || :available
        jid = item.jid
        # XXX unavaliable
        presence = :unavailable if pres.status.to_s == 'unavailable'
        debug "item #{jid} chaged presence to #{presence} status #{status}"
        base.item_presence_change(jid.to_s,presence,status)
      end
          
      mainthread = Thread.current
 
      @roster.add_query_callback { |iq|
        mainthread.wakeup
      }
      Thread.stop
      items =  []          
      @roster.groups.each do |group|            
        @roster.find_by_group(group).each do |item|
          contact = Base::Contact.new(item.jid.to_s, item.iname, :group => group)
          Thread.new do
            debug "- #{item.iname} (#{item.jid})"
            vcard_hash = {}
            begin
              puts "getting vcard #{item.jid} "
              vcard = Jabber::Vcard::Helper.new(cl).get(item.jid.strip)
              puts "get vcard for #{item.jid}"
              if vcard
                vcard.fields.each do |field|
                  vcard_hash[field] = vcard[field]
                end
                contact.vcard = vcard_hash                
                puts "got end set"
                @base.update_roster_item contact
              else
                puts "no vcard for #{item.jid}"
              end
            rescue Exception => ex
              pp ex
              puts "Error while getting avatar"
            end
          end
          items << contact#, :vcard => vcard_hash)
        end
            
        debug "\n"
      end
          
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

      cl.send(Presence.new.set_type(:available))
    end
    
    protected
    def debug(text)
      base.debug("Engine: #{text}")
    end
  end
end

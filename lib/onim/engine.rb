require 'rubygems'
require 'xmpp4r'
require 'xmpp4r/roster'
require 'xmpp4r/vcard'

module Onim

  # Class responsible for connection with jabber server
  # It should be able to:
  # * connect with the server
  # * set status
  # * get roster and handle presence changes
  # * send messages and receive incoming ones
  class Engine
    
    attr_accessor :base
    
    #Jabber::debug = true 


    # Initilization
    # base is a handle for the main controller, used for callbacks
    def initialize(base)
      @base = base
    end

    # Sends a message
    # jid - recipient's jid
    # text - message text
    # message will be received as a jabber chat message
    def send_message(jid,text)
      m = Jabber::Message.new(jid, text)
      m.set_type :chat
      @client.send m
    end

    # Set own presence
    # presence - symbol representing prestence (:dnd, :away etc.)
    # status - status text
    def set_presence(presence=nil,status=nil)
      debug "setting presence to [#{presence}] : #{status}"
      @client.send(Jabber::Presence.new(presence,status)) if connected?
    end

    # Fetch roster items from server, blocknig
    # returns an array
    def get_roster_items
      cl = @client
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
      items
    end

    # Connnect to the jabber server and
    # * add hooks
    # * get roster
    # * set initial presence
    def connect
      debug "setting up.. jid #{base.config[:account_jid]}"    
      cl = Jabber::Client.new(Jabber::JID::new(base.config[:account_jid]))
      @client = cl
      begin
        debug "connect"
        cl.connect
        debug "auth"
        cl.auth base.config[:account_password]
        # XXX should catch only proper exception types (including Jabber::ClientAuthenticationFailure)
      rescue Exception => ex        
        debug "EX: #{ex.class} "
        debug ex.backtrace
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
          
      @base.roster_items = get_roster_items

      @client.send Jabber::Presence.new
      
      set_presence

      cl.add_message_callback do |m|
        if m.type != :error
          debug "message received from #{m.from} type #{m.type}"
          @base.message_received(m.from.to_s,m.body)
        end
      end
    end

    def connected?
      # this shold check if we are really connected not only if we tried..
      !!@client
    end
    
    protected
    
    def debug(text)
      base.debug("Engine: #{text}")
    end
  end
end

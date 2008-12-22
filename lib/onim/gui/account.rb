module Onim
  class Gui

    # Account configuration window
    class Account      
        attr_accessor :base
      
        def initialize(base,reconnect=false)
          @base = base
          @glade = GladeXML.new(Onim::PATH+'gui/account.glade', nil, 'account')      
          @window = @glade['account']      
          @glade['entry_jid'].text = base.config[:account_jid]  || ''
          @glade['entry_password'].text = base.config[:account_password]  || ''

          @glade['button_save'].signal_connect('clicked') do
            if @glade['checkbutton_remember'].active?
              base.config[:account_jid] = @glade['entry_jid'].text
              base.config[:account_password] = @glade['entry_password'].text
            end
            base.connect if reconnect
            @window.hide
          end
          @glade['button_cancel'].signal_connect('clicked') do
            @window.destroy         
          end

          #      @glade['config_window'].signal_connect('destroy') do
          #        debug "on destroy"
          #      end
      
          @glade['account'].signal_connect('close') do
            debug "on close"
            @window.destroy
          end
      
          @window.run
        end          
    end
  end
end
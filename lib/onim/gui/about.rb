module Onim
  class Gui
    # About window
    class About
      # Show window and load garfield image :]
      def initialize(gui)
        @gui = gui
        @glade = GladeXML.new(Onim::PATH+'gui/about.glade', nil, 'window_about')
        @window = @glade['window_about']
        @glade['button_ok'].signal_connect('clicked') { @window.hide }
        @window.modify_bg(Gtk::STATE_NORMAL,Gdk::Color.new(255*255, 255*255, 255*255))
        @image = @glade['image_about']
        @image.pixbuf = Gdk::Pixbuf.new(File.join(Onim::PATH,"gui","images","about.gif"))
        @window.show
      end
    end
  end
end
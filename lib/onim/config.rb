require 'yaml'
module Onim
  class Config
 
    def initialize(base)
      @base = base
      @config_file = File.join Onim.conf_dir, 'config.yml'
      unless File.exist? Onim.conf_dir
        Dir.mkdir Onim.conf_dir
      end
      @config = false
    end
  
    def get(key)    
      debug "getting key from config #{key}:::::#{config[key]}"
      config[key]
    end
  
    def set(key,value)
      debug "Setting config #{key}:::::#{value}"
      @@config = config # indeed, not so elegant
      @@config[key] = value
      File.open(@config_file,'w') { |f| f.write config.to_yaml }
    end
  
    def [](key)
      self.get(key)
    end

    def []=(key,value)
      self.set(key,value)
    end
  
    protected
  
    def config
      @@config ||= YAML.load_file(@config_file) || {} rescue {}
    end
    
    def debug(text)
      @base.debug("Congig: #{text}")
    end
  
  end

end
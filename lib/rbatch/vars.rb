require 'rbatch/run_conf'

module RBatch
  class Vars
    attr :opt,:run_conf,:tmp_opt
    def initialize
      @tmp_opt = {}
      @opt = {
        :program_name => $PROGRAM_NAME ,
        :program_path => File.expand_path($PROGRAM_NAME) ,
        :program_base => File.basename($PROGRAM_NAME),
        :date => Time.now.strftime("%Y%m%d"),
        :time => Time.now.strftime("%H%M%S"),
      }

      if ENV["RB_VERBOSE"]
        @opt[:journal_verbose] = ENV["RB_VERBOSE"].to_i
      else
        @opt[:journal_verbose] = 1
      end

      case RUBY_PLATFORM
      when /mswin|mingw/
        @opt[:host_name] =  ENV["COMPUTERNAME"] ? ENV["COMPUTERNAME"] : "unknownhost"
      when /cygwin|linux/
        @opt[:host_name] = ENV["HOSTNAME"] ? ENV["HOSTNAME"] : "unknownhost"
      else
        @opt[:host_name] = "unknownhost"
      end

      if  ENV["RB_HOME"]
        @opt[:home_dir] = File.expand_path(ENV["RB_HOME"])
      else
        @opt[:home_dir] = File.expand_path(File.join(File.dirname(@opt[:program_name]), ".."))
      end
      @opt[:run_conf_path] = File.join(@opt[:home_dir],".rbatchrc")
      @run_conf = RunConf.new(@opt[:run_conf_path]) # load run_conf
      @opt.merge!(@run_conf.opt)
      @opt[:common_config_path] = File.join(@opt[:conf_dir],@opt[:common_conf_name])
      @opt[:config_path] = File.join(@opt[:conf_dir],Pathname(File.basename(@opt[:program_name])).sub_ext(".yaml").to_s)
      replace_values
    end #end def

    def replace_values
      @opt.each_key do |key|
        if @opt[key].class == String
          @opt[key] = @opt[key]
            .gsub("<home>", @opt[:home_dir])
            .gsub("<date>", @opt[:date])
            .gsub("<time>", @opt[:time])
            .gsub("<prog>", @opt[:program_base])
            .gsub("<host>", @opt[:host_name])
        end
      end
    end
   
    def[](key)
      if @opt.has_key?(key)
        @opt[key]
      else
        raise RBatch::Vars::Exception, "no such key exist :" + key.to_s
      end
    end

    def add_tmp_opt(opt)
      @tmp_opt = opt
      @opt.merge()
      
    end

  end
  class RBatch::Vars::Exception < Exception ; end
end

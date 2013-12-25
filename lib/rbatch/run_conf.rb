require 'tmpdir'
module RBatch
  class RunConf
    attr :opt,:yaml
    @@def_opt = {
      :tmp_dir       => Dir.tmpdir,
      :forbid_double_run => false,
      :log_name      => "<date>_<time>_<prog>.log",
      :log_conf      => nil,
      :log_dir       => nil,
      :log_append    => true,
      :log_level     => "info",
      :log_stdout    => false,
      :log_quiet     => false,
      :log_delete_old_log => false,
      :log_delete_old_log_date => 7,
      :log_send_mail => false,
      :log_hostname => "unknownhost",
      :log_mail_to   => nil,
      :log_mail_from => "rbatch.localhost",
      :log_mail_server_host => "localhost",
      :log_mail_server_port => 25
    }

    def initialize(path)
      @opt = @@def_opt.clone

      case RUBY_PLATFORM
      when /mswin|mingw/
        @opt[:log_hostname] =  ENV["COMPUTERNAME"] ? ENV["COMPUTERNAME"] : "unknownhost"
      when /cygwin|linux/
        @opt[:log_hostname] = ENV["HOSTNAME"] ? ENV["HOSTNAME"] : "unknownhost"
      else
        @opt[:log_hostname] = "unknownhost"
      end

      @opt[:log_dir] = File.join(RBatch::home_dir , "log")
      @opt[:conf_dir] = File.join(RBatch::home_dir , "conf")

      begin
        @yaml = YAML::load_file(path)
        if @yaml
          @@def_opt.each_key do |key|
            if @yaml[key.to_s] != nil
              # use yaml
              @opt[key] = @yaml[key.to_s]
            else
              # use default
            end
          end
        end
      rescue
      end
    end

    def[](key)
      raise RBatch::RunConf::Exception, "Value of key=\"#{key}\" is nil" if @opt[key].nil?
      @opt[key]
    end
  end
  class RBatch::RunConf::Exception < Exception; end
end

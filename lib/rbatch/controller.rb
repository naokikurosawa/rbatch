require 'logger'
module RBatch
  class Controller
    attr :vars,:config,:common_config,:journals,:user_logs
    def initialize
      @vars = Vars.new()
      @journals = []
      @user_logs = []
      journal 1,"=== START RBatch === (PID=#{$$.to_s})"
      journal 1, "RB_HOME : \"#{@vars.home_dir}\""
      journal 1, "Load Run-Conf: \"#{@vars.run_conf_path}\""
      journal 2, "RBatch Variables : #{@vars.inspect}"
      @common_config = RBatch::Config.new(@vars.common_config_path)
      journal 1, "Load Config  : \"#{@vars.common_config_path}\"" if ! @common_config.nil?
      @config = RBatch::Config.new(@vars.config_path)
      journal 1, "Load Config  : \"#{@vars.config_path}\"" if ! @config.nil?
      # double_run_check
      if ( @vars.forbid_double_run )
        RBatch::DoubleRunChecker.check(@pvars.rogram_base) #raise error if check is NG
        RBatch::DoubleRunChecker.make_lock_file(@vars.program_base)
      end
      # load_lib
      if @run_conf[:auto_lib_load] && Dir.exist?(@vars.lib_dir)
        Dir::foreach(@vars.lib_dir) do |file|
          if /.*rb/ =~ file
            require File.join(@vars.lib_dir,File.basename(file,".rb"))
            journal 1, "Load Library : \"#{File.join(@vars.lib_dir,file)}\" "
          end
        end
      end
      journal 1, "Start Script : \"#{@vars.program_path}\""
    end #end def
    #
    def journal(level,str)
      if level <= @vars.journal_verbose
        str = "[RBatch] " + str
        puts str
        @journals << str
        @user_logs.each do |log|
          if @vars.mix_rbatch_journal_to_logs
            log.journal(str)
          end
        end
      end
    end
    #
  end
end

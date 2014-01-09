$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
require 'yaml'

module RBatch
  @@program_name = $PROGRAM_NAME
  @@program_base = File.basename($PROGRAM_NAME)
  @@home_dir = nil
  @@run_conf_path = nil
  @@run_conf = nil
  @@journal_verbose = 3
  @@journal_verbose_map = { :error => 1, :warn => 2, :info => 3, :debug => 4}
  module_function
  def program_name  ; @@program_name ; end
  def program_base  ; @@program_base ; end
  def home_dir      ; @@home_dir ; end
  def run_conf_path ; @@run_conf_path ; end
  def run_conf      ; @@run_conf ; end
  def conf_dir      ; @@run_conf[:conf_dir].gsub("<home>",@@home_dir) ; end
  def log_dir       ; @@run_conf[:log_dir].gsub("<home>",@@home_dir) ; end
  def lib_dir       ; @@run_conf[:lib_dir].gsub("<home>",@@home_dir) ; end
  def lib_dir_path  ; File.expand_path(lib_dir) ; end
  def journal(level,str)
    puts "[RBatch] " + str if @@journal_verbose_map[level] <= @@journal_verbose
  end
  def init
    @@journal_verbose = ENV["RB_VERBOSE"].to_i if ENV["RB_VERBOSE"]
    if  ENV["RB_HOME"]
      @@home_dir = ENV["RB_HOME"]
      RBatch.journal :info,"RB_HOME : \"#{@@home_dir}\" (defined by $RB_HOME)"
    else
      @@home_dir =  File.join(File.dirname(@@program_name) , "..")
      RBatch.journal :info,"RB_HOME : \"#{@@home_dir}\" (default)"
    end
    @@run_conf_path = File.join(@@home_dir,".rbatchrc")
    RBatch.journal :info,"Run-Conf: \"#{@@run_conf_path}\""

    @@run_conf = RunConf.new(@@run_conf_path,@@home_dir)
    RBatch.journal :debug,"RBatch option : #{@@run_conf.inspect}"
  end
end

# main
require 'rbatch/run_conf'
require 'rbatch/double_run_checker'

RBatch::init
if ( RBatch.run_conf[:forbid_double_run] )
  RBatch::DoubleRunChecker.check(File.basename(RBatch.program_name)) #raise error if check is NG
  RBatch::DoubleRunChecker.make_lock_file(File.basename(RBatch.program_name))
end

require 'rbatch/log'
require 'rbatch/config'
require 'rbatch/common_config'
require 'rbatch/cmd'


if RBatch.run_conf[:auto_lib_load] && Dir.exist?(RBatch.lib_dir)
  Dir::foreach(RBatch.lib_dir) do |file|
    if /.*rb/ =~ file
      require File.join(RBatch.lib_dir_path,File.basename(file,".rb"))
      RBatch.journal :info, "Load library \"#{File.join(RBatch.lib_dir,file)}\" "
    end
  end
end
RBatch.journal :info,"Start \"#{RBatch.program_name}\" under RBatch (PID=#{$$.to_s})"

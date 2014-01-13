require 'rbatch/vars'
require 'rbatch/log'
require 'tmpdir'

describe RBatch::Log do

  before :each do
    @home = File.join(Dir.tmpdir, "rbatch_test_" + rand.to_s)
    @log_dir = File.join(@home,"log")
    ENV["RB_HOME"]=@home
    ENV["RB_VERBOSE"]="0"

    Dir.mkdir(@home)
    Dir::mkdir(@log_dir)
    @vars = RBatch::Vars.new()
  end

  after :each do
    if Dir.exists? @log_dir
      Dir::foreach(@log_dir) do |f|
        File::delete(File.join(@log_dir , f)) if ! (/\.+$/ =~ f)
      end
    end
    Dir::rmdir(@log_dir)
    Dir::rmdir(@home)
    @vars = nil
  end

  it "is run" do
    RBatch::Log.new(@vars) do | log |
      log.info("test_log")
    end
    Dir::foreach(@log_dir) do |f|
      if ! (/\.+$/ =~ f)
        File::open(File.join(@log_dir , f)) {|f|
          expect(f.read).to match /test_log/
        }
      end
    end
  end

  it "raise error when log dir does not exist" do
    Dir::rmdir(@log_dir)
    expect{
      RBatch::Log.new(@vars) {|log|}
    }.to raise_error(RBatch::Log::Exception)
    Dir::mkdir(@log_dir)
  end

  it "run when log block is nested" do
    RBatch::Log.new(@vars,{:name => "name1" }) do | log |
      log.info("name1")
      RBatch::Log.new(@vars,{:name => "name2" }) do | log |
        log.info("name2")
      end
    end
    File::open(File.join(@log_dir,"name1")) {|f| expect(f.read).to match /name1/ }
    File::open(File.join(@log_dir,"name2")) {|f| expect(f.read).to match /name2/ }
  end

  describe "option by argument" do
    it "change log name" do
      RBatch::Log.new(@vars,{:name => "name1.log" }) do | log |
        log.info("hoge")
      end
      File::open(File.join(@log_dir , "name1.log")) {|f|
        expect(f.read).to match /hoge/
      }
    end

    it "change log name 2" do
      RBatch::Log.new(@vars,{:name => "<prog><date>name.log" }) do | log |
        log.info("hoge")
      end
      File::open(File.join(@log_dir ,  "rspec" + Time.now.strftime("%Y%m%d") + "name.log")) {|f|
        expect(f.read).to match /hoge/
      }
    end

   it "change log name 3" do
      RBatch::Log.new(@vars,{:name => "<prog>-<date>-name.log" }) do | log |
        log.info("hoge")
      end
      File::open(File.join(@log_dir ,  "rspec-" + Time.now.strftime("%Y%m%d") + "-name.log")) {|f|
        expect(f.read).to match /hoge/
      }
    end

    it "change log dir" do
      @tmp = File.join(ENV["RB_HOME"],"log3")
      Dir.mkdir(@tmp)
      RBatch::Log.new(@vars,{:name => "c.log", :dir=> @tmp }) do | log |
        log.info("hoge")
      end
      File::open(File.join(@tmp , "c.log")) {|f|
        expect(f.read).to match /hoge/
      }
      FileUtils.rm(File.join(@tmp , "c.log"))
      Dir.rmdir(@tmp)
    end

    it "is append mode" do
      RBatch::Log.new(@vars,{:append => true, :name =>  "a.log" }) do | log |
        log.info("line1")
      end
      RBatch::Log.new(@vars,{:append => true, :name =>  "a.log" }) do | log |
        log.info("line2")
      end
      File::open(File.join(@log_dir , "a.log")) {|f|
        str = f.read
        expect(str).to match /line1/
        expect(str).to match /line2/
      }
    end

    it "is overwrite mode" do
      RBatch::Log.new(@vars,{:append => false, :name =>  "a.log" }) do | log |
        log.info("line1")
      end
      RBatch::Log.new(@vars,{:append => false, :name =>  "a.log" }) do | log |
        log.info("line2")
      end
      File::open(File.join(@log_dir , "a.log")) {|f|
        str = f.read
        expect(str).to_not match /line1/
        expect(str).to match /line2/
      }
    end

    it "is debug level" do
      RBatch::Log.new(@vars,{ :level => "debug",:name =>  "a.log" }) do | log |
        log.debug("test_debug")
        log.info("test_info")
        log.warn("test_warn")
        log.error("test_error")
        log.fatal("test_fatal")
      end
      File::open(File.join(@log_dir , "a.log")) {|f|
        str = f.read
        expect(str).to match /test_debug/
        expect(str).to match /test_info/
        expect(str).to match /test_warn/
        expect(str).to match /test_error/
        expect(str).to match /test_fatal/
      }
    end

    it "is info level" do
      RBatch::Log.new(@vars,{ :level => "info",:name =>  "a.log" }) do | log |
        log.debug("test_debug")
        log.info("test_info")
        log.warn("test_warn")
        log.error("test_error")
        log.fatal("test_fatal")
      end
      File::open(File.join(@log_dir , "a.log")) {|f|
        str = f.read
        expect(str).to_not match /test_debug/
        expect(str).to match /test_info/
        expect(str).to match /test_warn/
        expect(str).to match /test_error/
        expect(str).to match /test_fatal/
      }
    end

    it "is warn level" do
      RBatch::Log.new(@vars,{ :level => "warn",:name =>  "a.log" }) do | log |
        log.debug("test_debug")
        log.info("test_info")
        log.warn("test_warn")
        log.error("test_error")
        log.fatal("test_fatal")
      end
      File::open(File.join(@log_dir , "a.log")) {|f|
        str = f.read
        expect(str).to_not match /test_debug/
        expect(str).to_not match /test_info/
        expect(str).to match /test_warn/
        expect(str).to match /test_error/
        expect(str).to match /test_fatal/
      }
    end

    it "is error level" do
      RBatch::Log.new(@vars,{ :level => "error",:name =>  "a.log" }) do | log |
        log.debug("test_debug")
        log.info("test_info")
        log.warn("test_warn")
        log.error("test_error")
        log.fatal("test_fatal")
      end
      File::open(File.join(@log_dir , "a.log")) {|f|
        str = f.read
        expect(str).to_not match /test_debug/
        expect(str).to_not match /test_info/
        expect(str).to_not match /test_warn/
        expect(str).to match /test_error/
        expect(str).to match /test_fatal/
      }
    end

    it "is fatal level" do
      RBatch::Log.new(@vars,{ :level => "fatal",:name =>  "a.log" }) do | log |
        log.debug("test_debug")
        log.info("test_info")
        log.warn("test_warn")
        log.error("test_error")
        log.fatal("test_fatal")
      end
      File::open(File.join(@log_dir , "a.log")) {|f|
        str = f.read
        expect(str).to_not match /test_debug/
        expect(str).to_not match /test_info/
        expect(str).to_not match /test_warn/
        expect(str).to_not match /test_error/
        expect(str).to match /test_fatal/
      }
    end

    it "is default level" do
      RBatch::Log.new(@vars,{ :name =>  "a.log" }) do | log |
        log.debug("test_debug")
        log.info("test_info")
        log.warn("test_warn")
        log.error("test_error")
        log.fatal("test_fatal")
      end
      File::open(File.join(@log_dir , "a.log")) {|f|
        str = f.read
        expect(str).to_not match /test_debug/
        expect(str).to match /test_info/
        expect(str).to match /test_warn/
        expect(str).to match /test_error/
        expect(str).to match /test_fatal/
      }
    end

    it "delete old log which name include <date>" do
      loglist = [*0..20].map do |day|
        File.join(@log_dir , (Date.today - day).strftime("%Y%m%d") + "_test_delete.log")
      end
      FileUtils.touch(loglist)
      log = RBatch::Log.new(@vars,{ :name =>  "<date>_test_delete.log",:delete_old_log => true})
      log.close
      loglist[1..6].each do |filename|
        expect(File.exists?(filename)).to be true
      end
      loglist[7..20].each do |filename|
        expect(File.exists?(filename)).to be false
      end
    end

    it "delete old log which name include <date> even if <date> position is changed" do
      loglist = [*0..20].map do |day|
        File.join(@log_dir , "235959-" + (Date.today - day).strftime("%Y%m%d") + "_test_delete.log")
      end
      FileUtils.touch(loglist)
      log = RBatch::Log.new(@vars,{ :name =>  "<time>-<date>_test_delete.log",:delete_old_log => true})
      log.close
      loglist[1..6].each do |filename|
        expect(File.exists?(filename)).to be true
      end
      loglist[7..20].each do |filename|
        expect(File.exists?(filename)).to be false
      end
    end

    it "does not delete old log which name does not include <date>" do
      log = RBatch::Log.new(@vars,{ :name =>  "test_delete.log",:delete_old_log => true})
      log.close
      expect(File.exists?(File.join(@log_dir,"test_delete.log"))).to be true
    end


  end

  describe "option by run_conf" do
    it "change log name" do
      @vars.merge!({:log_name => "name1.log"})
      RBatch::Log.new(@vars) do | log |
        log.info("hoge")
      end
      File::open(File.join(@log_dir , "name1.log")) {|f|
        expect(f.read).to match /hoge/
      }
    end

    it "change log dir" do
      @tmp = File.join(ENV["RB_HOME"],"log2")
      Dir.mkdir(@tmp)
      @vars.merge!({:log_dir => @tmp})
      RBatch::Log.new(@vars,{:name => "c.log" }) do | log |
        log.info("hoge")
      end
      File::open(File.join(@tmp , "c.log")) {|f|
        expect(f.read).to match /hoge/
      }
      FileUtils.rm(File.join(@tmp , "c.log"))
      Dir.rmdir(@tmp)
    end
  end
  describe "option both run_conf and opt" do
    it "change log name" do
      @vars.merge!({:log_name => "name1.log"})
      RBatch::Log.new(@vars,{:name => "name2.log"}) do | log |
        log.info("hoge")
      end
      File::open(File.join(@log_dir , "name2.log")) {|f|
        expect(f.read).to match /hoge/
      }
    end
  end
end

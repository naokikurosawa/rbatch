require 'tmpdir'
ENV["RB_HOME"]=Dir.tmpdir

require 'rbatch'

describe RBatch::RunConf do
  before :all do
    @config = File.join(Dir.tmpdir, ".rbatchrc")
  end

  before :each do
  end

  after :each do
    FileUtils.rm @config if File.exists? @config
  end

  after :all do
  end

  it "read config" do
    open( @config  , "w" ){|f| f.write("log_dir: hoge")}
    RBatch.reload_run_conf
    expect(RBatch.run_conf[:log_dir]).to eq "hoge"
  end
end

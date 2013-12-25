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

  it "is default when run_conf is empty" do
    expect(RBatch.run_conf[:log_dir]).to eq "log"
  end

  it "is default when run_conf does not exist" do
    FileUtils.rm @config if File.exists? @config
    expect(RBatch.run_conf[:log_dir]).to eq "log"
  end

  it "raise when key does not exist" do
    expect{RBatch.run_conf[:not_exist_key]}.to raise_error(RBatch::RunConf::Exception)
  end

  it "read run conf" do
    open( @config  , "w" ){|f| f.write("log_dir: hoge")}
    RBatch.reload_run_conf
    expect(RBatch.run_conf[:log_dir]).to eq "hoge"
  end

  it "raise when run_conf has unreserved words" do
    open( @config  , "w" ){|f| f.write("unreserved: hoge")}
    expect{RBatch.reload_run_conf}.to raise_error(RBatch::RunConf::Exception)
  end
end

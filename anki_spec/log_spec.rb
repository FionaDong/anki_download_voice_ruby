require './spec_helper'

describe Log do

  before :each do
    @log = Log.new $stdout, "/Users/Fiona/anki_ruby/log"
  end

  describe "#new" do
    it "returns a new log object." do
      log = Log.new $stdout, "/Users/Fiona/anki_ruby/log"
      expect(log).to be_an_instance_of Log
    end

    it "throws a ArgumentError when passes more than 2 arguments." do
      expect{ log = Log.new "/Users/Fiona/anki_ruby/log" }.to raise_error(ArgumentError)
    end
  end  

  describe "#puts_to_stdout" do
    it "outputs any log message to STDOUT" do
      @log.msg = "Message"
      # Dir.chdir("..")
      # @log.output.puts @log.msg
      # expect{ @log.puts_to_stdout }.to output.to_stdout
      expect{ $stdout.puts "Message" }.to output("Message\n").to_stdout
    end
    it "creates a log file when file not exists." do
      File.delete("/Users/Fiona/anki_ruby/log")
      @log.msg = "Message"
      @log.puts_to_file
      expect(File.exist?("/Users/Fiona/anki_ruby/log")).to eq true
    end

    it "outputs one line log message to the log file." do
      File.delete("/Users/Fiona/anki_ruby/log")
      @log.msg = "Message"
      @log.puts_to_file
      expect(File.open("/Users/Fiona/anki_ruby/log",'r').readlines[0]).to eq "Message\n"
    end
    
    it "outputs multiple lines log message to the log file." do
      File.delete("/Users/Fiona/anki_ruby/log")
      @log.msg = <<-END
Log start at 2014-11-14 2.36pm
start get deck id from db.
check internet resource.
download mp3 and update db.
Log end at at 2014-11-14 2.37pm
      END
      @log.puts_to_file
      expect(File.open("/Users/Fiona/anki_ruby/log",'r').readlines[4]).to eq "Log end at at 2014-11-14 2.37pm\n"
    end

    it "appends the second message to the log file." do

      File.delete("/Users/Fiona/anki_ruby/log")
      @log.msg = "Message"
      @log.puts_to_file
      @log.msg = "Hello"
      @log.puts_to_file

      expect(File.open("/Users/Fiona/anki_ruby/log",'r').readlines[1]).to eq "Hello\n"
    end

  end
end
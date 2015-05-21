# require 'pry'
class Log
  attr_accessor :msg, :output

  def initialize(output, log_file)
    @output = output
    @log_file = log_file
    @msg = ""
  end

  def puts(msg)
    @msg = msg
    puts_to_stdout
    puts_to_file
  end

  def puts_to_stdout
    @output.puts @msg
  end

  def puts_to_file
      File.open(@log_file, "a") do |f|
      f.puts @msg
    end     
  end

end
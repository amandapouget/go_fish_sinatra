require 'socket'

class MockClient
  attr_reader :socket

  def initialize
    @my_output = ""
  end

  def start
    @socket = TCPSocket.open('localhost', 2000)
  end

  def provide_input(text)
    @socket.puts(text)
  end

  def capture_output(delay=0.1)
    sleep(delay)
    @my_output += @socket.read_nonblock(1000)
  rescue IO::WaitReadable
    @my_output += ""
  end

  def output
    capture_output
    @my_output
  end

  def erase_output
    @my_output = ""
  end
end

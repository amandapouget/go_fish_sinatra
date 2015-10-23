require './lib/server.rb'

def get_input
  begin
    client.read_nonblock(1000).chomp
  rescue IO::WaitReadable
    IO.select([client])
    retry
  rescue IOError
    return nil
  end
end

server = Server.new()
server.start
running = Thread.new { server.make_threads }
server.stop_server if gets.chomp == "stop"

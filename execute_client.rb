require './lib/client.rb'

def over?
  @client.socket.closed?
end

@client = Client.new
@client.start

putsing = Thread.new {
  loop do
    sleep 0.1
    @client.puts_message
  end
}

getsing = Thread.new {
  loop do
    sleep 0.1
    input = read_nonblock(1000)
    @client.provide_input(input)
  end
}

loop do
  Thread.kill(putsing) if over?
  Thread.kill(getsing) if over?
end

puts "STARTED"
puts @client.socket.is_a? TCPSocket

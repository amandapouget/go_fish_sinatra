require './lib/client.rb'

def over?
  @client.socket.closed?
end

@client = Client.new
@client.start

loop do
  @client.puts_message
  @client.give_input_when_asked
end

require 'spec_helper'

describe Client do
  let(:client) { Client.new }
  let(:client2) { Client.new }
  let(:server) { Server.new }

  def capture_stdout(&blk)
    old = $stdout
    $stdout = fake = StringIO.new
    blk.call
    fake.string
  ensure
    $stdout = old
  end

  it 'does nothing when initialized' do
    expect { client }.to_not raise_exception
  end

  it '#start tries to connect to the server, with new socket attribute' do
    begin
      client.start
    rescue => e
      expect(e.message).to match(/connection refused/i)
    end
  end

  context 'server and client started, connection accepted,' do
    before do
      server.start
      client.start
      @client_socket = server.accept
    end

    after do
      server.stop_server
    end

    it '#start when it successfully connects, gets a welcome message back from the server' do
      expect { client.socket.read_nonblock(1000) }.to_not raise_exception
    end

    it 'puts the welcome message to the client' do
      putted = capture_stdout { client.puts_message }
      expect(putted).to match /.+/
    end

    it 'provides input' do
      client.provide_input("yes")
      expect(server.get_input(@client_socket)).to eq "yes"
    end
  end

  context 'second user is connected and game is in progress' do
    before do
      server.start
      client.start
      client2.start
      @client_socket = server.socket.accept
      @client2_socket = server.socket.accept
      @match = (Match.new(game: Game.new, user1: User.new(name: "Amanda", client: @client_socket), user2: User.new(name: "Vianney", client: @client2_socket)))
      @match.game.deal
    end

    after do
      server.stop_server
    end

    it 'interprets json and prints match state' do
      server.tell_match(@match)
      putted = capture_stdout { client.puts_message }
      expect(putted).to include "cards left to fish for."
    end

    it 'interprets json and prints player state correctly' do
      server.tell_player(@match, @match.user1)
      putted = capture_stdout { client.puts_message }
      expect(putted).to include "Amanda, you have"
    end

    it 'turns an array of card strings into a simple string' do
      expect(client.seriesify(["one", "two", "three"])).to eq "one, two and three"
    end
  end
end

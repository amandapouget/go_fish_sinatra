require 'spec_helper'

def capture_stdout(&block)
  old = $stdout
  $stdout = fake = StringIO.new
  block.call
  fake.string
ensure
  $stdout = old
end

def start_server_with_clients_and_users
  @server = Server.new.tap { |server| server.start }
  @clients = Array.new(3) { MockClient.new.tap { |client| client.start } }
  @client_sockets = Array.new(3) { @server.accept }
  @users = Array.new(3) { |index| create(:real_user, client: @client_sockets[index]) }
  @clients.each { |client| client.erase_output }
end

describe Server do
  context 'create server' do
    let(:server) { Server.new }
    let(:clients) { Array.new(3) { MockClient.new } }

    describe '#initialize' do
      it 'creates a Server on a default port' do
        expect(server.port).to eq 2000
      end

      it 'is not listening when it is created' do
        begin
          clients[0].start
        rescue => e
          expect(e.message).to match(/connection refused/i)
        end
      end
    end

    context 'server started' do
      before { server.start }
      after { server.stop }

      describe '#start' do
        it 'starts the server by giving it a TCP server and arrays of pending_users and clients' do
          expect(server.socket).to be_a TCPServer
          expect(server.pending_users).to eq []
          expect(server.clients).to eq []
        end

        it 'is listening when started and allows a client to connect' do
          expect{ clients[0].start }.to_not raise_exception
        end

        it 'when started, allows multiple clients to connect at once' do
          clients.each { |client| expect { client.start }.to_not raise_exception }
        end
      end

      describe '#accept' do
        it 'accepts clients, adds them to its clients array and welcomes them' do
          clients[0..1].each_with_index do |client, index|
            client.start
            expect(server.accept).to eq server.clients[index]
            expect(client.output).to include Server::WELCOME
          end
        end
      end
    end
  end

  context 'two clients are accepted and users connected to clients exist' do
    before(:all) { start_server_with_clients_and_users }
    after(:all) { @server.stop }
    after do
      @clients.each { |client| client.erase_output }
      @server.pending_users = []
    end

    describe '#get_info' do
      it 'delivers a message and takes client input' do
        failures = []
        2.times do |time| # run this 10000 times to expose an intermittant timing issue
          @clients[0].provide_input("123")
          id = @server.get_info(@client_sockets[0], Server::ENTER_ID, 0.00001).to_i
          failures << time if id != 123
        end
        expect(failures).to eq []
        expect(@clients[0].output).to include Server::ENTER_ID
      end
    end

    describe '#match_user' do
      it 'returns a user based on id if a good user id # is given, and sets the user.client to the clients[0]_socket' do
        found_user = @server.match_user(@client_sockets[1], @users[0].id)
        expect(found_user).to eq @users[0]
        expect(found_user.client).to be_a TCPSocket
      end

      it 'returns a new user with name if no good user id # is given and tells the client its user id, and sets the user.client to the clients[0]_socket' do
        @clients[0].provide_input("Jane")
        created_user = @server.match_user(@client_sockets[0], 0)
        expect(created_user).to be_a User
        expect(created_user.client).to be_a TCPSocket
        expect(@clients[0].output).to include "Your unique id is" # how to make this a constant? (had variable in it...)
      end
    end

    describe '#add_user' do
      it 'adds a user to @pending_users if the user does not have a match in progress' do
        @server.add_user(@users[2].client, @users[2].id)
        expect(@server.pending_users).to include @users[2]
      end

      it 'does not add a user to @pending_users if the user does have a match in progress' do
        only_match_in_progress = Match.create(users: [@users[0], @users[1]])
        @server.add_user(@users[0].client, @users[0].id)
        expect(@server.pending_users).not_to include(@users[0]) && include(@users[1])
      end
    end

    describe '#enough_players?' do
      it 'returns false when 0 - 1 users are waiting to join a game' do
        expect(@server.enough_players?).to be false
        @server.pending_users << @users[0]
        expect(@server.enough_players?).to be false
      end
      it 'returns true when two or more users are waiting to join a game' do
        @users[0..1].each { |user| @server.pending_users << user }
        expect(@server.enough_players?).to be true
        @server.pending_users << @users[2]
        expect(@server.enough_players?).to be true
      end
    end

    describe '#make_match' do
      it 'takes two users and starts a match with those users' do
        match = @server.make_match(@users)
        expect(match).to be_a Match
        @users.each do |user|
          expect(match.users).to include user
          expect(Match.find_by_id(user.current_match)).to eq match
        end
      end
    end
  end

  context 'managing connections gracefully after game play starts' do
    before { start_server_with_clients_and_users }
    after { @server.stop }

    describe 'find_client' do
      it 'rejoins a lost user to the game it was in before it was disconnected' do
        @match = @server.make_match(@users)
        @server.stop_connection(@client_sockets[1])
        @clients[1].start
        @client_sockets[1] = @server.accept
        @server.match_user(@client_sockets[1], @users[1].id)
        @server.send_output(@match.users[1].client, "Reconnected!")
        expect(@clients[1].capture_output).to include "Reconnected!"
      end
    end

    describe '#stop_connection' do
      it 'closes the client connection to the server and removes the connection from clients' do
        @server.stop_connection(@client_sockets[1] )
        expect(@client_sockets[1].closed?).to be true
        expect(@server.clients.include?(@client_sockets[1])).to be false
      end
    end

    describe '#stop' do
      it 'closes all the connections in clients, empties clients and pending_users, and closes the server socket' do
        @users.each { |user| @server.pending_users << user }
        @server.stop
        @client_sockets.each { |socket| expect(socket.closed?).to be true }
        expect(@server.clients).to eq []
        expect(@server.pending_users).to eq []
        expect(@server.socket.closed?).to be true
      end
    end
  end

  context 'match is made but players have no cards' do
    before(:all) { start_server_with_clients_and_users }
    after(:all) { @server.stop }
    before { @match = @server.make_match(@users) }
    after { @clients.each { |client| client.erase_output } }

    describe '#play_match' do
      it 'plays the game until over and ends the match' do
        expect(@match.over).to be false
        @server.play_match(@match)
        expect(@match.over).to be true
      end
    end

    context 'players each have one card to play a round' do
      before { @match.players.each { |player| player.add_card(build(:card)) } }

      describe '#play_move, #play_fish' do
        it 'it asks a player for a rank to request' do
          @clients[0].provide_input("two")
          rank = @server.get_rank(@match, @users[0])
          expect(@clients[0].output).to include Server::RANK_REQUEST
          expect(rank).to eq "two"
        end

        it 'asks him for a player to request cards from' do
          @clients[0].provide_input("#{@users[1].name}")
          opponent = @server.get_opponent(@match, @users[0])
          expect(@clients[0].output).to include Server::OPPONENT_REQUEST
          expect(opponent).to eq @users[1]
        end

        it 'tells the player he must go fish, waits for input, then makes the player go fish and then tells him what he drew' do
          user = @match.users[2]
          player = @match.player(user)
          count = player.count_cards
          @clients[2].provide_input("\n")
          @server.play_fish(@match, user, "any rank")
          expect(player.count_cards).to eq count + 1
          expect(@clients[2].output).to include(Server::GO_FISH) && include("You drew")
        end
      end

      describe '#tell_fish' do
        it 'announces someone went fish' do
          @server.tell_fish(@match, @users[0])
          expect(@clients[rand(3)].output).to include "#{@users[0].name} went fish!"
        end
      end

      describe '#tell_request' do
        it 'announces one players rank and opponent request to all players' do
          @server.tell_request(@match, "two", @users[0], @users[1])
          expect(@clients[rand(3)].output).to include "#{@users[0].name} requested every two in #{@users[1].name}'s hand!"
        end
      end

      describe '#tell_winnings' do
        it 'tells the player what he won' do
          card = build(:card_as)
          @server.tell_winnings(@match, @users[0], [card])
          expect(@clients[0].output).to include card.to_s
        end
      end

      describe '#tell_player_his_view' do
        it 'tells a player about the match from his point of view (message, cards, books, etc)' do
          @server.tell_player_his_view(@match, @users[0])
          expect(@clients[0].output).to include @match.view(@match.player(@users[0]))
        end
      end

      describe '#tell_match' do
        it 'tells every player about the match from his point of view (message, cards, books, etc)' do
          @clients.each { |client| client.erase_output until client.output == "" }
          @server.tell_match(@match)
          num = rand(3)
          output = @clients[num].output
          view = @match.view(@match.player(@users[num]))
          expect(output).to include view
        end
      end
    end
  end
end

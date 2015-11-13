require 'spec_helper'

def capture_stdout(&block)
  old = $stdout
  $stdout = fake = StringIO.new
  block.call
  fake.string
ensure
  $stdout = old
end

describe Server do
  context 'create server' do
    let(:server) { Server.new }
    let(:client0) { MockClient.new() }
    let(:client1) { MockClient.new() }
    let(:client2) { MockClient.new() }
    let(:clients) { [client0, client1, client2] }

    after do
      client0.erase_output
      client1.erase_output
      client2.erase_output
    end

    describe '#initialize' do
      it 'creates a Server on a default port' do
        expect(server).to be_a Server
        expect(server.port).to eq 2000
      end

      it 'is not listening when it is created' do
        begin
          client0.start
        rescue => e
          expect(e.message).to match(/connection refused/i)
        end
      end
    end

    context 'server started' do
      before do
        server.start
      end

      after do
        server.stop
      end

      describe '#start' do
        it 'starts the server by giving it a TCP server and arrays of pending_users and clients' do
          expect(server.socket).to be_a TCPServer
          expect(server.pending_users).to eq []
          expect(server.clients).to eq []
        end

        it 'is listening when started and connects to a client' do
          expect{ client0.start }.to_not raise_exception
        end

        it 'when started, connects to multiple clients at once' do
          client0.start
          expect{ client1.start }.to_not raise_exception
        end
      end

      context 'two clients are started' do
        before do
          client0.start
          client1.start
          client2.start
        end

        describe '#accept' do
          it 'accepts the client and welcomes the player' do
            server.accept
            expect(client0.output).to include Server::WELCOME
          end

          it 'accepts multiple clients and welcomes them' do
            server.accept
            expect(client0.output).to include Server::WELCOME
            server.accept
            expect(client1.output).to include Server::WELCOME
            server.accept
            expect(client2.output).to include Server::WELCOME
          end

          it 'adds the client to clients' do
            client0_socket = server.accept
            expect(server.clients[0]).to eq client0_socket
          end
        end

        context 'two clients are accepted and users connected to clients exist' do
          let(:user0) { build(:user, client: @client0_socket) }
          let(:user1) { build(:user, client: @client1_socket) }
          let(:user2) { build(:user, client: @client2_socket) }
          let(:users) { [user0, user1, user2] }
          let(:client_sockets) { [@client0_socket, @client1_socket, @client2_socket] }

          before do
            @client0_socket = server.accept
            @client1_socket = server.accept
            @client2_socket = server.accept
          end

          describe '#get_id' do
            it 'asks for a unique id and takes client input' do
              failures = []
              2.times do |time|
                client0.provide_input("123")
                id = server.get_id(@client0_socket, 0.00001)
                failures << time if id != 123
              end
              expect(failures).to eq []
              expect(client0.output).to include Server::ENTER_ID
            end
          end

          describe '#get_name' do
            it 'asks the client for the players name and returns it as a string' do
              failures = []
              2.times do |time|
                client0.provide_input("Amanda")
                name = server.get_name(@client0_socket, 0.00001)
                failures << time if name != "Amanda"
              end
              expect(failures).to eq []
              expect(client0.output).to include Server::ASK_NAME
            end
          end

          describe '#match_user' do
            it 'returns a user based on id if a good user id # is given' do
              expect(server.match_user(@client1_socket, user0.object_id)).to eq user0
            end

            it 'returns a new user with name if no good user id # is given and tells the client its user id' do
              client0.provide_input("Jane")
              expect(server.match_user(@client0_socket, 0)).to be_a User
              expect(client0.output).to include "Your unique id is" # how to make this a constant? (had variable in it...)
            end

            it 'in both cases, sets the user.client to the client0_socket' do
              client0.provide_input("Jane")
              created_user = server.match_user(@client0_socket, 0)
              found_user = server.match_user(@client1_socket, user1.object_id)
              expect(created_user.client).to be_a TCPSocket
              expect(found_user.client).to be_a TCPSocket
            end
          end

          describe '#add_user' do
            before { only_match_in_progress = Match.new([user0, user1]) }

            it 'adds a user to @pending_users if the user does not have a match in progress' do
              server.add_user(user2.client, user2.object_id)
              expect(server.pending_users.length).to eq 1
            end

            it 'does not add a user to @pending_users if the user does have a match in progress' do
              server.add_user(user0.client, user0.object_id)
              expect(server.pending_users.length).to eq 0
            end
          end

          describe '#enough_players?' do
            it 'returns false when 0 - 1 users are waiting to join a game' do
              expect(server.enough_players?).to be false
              server.pending_users << user0
              expect(server.enough_players?).to be false
            end
            it 'returns true when two or more users are waiting to join a game' do
              server.pending_users << user0
              server.pending_users << user1
              expect(server.enough_players?).to be true
              server.pending_users << user2
              expect(server.enough_players?).to be true
            end

            it 'returns false when there are less than two users waiting to join a game' do
              expect(server.enough_players?).to be false
              server.pending_users << user0
              expect(server.enough_players?).to be false
            end
          end

          describe '#make_match' do
            it 'takes two users and returns a match object with an a Game and Players corresponding to the users' do
              match = server.make_match(users)
              expect(match).to be_a Match
              expect(match.game.players).to eq match.players
              users.each do |user|
                player = match.player(user)
                expect(match.user(player)).to eq user
              end
            end

            it 'changes the users current_match to this match' do
              match = server.make_match(users)
              users.each { |user| expect(Match.find(user.current_match)).to eq match }
            end
          end

          context 'match is made' do
            let(:match) { server.make_match(users) }

            describe '#ask_to_start_match' do
              it 'asks the clients to hit enter to play' do
                clients.each { |client| client.provide_input("\n") }
                server.ask_to_start_match(match)
                clients.each { |client| expect(client.output).to include Server::START_GAME }
              end
            end

            describe '#play_match' do
              it 'plays the game until over and ends the match' do
                expect(match.over).to be false
                clients.each { |client| client.provide_input("\n") }
                server.play_match(match)
                expect(match.game.game_over?).to be true
                expect(match.over).to be true
              end
            end

            context 'players each one have one card to play a round' do
              before do
                match.players.each { |player| player.add_card(match.game.deck.deal_next_card) }
              end

              describe '#play_move, #play_fish' do
                it 'it asks a player for a rank to request' do
                  client0.provide_input("two")
                  rank = server.get_rank(match, user0)
                  expect(client0.output).to include Server::RANK_REQUEST
                  expect(rank).to eq "two"
                end

                it 'asks him for a player to request cards from' do
                  client0.provide_input("#{user1.name}")
                  opponent = server.get_opponent(match, user0)
                  expect(client0.output).to include Server::OPPONENT_REQUEST
                  expect(opponent).to eq user1
                end

                it 'tells the player he must go fish, waits for input, then makes the player go fish and then tells him what he drew' do
                  count = match.players[2].count_cards
                  client2.provide_input("\n")
                  server.play_fish(match, user2, "any rank")
                  expect(match.players[2].count_cards).to eq count + 1
                  expect(client2.output).to include Server::GO_FISH
                  expect(client2.output).to include "You drew"
                end
              end

              describe 'find_client' do
                it 'rejoins a lost user to the game it was in before it was disconnected' do
                  server.stop_connection(@client1_socket)
                  client1.start
                  new_socket = server.accept
                  server.match_user(new_socket, user1.object_id)
                  server.send_output(match.users[1].client, "Reconnected!")
                  expect(client1.capture_output).to include "Reconnected!"
                end
              end
            end

            describe '#tell_fish' do
              it 'announces someone went fish' do
                server.tell_fish(match, users[0])
                clients.each { |client| expect(client.output).to include "#{users[0].name} went fish!" }
              end
            end

            describe '#tell_request' do
              it 'announces one players rank and opponent request to all players' do
                server.tell_request(match, "two", users[0], users[1])
                clients.each { |client| expect(client.output).to include "#{users[0].name} requested every two in #{users[1].name}'s hand!" }
              end
            end

            describe '#tell_winnings' do
              it 'tells the player what he won' do
                card = build(:card_as)
                server.tell_winnings(match, user0, [card])
                expect(client0.output).to include "You received:"
                expect(client0.output).to include card.to_s
              end
            end

            describe '#tell_player_his_hand' do
              it 'tells a player his own current state (cards, books, etc)' do
                server.tell_player_his_hand(match, user0)
                expect(client0.output).to include JSON.dump(match.json_ready(user0))
              end
            end

            describe '#tell_match' do
              it 'sends all match clients a json hash with info about the match' do
                server.tell_match(match)
                clients.each { |client| expect(client.output).to include JSON.dump(match.json_ready) }
              end
            end

            describe '#stop_connection' do
              it 'closes the client connection to the server unless socket already closed' do
                client_sockets.each do |socket|
                  expect(socket.closed?).to be false
                  server.stop_connection(socket)
                  expect(socket.closed?).to be true
                end
              end

              it 'removes the connection from clients if it is in clients' do
                client_sockets.each do |socket|
                  expect(server.clients.include?(socket)).to be true
                  server.stop_connection(socket)
                  expect(server.clients.include?(socket)).to be false
                end
              end
            end

            describe '#stop' do
              it 'closes all the connections in clients and removes them from clients' do
                server.stop
                client_sockets.each { |socket| expect(socket.closed?).to be true }
                expect(server.clients.length).to eq 0
              end

              it 'removes all the pending users' do
                users.each { |user| server.pending_users << user }
                server.stop
                expect(server.pending_users).to eq []
              end

              it 'closes the server socket' do
                server.stop
                expect(server.socket.closed?).to be true
              end
            end
          end
        end
      end
    end
  end
end

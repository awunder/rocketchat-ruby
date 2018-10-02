require 'spec_helper'

describe RocketChat::Messages::Channel do
  include_examples 'room_behavior', room_type: 'c', query: true

  describe '#join' do
    before do
      # Stubs for /api/v1/channels.join REST API
      stub_unauthed_request :post, '/api/v1/channels.join'

      stub_authed_request(:post, '/api/v1/channels.join')
        .to_return(not_provided_room_body)

      stub_authed_request(:post, '/api/v1/channels.join')
        .with(
          body: { roomName: 'missing-room' }
        ).to_return(invalid_room_body)

      stub_authed_request(:post, '/api/v1/channels.join')
        .with(
          body: { roomName: 'a-room' }.to_json
        ).to_return(
          body: { success: true }.to_json,
          status: 200
        )
    end

    context 'valid session' do
      it 'should be success' do
        expect(scope.join(name: 'a-room')).to be_truthy
      end

      context 'about a missing room' do
        it 'should raise an error' do
          expect do
            scope.join(name: 'missing-room')
          end.to raise_error(
            RocketChat::StatusError,
            'The required "roomId" or "roomName" param provided does not match any channel [error-room-not-found]'
          )
        end
      end
    end

    context 'invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, roomId: nil) }

      it 'should be failure' do
        expect do
          scope.join(name: 'a-room')
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end

  describe '#online' do
    let(:online_users_request) do
      {
        body: {
          success: true,
          online: [
            {
              _id: 'rocketID1',
              username: 'rocketUserName1'
            },
            {
              _id: 'rocketID2',
              username: 'rocketUserName2'
            }
          ]
        }.to_json,
        status: 200
      }
    end

    let(:invalid_room_body) do
      {
        body: {
          success: false,
          error: 'That Channel does not exist.'
        }.to_json,
        status: 200
      }
    end

    before do
      # Stubs for /api/v1/channels.online REST API
      stub_unauthed_request :get, described_class.api_path('online')

      stub_authed_request(:get, described_class.api_path('online?roomName=wrong-room'))
        .to_return(invalid_room_body)

      stub_authed_request(:get, described_class.api_path('online?roomName=room-one'))
        .to_return(online_users_request)
    end

    context 'valid session' do
      context 'online users request with an invalid room name' do
        it 'return no users' do
          expect do
            scope.online(name: 'wrong-room')
          end.to raise_error RocketChat::StatusError, 'That Channel does not exist.'
        end
      end

      it 'return online users' do
        online_users = scope.online(name: 'room-one')

        expect(online_users.length).to eq 2
        expect(online_users[0].id).to eq 'rocketID1'
        expect(online_users[0].username).to eq 'rocketUserName1'
        expect(online_users[1].id).to eq 'rocketID2'
        expect(online_users[1].username).to eq 'rocketUserName2'
      end
    end

    context 'invalid session token' do
      let(:token) { RocketChat::Token.new(authToken: nil, groupId: nil) }

      it 'failure' do
        expect do
          scope.online
        end.to raise_error RocketChat::StatusError, 'You must be logged in to do this.'
      end
    end
  end
end

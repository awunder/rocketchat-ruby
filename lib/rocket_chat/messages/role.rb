module RocketChat
  module Messages
    #
    # Rocket.Chat User messages
    #
    class Role
      include ListSupport

      #
      # @param [Session] session Session
      #
      def initialize(session)
        @session = session
      end

      #
      # roles.create REST API
      # @param [String] name Name
      # @param [String] scope Scope
      # @param [String] description Description
      # @return [Role]
      # @raise [HTTPError, StatusError]
      #
      def create(name, scope, description)
        response = session.request_json(
          '/api/v1/roles.create',
          method: :post,
          body: {
            name: name,
            scope: scope,
            description: description
          }
        )
        RocketChat::Role.new response['role']
      end


      private

      attr_reader :session
    end
  end
end

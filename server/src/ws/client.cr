module MyServer
  module WS
    class Client
      property socket : HTTP::WebSocket
      property user_id : String

      def initialize(@socket, @user_id)
      end

      def send_message(msg)
        @socket.send(msg)
      end
    end
  end
end

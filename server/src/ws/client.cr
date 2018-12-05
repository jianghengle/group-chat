module MyServer
  module WS
    class Client
      property socket : HTTP::WebSocket
      property user_id : String
      property last_active : Time

      def initialize(@socket, @user_id)
        @last_active = Time.now
      end

      def send_message(msg)
        begin
          span = Time.now - @last_active
          if span.total_seconds > 100
            puts "socket expired"
            ClientStore.remove_client(@socket)
            @socket.close
          else
            @socket.send(msg)
          end
        rescue
          puts "failed to send or close socket"
        end
      end

      def update_last_active
        @last_active = Time.now
      end
    end
  end
end

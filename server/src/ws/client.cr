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
          raise "last active expired" if span.total_seconds > 100
          @socket.send(msg)
        rescue e : Exception
          puts "close socket"
          puts e.message.to_s
          @socket.close
        end
      end

      def update_last_active
        @last_active = Time.now
      end
    end
  end
end

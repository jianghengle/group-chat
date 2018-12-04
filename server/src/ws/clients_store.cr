module MyServer
  module WS
    class ClientStore
      @@socket_client = {} of UInt64 => Client
      @@user_clients = {} of String => Array(Client)

      def self.add_client(socket, env)
        return false unless env.params.query.has_key?("token")
        token = env.params.query["token"].to_s
        user = Repo.get_by(MyServer::HttpAPI::User, auth_token: token)
        return false if user.nil?
        user_id = user.id.to_s
        client = Client.new(socket, user_id)
        @@socket_client[socket.object_id] = client
        @@user_clients[user_id] = [] of Client unless @@user_clients.has_key?(user_id)
        @@user_clients[user_id] << client
        puts "add"
        puts @@socket_client.keys
        puts @@user_clients.keys
        true
      end

      def self.remove_client(socket)
        return unless @@socket_client.has_key?(socket.object_id)
        client = @@socket_client[socket.object_id]
        @@socket_client.delete(socket.object_id)

        return unless @@user_clients.has_key?(client.user_id)
        clients = @@user_clients[client.user_id]
        clients.delete(client)
        @@user_clients.delete(client.user_id) if clients.empty?

        puts "remove"
        puts @@socket_client.keys
        puts @@user_clients.keys
      end

      def self.update_client(socket)
        return unless @@socket_client.has_key?(socket.object_id)
        client = @@socket_client[socket.object_id]
        client.update_last_active
      end

      def self.broadcast_message(user_ids, msg)
        user_ids.each do |user_id|
          next unless @@user_clients.has_key? user_id
          clients = @@user_clients[user_id]
          clients.each do |client|
            client.send_message(msg)
          end
        end
      end

      def self.pull_group(group_id, user_ids = [] of String)
        if user_ids.empty?
          memberships = MyServer::HttpAPI::Membership.get_memberships_by_group_id(group_id)
          user_ids = memberships.map { |m| m.user_id.to_s }
        end
        message = ["pullGroup", group_id.to_s].to_json
        MyServer::WS::ClientStore.broadcast_message(user_ids, message)
      end
    end
  end
end

module MyServer
  module HttpAPI
    class User < Crecto::Model
      schema "users" do
        field :email, String
        field :encrypted_password, String
        field :auth_token, String
        field :role, String
        field :full_name, String
      end

      def to_json(with_token = false)
        String.build do |str|
          str << "{"
          str << "\"id\":" << @id << ","
          str << "\"token\":" << @auth_token.to_json << "," if with_token
          str << "\"email\":" << @email.to_json << ","
          str << "\"fullName\":" << @full_name.to_json
          str << "}"
        end
      end

      def self.get_user(email : String, password : String)
        user = Repo.get_by(User, email: email)
        raise "Cannot find user" if user.nil?
        raise "Cannot verify password" unless Crypto::Bcrypt::Password.new(user.encrypted_password.not_nil!) == password
        user
      end

      def self.get_user_by_token(token : String)
        user = Repo.get_by(User, auth_token: token)
        raise "Cannot find user" if user.nil?
        user
      end

      def self.get_users_by_ids(ids)
        return [] of User if ids.empty?
        query = Query.where(:id, ids)
        items = Repo.all(User, query)
        return [] of User if items.nil?
        items.as(Array)
      end

      def self.get_user_by_id(id)
        user = Repo.get(User, id)
        raise "Cannot find user" if user.nil?
        user
      end

      def self.get_name_map(ids)
        result = {} of String => String
        query = Query.where(:id, ids)
        items = Repo.all(User, query)
        return result if items.nil?
        items.as(Array).each do |i|
          result[i.id.to_s] = i.full_name.to_s
        end
        result
      end
    end
  end
end

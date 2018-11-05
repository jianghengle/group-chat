module MyServer
  module HttpAPI
    class User < Crecto::Model
      schema "users" do
        field :email, String
        field :encrypted_password, String
        field :auth_token, String
        field :role, String
        field :first_name, String
        field :last_name, String
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
    end
  end
end

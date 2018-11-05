require "./controller_base"

module MyServer
  module HttpAPI
    module UserController
      include MyServer::HttpAPI::ControllerBase
      extend self

      def get_auth_token(ctx)
        begin
          email = get_param!(ctx, "email")
          password = get_param!(ctx, "password")

          user = User.get_user(email, password)
          token = user.auth_token.to_s
          email = user.email.to_s
          first_name = user.first_name.to_s
          {token: token, email: email, firstName: first_name}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end
    end
  end
end

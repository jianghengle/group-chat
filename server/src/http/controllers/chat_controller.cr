require "./controller_base"

module MyServer
  module HttpAPI
    module ChatController
      include MyServer::HttpAPI::ControllerBase
      extend self

      def get_group_chats(ctx)
        begin
          user = verify_token(ctx)
          group_id = get_param!(ctx, "group_id").to_i
          group = Group.get_group_by_id(group_id)
          user_ids = [] of String
          raise "not in the group" unless user_ids.includes? (user.id.to_s)

          chats = Chat.get_chats_by_group(group)
          attachment_keys = chats.map { |c| c.attachment_key.nil? ? "" : c.attachment_key.to_s }
          attachment_map = Attachment.get_attachment_map(attachment_keys)
          chats_json = chats.join(",") do |c|
            if c.attachment_key.nil?
              c.to_json
            else
              if attachment_map.has_key?(c.attachment_key.to_s)
                attachment = attachment_map[c.attachment_key.to_s]
                c.to_json attachment.filename.to_s
              else
                c.to_json
              end
            end
          end
          chats_json = "[" + chats_json + "]"
          user_ids = chats.map { |c| c.user_id }
          users = User.get_users_by_ids(user_ids)
          users_json = "[" + users.join(", ") { |u| u.to_json } + "]"
          "[#{chats_json}, #{users_json}]"
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_group_chat(ctx)
        begin
          user = verify_token(ctx)
          chat_id = get_param!(ctx, "chat_id").to_i
          chat = Chat.get_chat_by_id(chat_id)

          filename = ""
          unless chat.attachment_key.nil?
            attachment = Attachment.get_attachment_by_key(chat.attachment_key.to_s)
            filename = attachment.filename.to_s
          end

          group_id = chat.group_id
          group = Group.get_group_by_id(group_id)
          user_ids = [] of String
          raise "not in the group" unless user_ids.includes? (user.id.to_s)

          sender = User.get_user_by_id(chat.user_id)
          "[#{chat.to_json(filename)}, #{sender.to_json}]"
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def add_group_chat(ctx)
        begin
          user = verify_token(ctx)
          group_id = get_param!(ctx, "group_id").to_i
          group = Group.get_group_by_id(group_id)
          user_ids = [] of String
          raise "not in the group" unless user_ids.includes? (user.id.to_s)

          message = get_param!(ctx, "message")
          chat_id = Chat.add_group_chat(user, group, message)
          message = ["pullChat", chat_id.to_s].to_json
          MyServer::WS::ClientStore.broadcast_message(user_ids, message)
          {ok: true}
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def add_group_chat_with_file(ctx)
        begin
          user = verify_token(ctx)
          group_id = get_param!(ctx, "group_id").to_i
          group = Group.get_group_by_id(group_id)
          user_ids = [] of String
          raise "not in the group" unless user_ids.includes? (user.id.to_s)

          chat_id = Chat.add_group_chat_with_file(user, group, ctx)
          message = ["pullChat", chat_id.to_s].to_json
          MyServer::WS::ClientStore.broadcast_message(user_ids, message)
          {ok: true}
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def download_attachment(ctx)
        begin
          key = get_param!(ctx, "key")
          attachment = Attachment.get_attachment_by_key(key)
          raise "No static dir setup" unless ENV.has_key?("GROUP_CHAT_FILES")
          data_dir = ENV["GROUP_CHAT_FILES"]
          full_path = File.join(data_dir, attachment.location.to_s)
          ext = File.extname(full_path)
          ctx.response.headers["Content-Disposition"] = "attachment; filename=\"" + attachment.filename.to_s + "\""
          if ext.downcase == ".pdf"
            send_file ctx, full_path, "application/pdf"
          else
            send_file ctx, full_path
          end
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end
    end
  end
end

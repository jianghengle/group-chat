require "./controller_base"

module MyServer
  module HttpAPI
    module ChatController
      include MyServer::HttpAPI::ControllerBase
      extend self

      def get_latest_chats(ctx)
        begin
          user = verify_token(ctx)
          group_id = get_param!(ctx, "group_id").to_i
          group = Group.get_group_by_id(group_id)
          chat_num = get_param!(ctx, "chat_num").to_i
          chat_num = 100 if (chat_num <= 0 || chat_num > 100)
          membership = Membership.get_membership_by_group_id_user_id(group_id, user.id)
          raise "cannot get group" if membership.nil?

          chats = Chat.get_latest_chats(group_id, chat_num)
          Membership.update_timestamp(membership, chats)
          attachment_keys = chats.map { |c| c.attachment_key.nil? ? "" : c.attachment_key.to_s }
          attachment_map = Attachment.get_attachment_map(attachment_keys)
          chats_json = chats.join(",") { |c| c.to_json(attachment_map) }
          chats_json = "[" + chats_json + "]"
          user_ids = chats.map { |c| c.user_id }
          users = User.get_users_by_ids(user_ids)
          users_json = "[" + users.join(", ") { |u| u.to_json } + "]"
          MyServer::WS::ClientStore.pull_group(group_id, [user.id.to_s])
          "[#{chats_json}, #{users_json}]"
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_chats_since(ctx)
        begin
          user = verify_token(ctx)
          group_id = get_param!(ctx, "group_id").to_i
          group = Group.get_group_by_id(group_id)
          membership = Membership.get_membership_by_group_id_user_id(group_id, user.id)
          raise "cannot get group" if membership.nil?

          timestamp = get_param!(ctx, "timestamp").to_i64
          chats = Chat.get_chats_since(group_id, timestamp)
          Membership.update_timestamp(membership, chats)
          attachment_keys = chats.map { |c| c.attachment_key.nil? ? "" : c.attachment_key.to_s }
          attachment_map = Attachment.get_attachment_map(attachment_keys)
          chats_json = chats.join(",") { |c| c.to_json(attachment_map) }
          chats_json = "[" + chats_json + "]"
          user_ids = chats.map { |c| c.user_id }
          users = User.get_users_by_ids(user_ids)
          users_json = "[" + users.join(", ") { |u| u.to_json } + "]"
          MyServer::WS::ClientStore.pull_group(group_id, [user.id.to_s])
          "[#{chats_json}, #{users_json}]"
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_chats_before(ctx)
        begin
          user = verify_token(ctx)
          group_id = get_param!(ctx, "group_id").to_i
          group = Group.get_group_by_id(group_id)
          chat_num = get_param!(ctx, "chat_num").to_i
          chat_num = 100 if (chat_num <= 0 || chat_num > 100)
          membership = Membership.get_membership_by_group_id_user_id(group_id, user.id)
          raise "cannot get group" if membership.nil?

          timestamp = get_param!(ctx, "timestamp").to_i64
          chats = Chat.get_chats_before(group_id, timestamp, chat_num)
          attachment_keys = chats.map { |c| c.attachment_key.nil? ? "" : c.attachment_key.to_s }
          attachment_map = Attachment.get_attachment_map(attachment_keys)
          chats_json = chats.join(",") { |c| c.to_json(attachment_map) }
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

      def add_chat(ctx)
        begin
          user = verify_token(ctx)
          group_id = get_param!(ctx, "group_id").to_i
          group = Group.get_group_by_id(group_id)
          membership = Membership.get_membership_by_group_id_user_id(group_id, user.id)
          raise "cannot get group" if membership.nil?

          message = get_param!(ctx, "message")
          attachment_key = get_param!(ctx, "attachmentKey")
          forward = get_param!(ctx, "forward")
          chat = Chat.add_chat(user.id, group_id, message, attachment_key)
          Membership.update_timestamp(membership, [chat]) if forward.empty?
          Group.update_timestamp(group, chat)
          MyServer::WS::ClientStore.pull_group(group_id)
          "[#{chat.to_json}, #{user.to_json}]"
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def add_chat_with_file(ctx)
        begin
          user = verify_token(ctx)
          group_id = get_param!(ctx, "group_id").to_i
          group = Group.get_group_by_id(group_id)
          membership = Membership.get_membership_by_group_id_user_id(group_id, user.id)
          raise "cannot get group" if membership.nil?

          result = Chat.add_chat_with_file(user.id, group_id, ctx)
          chat = result[0]
          attachment = result[1]
          attachment_map = {} of String => String
          attachment_map[attachment.key.to_s] = attachment.filename.to_s unless attachment.filename.nil?
          chat_json = chat.to_json(attachment_map)
          Membership.update_timestamp(membership, [chat])
          Group.update_timestamp(group, chat)
          MyServer::WS::ClientStore.pull_group(group_id)
          "[#{chat_json}, #{user.to_json}]"
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

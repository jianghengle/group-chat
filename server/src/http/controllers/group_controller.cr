require "./controller_base"

module MyServer
  module HttpAPI
    module GroupController
      include MyServer::HttpAPI::ControllerBase
      extend self

      def get_groups(ctx)
        begin
          user = verify_token(ctx)
          memberships = Membership.get_memberships_by_user_id(user.id)
          group_ids = memberships.map { |m| m.group_id }
          groups = Group.get_groups_by_ids(group_ids)
          timestamp_map = {} of String => String
          memberships.each do |m|
            timestamp_map[m.group_id.to_s] = m.timestamp.to_s
          end
          conversation_name_map = Membership.get_conversation_name_map(user.id, groups)
          groups_json = groups.join(", ") do |g|
            id = g.id.to_s
            timestamp = timestamp_map[id]
            conversation_name = ""
            conversation_name = conversation_name_map[id] if conversation_name_map.has_key? id
            g.to_json_with_more(timestamp, conversation_name)
          end
          "[" + groups_json + "]"
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_public_groups(ctx)
        begin
          user = verify_token(ctx)
          groups = Group.get_public_groups
          group_ids = groups.map { |g| g.id }
          memberships = Membership.get_memberships_by_group_ids(group_ids)
          counts = {} of String => Int32
          memberships.each do |m|
            group_id = m.group_id.to_s
            counts[group_id] = 0 unless counts.has_key?(group_id)
            counts[group_id] += 1
          end
          groups_json = "[" + groups.join(", ") { |g| g.to_json(counts.has_key?(g.id.to_s) ? counts[g.id.to_s] : 0) } + "]"
          user_ids = groups.map { |g| g.owner_id }
          users = User.get_users_by_ids(user_ids)
          users_json = "[" + users.join(", ") { |u| u.to_json } + "]"
          "[#{groups_json}, #{users_json}]"
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_my_groups(ctx)
        begin
          user = verify_token(ctx)
          groups = Group.get_my_groups(user)
          group_ids = groups.map { |g| g.id }
          memberships = Membership.get_memberships_by_group_ids(group_ids)
          counts = {} of String => Int32
          memberships.each do |m|
            group_id = m.group_id.to_s
            counts[group_id] = 0 unless counts.has_key?(group_id)
            counts[group_id] += 1
          end
          groups_json = "[" + groups.join(", ") { |g| g.to_json(counts.has_key?(g.id.to_s) ? counts[g.id.to_s] : 0) } + "]"
          chats = Chat.get_latest_messages(groups)
          chats_json = "[" + chats.join(", ") { |c| c.to_json } + "]"
          owner_ids = groups.map { |g| g.owner_id }
          chatter_ids = chats.map { |c| c.user_id }
          user_ids = owner_ids | chatter_ids
          users = User.get_users_by_ids(user_ids)
          users_json = "[" + users.join(", ") { |u| u.to_json } + "]"
          "[#{groups_json}, #{chats_json}, #{users_json}]"
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_group(ctx)
        begin
          user = verify_token(ctx)
          group_id = get_param!(ctx, "group_id").to_i
          group = Group.get_group_by_id(group_id)
          membership = Membership.get_membership_by_group_id_user_id(group_id, user.id)
          raise "cannot get group" if membership.nil?
          conversation_name = ""
          if group.category.to_s == "conversation"
            conversation_name_map = Membership.get_conversation_name_map(user.id, [group])
            conversation_name = conversation_name_map[group_id.to_s] if conversation_name_map.has_key? group_id.to_s
          end
          group.to_json_with_more(membership.timestamp, conversation_name)
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_group_detail(ctx)
        user = verify_token(ctx)
        group_id = get_param!(ctx, "group_id").to_i
        group = Group.get_group_by_id(group_id)
        memberships = Membership.get_memberships_by_group_id(group_id)
        user_ids = memberships.map { |m| m.user_id }
        raise "cannot get group" unless user_ids.includes?(user.id)

        users = User.get_users_by_ids(user_ids)
        users_json = "[" + users.join(", ") { |u| u.to_json } + "]"
        "[#{group.to_json}, #{users_json}]"
      end

      def add_group(ctx)
        begin
          user = verify_token(ctx)
          group = Group.new
          group.name = get_param!(ctx, "name")
          group.category = get_param!(ctx, "category")
          group.description = get_param!(ctx, "description")
          group.status = get_param!(ctx, "status")
          group.owner_id = user.id
          group = Group.add_group(group)
          Membership.add_membership(group.id, user.id)
          group.to_json_with_more("", "")
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def update_group(ctx)
        begin
          user = verify_token(ctx)
          group_id = get_param!(ctx, "group_id").to_i
          group = Group.get_group_by_id(group_id)
          raise "cannot update group" unless user.id == group.owner_id

          group.name = get_param!(ctx, "name")
          group.description = get_param!(ctx, "description")
          group.status = get_param!(ctx, "status")
          Group.update_group(group)
          MyServer::WS::ClientStore.pull_group(group_id)
          group.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def delete_group(ctx)
        begin
          user = verify_token(ctx)
          group_id = get_param!(ctx, "group_id").to_i
          group = Group.get_group_by_id(group_id)
          raise "cannot delete group" unless user.id == group.owner_id

          memberships = Membership.get_memberships_by_group_id(group_id)
          user_ids = memberships.map { |m| m.user_id.to_s }
          Membership.delete_memberships_by_group_id(group_id)
          Group.delete_group(group)
          MyServer::WS::ClientStore.pull_group(group_id, user_ids)
          {ok: true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def join_group(ctx)
        begin
          user = verify_token(ctx)
          user_id = get_param!(ctx, "userId").to_i
          group_id = get_param!(ctx, "group_id").to_i
          group = Group.get_group_by_id(group_id)
          raise "you are owner" if group.owner_id == user_id
          membership = Membership.get_membership_by_group_id_user_id(group_id, user_id)
          raise "already member" unless membership.nil?
          Membership.add_membership(group_id, user_id)
          {ok: true}
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def quit_group(ctx)
        begin
          user = verify_token(ctx)
          group_id = get_param!(ctx, "group_id").to_i
          group = Group.get_group_by_id(group_id)
          user_id = get_param!(ctx, "userId").to_i
          membership = Membership.get_membership_by_group_id_user_id(group_id, user_id)
          raise "not a member" if membership.nil?
          raise "cannot quit owner" if group.owner_id == user_id
          raise "cannot quit" unless (group.owner_id == user.id || membership.user_id == user.id)
          Membership.delete_membership(membership)
          MyServer::WS::ClientStore.pull_group(group_id, [user_id.to_s])
          {ok: true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def quit_conversation(ctx)
        begin
          user = verify_token(ctx)
          group_id = get_param!(ctx, "group_id").to_i
          group = Group.get_group_by_id(group_id)
          raise "not a conversation" if group.category.to_s != "conversation"
          user_id = get_param!(ctx, "userId").to_i
          membership = Membership.get_membership_by_group_id_user_id(group_id, user_id)
          raise "not a member" if membership.nil?
          raise "not yourself" if membership.user_id != user.id
          Membership.delete_membership(membership)
          memberships = Membership.get_memberships_by_group_id(group_id)
          Group.delete_group(group) if memberships.empty?
          user_ids = [user_id.to_s]
          user_ids << memberships[0].user_id.to_s unless memberships.empty?
          MyServer::WS::ClientStore.pull_group(group_id, user_ids)
          {ok: true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def start_conversation(ctx)
        begin
          user = verify_token(ctx)
          user_id = get_param!(ctx, "userId").to_i
          Group.start_conversation(user.id, user_id)
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end
    end
  end
end

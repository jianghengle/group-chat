require "./controller_base"

module MyServer
  module HttpAPI
    module GroupController
      include MyServer::HttpAPI::ControllerBase
      extend self

      def get_groups(ctx)
        begin
          user = verify_token(ctx)
          owned_groups = Group.get_owned_groups(user)
          memberships = Membership.get_memberships_by_user_id(user.id)
          group_ids = memberships.map { |m| m.group_id }
          groups = Group.get_groups_by_ids(group_ids)
          groups = groups | owned_groups
          "[" + groups.join(", ") { |g| g.to_json } + "]"
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

      def get_group(ctx)
        begin
          user = verify_token(ctx)
          group_id = get_param!(ctx, "group_id").to_i
          group = Group.get_group_by_id(group_id)
          membership = Membership.get_membership_by_group_id_user_id(group_id, user.id)
          raise "cannot get group" if ((group.owner_id != user.id) && membership.nil?)
          group.to_json
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
        raise "cannot get group" unless ((group.owner_id == user.id) || user_ids.includes?(user.id))

        user_ids << group.owner_id
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
          group.to_json
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
          memberships = Membership.get_memberships_by_group_id(group_id)
          user_ids = memberships.map { |m| m.user_id.to_s }
          message = ["pullGroup", group_id.to_s].to_json
          MyServer::WS::ClientStore.broadcast_message(user_ids, message)
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
          message = ["pullGroup", group_id.to_s].to_json
          Membership.delete_memberships_by_group_id(group_id)
          Group.delete_group(group)
          MyServer::WS::ClientStore.broadcast_message(user_ids, message)
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
          raise "cannot quit" unless (group.owner_id == user.id || membership.user_id == user.id)
          Membership.delete_membership(membership)
          user_ids = [user_id.to_s]
          message = ["pullGroup", group_id.to_s].to_json
          MyServer::WS::ClientStore.broadcast_message(user_ids, message)
          {ok: true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end
    end
  end
end

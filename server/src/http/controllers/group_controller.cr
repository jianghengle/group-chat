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
          owned_group_ids = owned_groups.map { |g| g.id }
          guardians = Guardian.get_guardians_by_parent(user)
          user_ids = guardians.map { |g| g.child_id }
          user_ids << user.id
          memberships = Membership.get_group_memberships_by_user_ids(user_ids)
          memberships_json = "[" + memberships.join(", ") { |m| m.to_json } + "]"
          group_ids = memberships.map { |m| m.group_id }
          group_ids = group_ids | owned_group_ids
          groups = Group.get_groups_by_ids(group_ids)
          groups_json = "[" + groups.join(", ") { |g| g.to_json } + "]"
          owner_ids = groups.map { |g| g.owner_id }
          user_ids = user_ids | owner_ids
          users = User.get_users_by_ids(user_ids)
          users_json = "[" + users.join(", ") { |u| u.to_json } + "]"
          "[#{groups_json}, #{memberships_json}, #{users_json}]"
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
          guardians = Guardian.get_guardians_by_parent(user)
          user_ids = guardians.map { |g| g.child_id }
          user_ids << user.id
          memberships = Membership.get_group_memberships_by_user_ids(user_ids, group_id)
          raise "cannot get group" if ((group.owner_id != user.id) && memberships.empty?)
          memberships_json = "[" + memberships.join(", ") { |m| m.to_json } + "]"
          user_ids << group.owner_id
          users = User.get_users_by_ids(user_ids)
          users_json = "[" + users.join(", ") { |u| u.to_json } + "]"
          "[#{group.to_json}, #{memberships_json}, #{users_json}]"
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def add_group(ctx)
        begin
          user = verify_token(ctx)
          group = Group.new
          group.name = get_param!(ctx, "name")
          group.category = get_param!(ctx, "category")
          group.description = get_param!(ctx, "description")
          capacity = get_param!(ctx, "capacity")
          group.capacity = capacity.to_i unless capacity.empty?
          group.access = get_param!(ctx, "access")
          group.enroll = get_param!(ctx, "enroll")
          group.owner_id = user.id
          group = Group.add_group(group)
          "[#{group.to_json}, #{user.to_json}]"
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
          membership = Membership.get_group_membership_by_user_id(group_id, user.id)
          role = "member"
          role = membership.role.to_s unless membership.nil?
          role = "owner" if group.owner_id == user.id
          raise "cannot update group" unless role == "owner" || role == "admin"

          group.name = get_param!(ctx, "name")
          group.category = get_param!(ctx, "category")
          group.description = get_param!(ctx, "description")
          capacity = get_param!(ctx, "capacity")
          group.capacity = capacity.to_i unless capacity.empty?
          group.access = get_param!(ctx, "access")
          group.enroll = get_param!(ctx, "enroll")
          Group.update_group(group)
          user_ids = Membership.get_group_related_user_ids(group)
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

          user_ids = Membership.get_group_related_user_ids(group)
          message = ["pullGroup", group_id.to_s].to_json
          Membership.delete_memberships_by_group_id(group_id)
          group.owner_id = nil
          Group.update_group(group)
          MyServer::WS::ClientStore.broadcast_message(user_ids, message)
          {ok: true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_group_members(ctx)
        begin
          user = verify_token(ctx)
          group_id = get_param!(ctx, "group_id").to_i
          group = Group.get_group_by_id(group_id)
          memberships = Membership.get_group_memberships(group_id)
          memberships_json = "[" + memberships.join(", ") { |m| m.to_json } + "]"
          children_ids = memberships.map { |m| m.user_id }
          guardians = Guardian.get_guardians_by_children_ids(children_ids)
          guardians_json = "[" + guardians.join(", ") { |g| g.to_json } + "]"
          parent_ids = guardians.map { |g| g.parent_id }
          user_ids = children_ids | parent_ids
          user_ids << group.owner_id
          raise "cannot get group members" unless user_ids.includes?(user.id)
          users = User.get_users_by_ids(user_ids)
          users_json = "[" + users.join(", ") { |u| u.to_json } + "]"
          "[#{memberships_json}, #{guardians_json}, #{users_json}]"
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def update_group_membership(ctx)
        begin
          user = verify_token(ctx)
          membership_id = get_param!(ctx, "membership_id").to_i
          membership = Membership.get_membership_by_id(membership_id)
          group = Group.get_group_by_id(membership.group_id)
          raise "cannot update membership" unless group.owner_id == user.id

          role = get_param!(ctx, "role")
          raise "wrong role" unless ["admin", "member"].includes?(role)
          membership.role = role
          Membership.update_membership(membership)
          user_ids = Membership.get_group_related_user_ids(group)
          message = ["pullGroup", group.id.to_s].to_json
          MyServer::WS::ClientStore.broadcast_message(user_ids, message)
          membership.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def delete_group_membership(ctx)
        begin
          user = verify_token(ctx)
          membership_id = get_param!(ctx, "membership_id").to_i
          membership = Membership.get_membership_by_id(membership_id)
          group = Group.get_group_by_id(membership.group_id)

          user_ids = Membership.get_group_related_user_ids(group)
          message = ["pullGroup", group.id.to_s].to_json

          guardians = Guardian.get_guardians_by_child_id(membership.user_id)
          guardian_ids = guardians.map { |g| g.parent_id }

          if group.owner_id == user.id
            Membership.delete_membership(membership)
          elsif membership.user_id == user.id
            Membership.delete_membership(membership)
          elsif guardian_ids.includes?(user.id)
            Membership.delete_membership(membership)
          else
            raise "cannot delete admin" unless membership.role.to_s == "member"
            user_membership = Membership.get_group_membership_by_user_id(group.id, user.id)
            raise "you are not member" if user_membership.nil?
            raise "you are not admin" unless user_membership.role.to_s == "admin"
            Membership.delete_membership(membership)
          end
          MyServer::WS::ClientStore.broadcast_message(user_ids, message)
          {ok: true}.to_json
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
          memberships = Membership.get_membership_by_group_ids(group_ids)
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

      def enroll_group(ctx)
        begin
          user = verify_token(ctx)
          user_id = get_param!(ctx, "userId").to_i
          group_id = get_param!(ctx, "group_id").to_i
          group = Group.get_group_by_id(group_id)
          raise "group not public" unless group.access.to_s == "public"
          raise "enroll not open" unless group.enroll.to_s == "open"
          raise "you are owner" if group.owner_id == user_id
          membership = Membership.get_group_membership_by_user_id(group_id, user_id)
          raise "already member" unless membership.nil?
          Membership.add_group_membership(group_id, user_id)
          user_ids = Membership.get_group_related_user_ids(group)
          message = ["pullGroup", group.id.to_s].to_json
          MyServer::WS::ClientStore.broadcast_message(user_ids, message)
          {ok: true}
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end
    end
  end
end

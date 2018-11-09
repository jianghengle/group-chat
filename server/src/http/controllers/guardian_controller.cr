require "./controller_base"

module MyServer
  module HttpAPI
    module GuardianController
      include MyServer::HttpAPI::ControllerBase
      extend self

      def guardian_get_children(ctx)
        begin
          user = verify_token(ctx)
          guardians = Guardian.get_guardians_by_parent(user)
          guardians_json = "[" + guardians.join(", ") { |g| g.to_json } + "]"
          ids = guardians.map { |g| g.child_id }
          children = User.get_users_by_ids(ids)
          children_json = "[" + children.join(", ") { |c| c.to_json } + "]"
          "[#{children_json}, #{guardians_json}]"
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def guardian_add_child(ctx)
        begin
          user = verify_token(ctx)
          first_name = get_param!(ctx, "firstName")
          last_name = get_param!(ctx, "lastName")
          relation = get_param!(ctx, "relation")
          Guardian.add_child_by_parent(user, first_name, last_name, relation)
          {ok: true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def guardian_get_child(ctx)
        begin
          user = verify_token(ctx)
          child_id = get_param!(ctx, "child_id")
          child = User.get_user_by_id(child_id)
          relations = Guardian.get_guardians_by_child_id(child.id)
          relations_json = "[" + relations.join(", ") { |r| r.to_json } + "]"
          guardian_ids = relations.map { |g| g.parent_id }
          raise "Cannot access child" unless guardian_ids.includes?(user.id)
          guardians = User.get_users_by_ids(guardian_ids)
          guardians_json = "[" + guardians.join(", ") { |g| g.to_json } + "]"
          "[#{child.to_json}, #{guardians_json}, #{relations_json}]"
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def guardian_update_child(ctx)
        begin
          user = verify_token(ctx)
          child_id = get_param!(ctx, "child_id").to_i
          first_name = get_param!(ctx, "firstName")
          last_name = get_param!(ctx, "lastName")
          relation = get_param!(ctx, "relation")
          guardian_id = get_param!(ctx, "guardianId")
          Guardian.update_child_by_parent(user, child_id, first_name, last_name, guardian_id, relation)
          {ok: true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def guardian_delete_child(ctx)
        begin
          user = verify_token(ctx)
          child_id = get_param!(ctx, "child_id").to_i
          guardian_id = get_param!(ctx, "guardianId")
          Guardian.delete_child_by_parent(user, child_id, guardian_id)
          {ok: true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def guardian_remove_guardian(ctx)
        begin
          user = verify_token(ctx)
          guardian_id = get_param!(ctx, "guardian_id").to_i
          master_guardian_id = get_param!(ctx, "masterGuardianId").to_i
          Guardian.remove_guardian_by_parent(user, master_guardian_id, guardian_id)
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

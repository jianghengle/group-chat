module MyServer
  module HttpAPI
    class Membership < Crecto::Model
      schema "memberships" do
        field :user_id, Int64
        field :group_id, Int64
        field :conversation, Bool
        field :role, String
        field :status, String
        field :timestamp, Int64
      end

      def to_json
        String.build do |str|
          str << "{"
          str << "\"id\":" << @id << ","
          str << "\"userId\":" << @user_id << ","
          str << "\"groupId\":" << @group_id << ","
          str << "\"conversation\":" << @conversation.to_json << ","
          str << "\"role\":" << @role.to_json << ","
          str << "\"status\":" << @status.to_json << ","
          str << "\"timestamp\":" << @timestamp.to_json
          str << "}"
        end
      end

      def self.get_group_memberships_by_user_ids(user_ids, group_id = nil)
        return [] of Membership if user_ids.empty?
        query = Query.where(conversation: "false").where(:user_id, user_ids)
        query = query.where(group_id: group_id) unless group_id.nil?
        items = Repo.all(Membership, query)
        return [] of Membership if items.nil?
        items.as(Array)
      end

      def self.get_group_membership_by_user_id(group_id, user_id)
        query = Query.where(group_id: group_id).where(user_id: user_id)
        items = Repo.all(Membership, query)
        return nil if items.nil?
        return nil if items.as(Array).empty?
        items.as(Array).first
      end

      def self.delete_memberships_by_group_id(group_id)
        query = Query.where(group_id: group_id)
        Repo.delete_all(Membership, query)
      end

      def self.delete_group_membership_by_user_id(user_id)
        query = Query.where(user_id: user_id)
        Repo.delete_all(Membership, query)
      end

      def self.get_group_memberships(group_id)
        query = Query.where(group_id: group_id)
        items = Repo.all(Membership, query)
        return [] of Membership if items.nil?
        items.as(Array)
      end

      def self.get_membership_by_id(id)
        membership = Repo.get(Membership, id)
        raise "Cannot find group" if membership.nil?
        membership
      end

      def self.update_membership(membership)
        changeset = Repo.update(membership)
        raise changeset.errors.to_s unless changeset.valid?
      end

      def self.delete_membership(membership)
        changeset = Repo.delete(membership)
        raise changeset.errors.to_s unless changeset.valid?
      end

      def self.get_membership_by_group_ids(group_ids)
        query = Query.where(:group_id, group_ids)
        items = Repo.all(Membership, query)
        return [] of Membership if items.nil?
        items.as(Array)
      end

      def self.add_group_membership(group_id, user_id)
        membership = Membership.new
        membership.group_id = group_id
        membership.user_id = user_id
        membership.role = "member"
        membership.conversation = false
        changeset = Repo.insert(membership)
        raise changeset.errors.to_s unless changeset.valid?
      end

      def self.get_group_related_user_ids(group)
        query = Query.where(group_id: group.id)
        items = Repo.all(Membership, query)
        return [] of String if items.nil?
        children_ids = items.as(Array).map { |m| m.user_id }
        guardians = Guardian.get_guardians_by_children_ids(children_ids)
        parent_ids = guardians.map { |g| g.parent_id }
        user_ids = children_ids | parent_ids
        user_ids << group.owner_id
        user_ids.map { |u| u.to_s }
      end
    end
  end
end

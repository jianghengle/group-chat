module MyServer
  module HttpAPI
    class Membership < Crecto::Model
      schema "memberships" do
        field :user_id, Int64
        field :group_id, Int64
        field :timestamp, Int64
      end

      def to_json
        String.build do |str|
          str << "{"
          str << "\"id\":" << @id << ","
          str << "\"userId\":" << @user_id << ","
          str << "\"groupId\":" << @group_id << ","
          str << "\"timestamp\":" << @timestamp.to_json
          str << "}"
        end
      end

      def self.get_membership_by_id(id)
        membership = Repo.get(Membership, id)
        raise "Cannot find group" if membership.nil?
        membership
      end

      def self.get_memberships_by_user_id(user_id)
        query = Query.where(user_id: user_id)
        items = Repo.all(Membership, query)
        return [] of Membership if items.nil?
        items.as(Array)
      end

      def self.get_memberships_by_group_id(group_id)
        query = Query.where(group_id: group_id)
        items = Repo.all(Membership, query)
        return [] of Membership if items.nil?
        items.as(Array)
      end

      def self.get_membership_by_group_id_user_id(group_id, user_id)
        query = Query.where(group_id: group_id).where(user_id: user_id)
        items = Repo.all(Membership, query)
        return nil if items.nil?
        return nil if items.as(Array).empty?
        items.as(Array).first
      end

      def self.get_memberships_by_group_ids(group_ids)
        query = Query.where(:group_id, group_ids)
        items = Repo.all(Membership, query)
        return [] of Membership if items.nil?
        items.as(Array)
      end

      def self.get_conversation_name_map(user_id, groups)
        result = {} of String => String
        conversations = groups.select { |g| g.category.to_s == "conversation" }
        return result if conversations.empty?
        conversation_ids = conversations.map { |c| c.id }
        query = Query.where(:group_id, conversation_ids).where("user_id <> ?", [user_id])
        items = Repo.all(Membership, query)
        return result if items.nil?
        items.as(Array).each do |i|
          result[i.group_id.to_s] = i.user_id.to_s
        end
        user_name_map = User.get_name_map(result.values)
        result.keys.each do |k|
          v = result[k]
          result[k] = ""
          result[k] = user_name_map[v] if user_name_map.has_key? v
        end
        result
      end

      def self.add_membership(group_id, user_id)
        membership = Membership.new
        membership.group_id = group_id
        membership.user_id = user_id
        changeset = Repo.insert(membership)
        raise changeset.errors.to_s unless changeset.valid?
        new_id = nil.as(Int64?)
        changeset.changes.each do |change|
          if (change.has_key?(:id))
            new_id = change[:id].as(Int64)
          end
        end
        raise "cannot get new id!" if new_id.nil?
        membership.id = new_id
        membership
      end

      def self.delete_memberships_by_group_id(group_id)
        query = Query.where(group_id: group_id)
        Repo.delete_all(Membership, query)
      end

      def self.delete_membership(membership)
        changeset = Repo.delete(membership)
        raise changeset.errors.to_s unless changeset.valid?
      end

      def self.update_timestamp(membership, chats)
        chat = chats.first?
        return if chat.nil? || chat.timestamp.nil?
        chat_timestamp = chat.timestamp
        return if chat_timestamp.nil?
        chat_timestamp = chat_timestamp.to_i64
        timestamp = membership.timestamp
        if timestamp.nil?
          membership.timestamp = chat_timestamp
        else
          timestamp = timestamp.to_i64
          membership.timestamp = chat_timestamp if timestamp < chat_timestamp
        end
        Repo.update(membership)
      end
    end
  end
end

module MyServer
  module HttpAPI
    class Group < Crecto::Model
      schema "groups" do
        field :name, String
        field :category, String
        field :description, String
        field :status, String
        field :owner_id, Int64
        field :timestamp, Int64
      end

      def to_json(membership_count = -1)
        String.build do |str|
          str << "{"
          str << "\"id\":" << @id << ","
          str << "\"name\":" << @name.to_json << ","
          str << "\"category\":" << @category.to_json << ","
          str << "\"description\":" << @description.to_json << ","
          str << "\"status\":" << @status.to_json << ","
          str << "\"ownerId\":" << @owner_id.to_json << ","
          str << "\"membershipCount\":" << membership_count.to_json << "," if membership_count > -1
          str << "\"timestamp\":" << @timestamp.to_json
          str << "}"
        end
      end

      def to_json_with_more(user_timestamp, conversation_name)
        String.build do |str|
          str << "{"
          str << "\"id\":" << @id << ","
          name = @name
          name = conversation_name unless conversation_name.empty?
          str << "\"name\":" << name.to_json << ","
          str << "\"category\":" << @category.to_json << ","
          str << "\"description\":" << @description.to_json << ","
          str << "\"status\":" << @status.to_json << ","
          str << "\"ownerId\":" << @owner_id.to_json << ","
          str << "\"userTimestamp\":" << user_timestamp.to_json << ","
          str << "\"timestamp\":" << @timestamp.to_json
          str << "}"
        end
      end

      def self.get_group_by_id(id)
        group = Repo.get(Group, id)
        raise "Cannot find group" if group.nil?
        group
      end

      def self.get_groups_by_ids(ids)
        return [] of Group if ids.empty?
        query = Query.where(:id, ids)
        items = Repo.all(Group, query)
        return [] of Group if items.nil?
        items.as(Array)
      end

      def self.get_public_groups
        query = Query.where(status: "public")
        items = Repo.all(Group, query)
        return [] of Group if items.nil?
        items.as(Array)
      end

      def self.get_my_groups(user)
        memberships = Membership.get_memberships_by_user_id(user.id)
        group_ids = memberships.map { |m| m.group_id }
        query = Query.where(:id, group_ids).where("category <> ?", ["conversation"])
        items = Repo.all(Group, query)
        return [] of Group if items.nil?
        items.as(Array)
      end

      def self.add_group(group)
        changeset = Repo.insert(group)
        raise changeset.errors.to_s unless changeset.valid?
        new_id = nil.as(Int64?)
        changeset.changes.each do |change|
          if (change.has_key?(:id))
            new_id = change[:id].as(Int64)
          end
        end
        raise "cannot get new id!" if new_id.nil?
        group.id = new_id
        group
      end

      def self.update_group(group)
        changeset = Repo.update(group)
        raise changeset.errors.to_s unless changeset.valid?
      end

      def self.delete_group(group)
        Chat.delete_all_by_group_id(group.id)
        changeset = Repo.delete(group)
        raise changeset.errors.to_s unless changeset.valid?
      end

      def self.update_timestamp(group, chat)
        chat_timestamp = chat.timestamp
        return if chat_timestamp.nil?
        chat_timestamp = chat_timestamp.to_i64
        timestamp = group.timestamp
        if timestamp.nil?
          group.timestamp = chat_timestamp
        else
          timestamp = timestamp.to_i64
          group.timestamp = chat_timestamp if timestamp < chat_timestamp
        end
        Repo.update(group)
      end

      def self.get_conversation_by_ids(ids)
        query = Query.where(:id, ids).where(category: "conversation")
        items = Repo.all(Group, query)
        return nil if items.nil?
        items.as(Array).first?
      end

      def self.start_conversation(user1_id, user2_id)
        user2 = User.get_user_by_id(user2_id)
        memberships1 = Membership.get_memberships_by_user_id(user1_id)
        g1_ids = memberships1.map { |m| m.group_id.to_s }
        memberships2 = Membership.get_memberships_by_user_id(user2_id)
        g2_ids = memberships2.map { |m| m.group_id.to_s }
        common_group_ids = g1_ids & g2_ids
        conversation = Group.get_conversation_by_ids(common_group_ids)
        if conversation.nil?
          conversation = Group.new
          conversation.name = "__"
          conversation.category = "conversation"
          conversation = Group.add_group(conversation)
          membership1 = Membership.add_membership(conversation.id, user1_id)
          membership2 = Membership.add_membership(conversation.id, user2_id)
          return conversation.to_json_with_more("", user2.full_name.to_s)
        end
        membership1 = Membership.get_membership_by_group_id_user_id(conversation.id, user1_id)
        membership2 = Membership.get_membership_by_group_id_user_id(conversation.id, user2_id)
        conversation.to_json_with_more("", user2.full_name.to_s)
      end
    end
  end
end

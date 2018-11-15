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

      def self.get_owned_groups(user)
        query = Query.where(owner_id: user.id)
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
        changeset = Repo.delete(group)
        raise changeset.errors.to_s unless changeset.valid?
      end
    end
  end
end

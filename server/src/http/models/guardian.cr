module MyServer
  module HttpAPI
    class Guardian < Crecto::Model
      schema "guardians" do
        field :parent_id, Int64
        field :child_id, Int64
        field :master, Bool
        field :relation, String
      end

      def to_json
        String.build do |str|
          str << "{"
          str << "\"id\":" << @id << ","
          str << "\"parentId\":" << @parent_id << ","
          str << "\"childId\":" << @child_id << ","
          str << "\"master\":" << @master.to_json << ","
          str << "\"relation\":" << @relation.to_json
          str << "}"
        end
      end

      def self.get_guardians_by_parent(parent : User)
        query = Query.where(parent_id: parent.id)
        items = Repo.all(Guardian, query)
        return [] of Guardian if items.nil?
        items.as(Array)
      end

      def self.add_child_by_parent(parent, first_name, last_name, relation)
        child = User.new
        child.email = "unknown"
        child.first_name = first_name
        child.last_name = last_name
        changeset = Repo.insert(child)
        raise changeset.errors.to_s unless changeset.valid?
        child_id = nil.as(Int64?)
        changeset.changes.each do |change|
          if (change.has_key?(:id))
            child_id = change[:id].as(Int64)
          end
        end
        raise "cannot get new id!" if child_id.nil?

        guardian = Guardian.new
        guardian.parent_id = parent.id
        guardian.child_id = child_id
        guardian.master = true
        guardian.relation = relation
        changeset = Repo.insert(guardian)
        raise changeset.errors.to_s unless changeset.valid?
        child_id
      end

      def self.get_guardians_by_child_id(child_id)
        query = Query.where(child_id: child_id)
        items = Repo.all(Guardian, query)
        return [] of Guardian if items.nil?
        items.as(Array)
      end

      def self.get_guardians_by_children_ids(children_ids)
        query = Query.where(:child_id, children_ids)
        items = Repo.all(Guardian, query)
        return [] of Guardian if items.nil?
        items.as(Array)
      end

      def self.update_child_by_parent(parent, child_id, first_name, last_name, guardian_id, relation)
        guardian = Repo.get(Guardian, guardian_id)
        raise "Cannot find guardian" if guardian.nil?
        raise "Cannot verify guardian" unless (guardian.parent_id == parent.id && guardian.child_id == child_id)
        guardian.relation = relation
        changeset = Repo.update(guardian)
        raise changeset.errors.to_s unless changeset.valid?

        child = User.get_user_by_id(child_id)
        child.first_name = first_name
        child.last_name = last_name
        changeset = Repo.update(child)
        raise changeset.errors.to_s unless changeset.valid?
      end

      def self.delete_child_by_parent(parent, child_id, guardian_id)
        guardian = Repo.get(Guardian, guardian_id)
        raise "Cannot find guardian" if guardian.nil?
        raise "Cannot verify guardian" unless (guardian.parent_id == parent.id && guardian.child_id == child_id && guardian.master)
        child = User.get_user_by_id(child_id)

        Membership.delete_group_membership_by_user_id(child.id)
        query = Query.where(child_id: child_id)
        Repo.delete_all(Guardian, query)
        child.status = "deleted"
        changeset = Repo.update(child)
        raise changeset.errors.to_s unless changeset.valid?
      end

      def self.remove_guardian_by_parent(parent, master_guardian_id, guardian_id)
        master_guardian = Repo.get(Guardian, master_guardian_id)
        raise "Cannot find master guardian" if master_guardian.nil?
        guardian = Repo.get(Guardian, guardian_id)
        raise "Cannot find guardian" if guardian.nil?
        raise "Cannot verify master guardian" unless (master_guardian.parent_id == parent.id && master_guardian.master)
        raise "Cannot verify guardian" unless (master_guardian.child_id == guardian.child_id)
        changeset = Repo.delete(guardian)
        raise changeset.errors.to_s unless changeset.valid?
        [master_guardian, guardian]
      end
    end
  end
end

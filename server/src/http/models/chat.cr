module MyServer
  module HttpAPI
    class Chat < Crecto::Model
      schema "chats" do
        field :user_id, Int64
        field :group_id, Int64
        field :message, String
        field :timestamp, Int64
        field :attachment_key, String
        field :request_key, String
        field :starred, Bool
      end

      def to_json(filename = "")
        String.build do |str|
          str << "{"
          str << "\"id\":" << @id << ","
          str << "\"userId\":" << @user_id << ","
          str << "\"groupId\":" << @group_id << ","
          str << "\"message\":" << @message.to_json << ","
          str << "\"attachmentKey\":" << @attachment_key.to_json << ","
          str << "\"filename\":" << filename.to_json << "," unless filename.empty?
          str << "\"requestKey\":" << @request_key.to_json << ","
          str << "\"starred\":" << @starred.to_json << ","
          str << "\"timestamp\":" << @timestamp.to_json
          str << "}"
        end
      end

      def self.get_chats_by_group(group)
        query = Query.where(group_id: group.id)
        items = Repo.all(Chat, query)
        return [] of Chat if items.nil?
        items.as(Array)
      end

      def self.get_chat_by_id(id)
        chat = Repo.get(Chat, id)
        raise "Cannot find chat" if chat.nil?
        chat
      end

      def self.add_group_chat(user, group, message)
        chat = Chat.new
        chat.user_id = user.id
        chat.group_id = group.id
        chat.message = message
        chat.timestamp = Time.now.epoch_ms
        chat.starred = false
        changeset = Repo.insert(chat)
        raise changeset.errors.to_s unless changeset.valid?

        chat_id = nil.as(Int64?)
        changeset.changes.each do |change|
          if (change.has_key?(:id))
            chat_id = change[:id].as(Int64)
          end
        end
        raise "cannot get new id!" if chat_id.nil?
        chat_id
      end

      def self.add_group_chat_with_file(user, group, ctx)
        attachment = Attachment.create_file(ctx)

        chat = Chat.new
        chat.user_id = user.id
        chat.group_id = group.id
        chat.message = attachment[0]
        chat.attachment_key = attachment[1]
        chat.timestamp = Time.now.epoch_ms
        chat.starred = false
        changeset = Repo.insert(chat)
        raise changeset.errors.to_s unless changeset.valid?

        chat_id = nil.as(Int64?)
        changeset.changes.each do |change|
          if (change.has_key?(:id))
            chat_id = change[:id].as(Int64)
          end
        end
        raise "cannot get new id!" if chat_id.nil?
        chat_id
      end
    end
  end
end

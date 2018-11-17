module MyServer
  module HttpAPI
    class Chat < Crecto::Model
      schema "chats" do
        field :user_id, Int64
        field :group_id, Int64
        field :message, String
        field :timestamp, Int64
        field :attachment_key, String
      end

      def to_json(attachment_map = {} of String => String)
        String.build do |str|
          str << "{"
          str << "\"id\":" << @id << ","
          str << "\"userId\":" << @user_id << ","
          str << "\"groupId\":" << @group_id << ","
          str << "\"message\":" << @message.to_json << ","
          if ((!@attachment_key.nil?) && attachment_map.has_key?(@attachment_key.to_s))
            filename = attachment_map[@attachment_key.to_s]
            str << "\"filename\":" << filename.to_json << "," unless filename.empty?
          end
          str << "\"attachmentKey\":" << @attachment_key.to_json << ","
          str << "\"timestamp\":" << @timestamp.to_json
          str << "}"
        end
      end

      def self.get_latest_chats(group_id)
        query = Query.where(group_id: group_id).order_by("timestamp DESC").limit(100)
        items = Repo.all(Chat, query)
        return [] of Chat if items.nil?
        items.as(Array)
      end

      def self.get_chats_since(group_id, timestamp)
        query = Query.where(group_id: group_id).where("timestamp > ?", [timestamp]).order_by("timestamp DESC")
        items = Repo.all(Chat, query)
        return [] of Chat if items.nil?
        items.as(Array)
      end

      def self.get_chats_before(group_id, timestamp)
        query = Query.where(group_id: group_id).where("timestamp < ?", [timestamp]).limit(100).order_by("timestamp DESC")
        items = Repo.all(Chat, query)
        return [] of Chat if items.nil?
        items.as(Array)
      end

      def self.get_chat_by_id(id)
        chat = Repo.get(Chat, id)
        raise "Cannot find chat" if chat.nil?
        chat
      end

      def self.add_chat(user_id, group_id, message)
        chat = Chat.new
        chat.user_id = user_id
        chat.group_id = group_id
        chat.message = message
        chat.timestamp = Time.now.epoch_ms
        changeset = Repo.insert(chat)
        raise changeset.errors.to_s unless changeset.valid?

        chat_id = nil.as(Int64?)
        changeset.changes.each do |change|
          if (change.has_key?(:id))
            chat_id = change[:id].as(Int64)
          end
        end
        raise "cannot get new id!" if chat_id.nil?
        chat.id = chat_id
        chat
      end

      def self.add_chat_with_file(user_id, group_id, ctx)
        attachment = Attachment.create_file(ctx)

        chat = Chat.new
        chat.user_id = user_id
        chat.group_id = group_id
        chat.message = attachment[0]
        chat.attachment_key = attachment[1]
        chat.timestamp = Time.now.epoch_ms

        changeset = Repo.insert(chat)
        raise changeset.errors.to_s unless changeset.valid?

        chat_id = nil.as(Int64?)
        changeset.changes.each do |change|
          if (change.has_key?(:id))
            chat_id = change[:id].as(Int64)
          end
        end
        raise "cannot get new id!" if chat_id.nil?
        chat.id = chat_id
        chat
      end
    end
  end
end

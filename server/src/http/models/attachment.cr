module MyServer
  module HttpAPI
    class Attachment < Crecto::Model
      schema "attachments" do
        field :key, String
        field :filename, String
        field :location, String
      end

      def to_json
        String.build do |str|
          str << "{"
          str << "\"id\":" << @id << ","
          str << "\"key\":" << @key.to_json << ","
          str << "\"filename\":" << @filename.to_json << ","
          str << "\"location\":" << @status.to_json
          str << "}"
        end
      end

      def self.create_file(env)
        message = ""
        attachment = Attachment.new
        attachment.key = Random::Secure.urlsafe_base64(32).to_s
        HTTP::FormData.parse(env.request) do |part|
          if part.name == "message"
            message = JSON.parse(part.body.gets_to_end).to_s
          elsif part.name == "file"
            raise "No static dir setup" unless ENV.has_key?("GROUP_CHAT_FILES")
            data_dir = ENV["GROUP_CHAT_FILES"]

            filename = part.filename
            raise "No filename included in upload" unless filename.is_a?(String)
            attachment.filename = filename

            unique_name = Attachment.get_unique_filename(data_dir, filename)
            target_path = File.join(data_dir, unique_name)
            File.open(target_path, "w") do |f|
              IO.copy(part.body, f)
            end

            attachment.location = unique_name
          end
        end

        unless (attachment.filename.nil?)
          changeset = Repo.insert(attachment)
          raise changeset.errors.to_s unless changeset.valid?
        end
        {message, attachment}
      end

      def self.get_unique_filename(path, filename)
        ext = File.extname(filename)
        name = filename[0, (filename.size - ext.size)]
        new_name = filename
        i = 0
        while File.exists?(File.join(path, new_name))
          i = i + 1
          new_name = name + "_" + i.to_s + ext
        end
        new_name
      end

      def self.get_attachment_map(keys)
        result = {} of String => String
        query = Query.where(:key, keys)
        items = Repo.all(Attachment, query)
        return result if items.nil?
        items.as(Array).each do |i|
          result[i.key.to_s] = i.filename.to_s
        end
        result
      end

      def self.get_attachment_by_key(key)
        Repo.get_by!(Attachment, key: key)
      end
    end
  end
end

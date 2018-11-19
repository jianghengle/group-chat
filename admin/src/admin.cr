require "pg"
require "crecto-admin"

module Repo
  extend Crecto::Repo
  config do |conf|
    conf.adapter = Crecto::Adapters::Postgres
    conf.uri = ENV["DB_URL"]
  end
end

class User < Crecto::Model
  schema "users" do
    field :email, String
    field :encrypted_password, String
    field :auth_token, String
    field :role, String
    field :full_name, String
  end

  def self.form_attributes
    [{:email, "string"},
     {:encrypted_password, "password"},
     {:auth_token, "string"},
     {:role, "enum", ["superuser", "user"]},
     {:full_name, "string"}]
  end

  def self.can_access(user)
    return false unless user.is_a? User
    user.role.to_s == "superuser"
  end
end

class Group < Crecto::Model
  schema "groups" do
    field :name, String
    field :category, String
    field :description, String
    field :status, String
    field :owner_id, Int64
    field :timestamp, Int64
  end

  def self.can_access(user)
    return false unless user.is_a? User
    user.role.to_s == "superuser"
  end
end

class Membership < Crecto::Model
  schema "memberships" do
    field :user_id, Int64
    field :group_id, Int64
    field :timestamp, Int64
  end

  def self.can_access(user)
    return false unless user.is_a? User
    user.role.to_s == "superuser"
  end
end

class Chat < Crecto::Model
  schema "chats" do
    field :user_id, Int64
    field :group_id, Int64
    field :message, String
    field :timestamp, Int64
    field :attachment_key, String
  end

  def self.can_access(user)
    return false unless user.is_a? User
    user.role.to_s == "superuser"
  end
end

class Attachment < Crecto::Model
  schema "attachments" do
    field :key, String
    field :filename, String
    field :location, String
  end

  def self.can_access(user)
    return false unless user.is_a? User
    user.role.to_s == "superuser"
  end
end

CrectoAdmin.config do |config|
  config.auth_enabled = true
  config.auth = CrectoAdmin::DatabaseAuth
  config.auth_repo = Repo
  config.auth_model = User
  config.auth_model_identifier = :email
  config.auth_model_password = :encrypted_password
  config.app_name = "Group Chat"
end

init_admin()

admin_resource(User, Repo)
admin_resource(Group, Repo)
admin_resource(Membership, Repo)
admin_resource(Chat, Repo)
admin_resource(Attachment, Repo)

Kemal::Session.config do |config|
  config.secret = "sTHxjX3R"
  config.secret = ENV["ADMIN_SECRET"] if ENV.has_key?("ADMIN_SECRET")
end

Kemal.run 9001

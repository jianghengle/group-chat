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
    field :first_name, String
    field :last_name, String
    field :status, String
  end

  def self.form_attributes
    [{:email, "string"},
     {:encrypted_password, "password"},
     {:auth_token, "string"},
     {:role, "enum", ["superuser", "user"]},
     {:first_name, "string"},
     {:last_name, "string"},
     {:status, "enum", ["active", "inactive", "deleted"]}]
  end

  def self.can_access(user)
    return false unless user.is_a? User
    user.role.to_s == "superuser"
  end
end

class Guardian < Crecto::Model
  schema "guardians" do
    field :parent_id, Int64
    field :child_id, Int64
    field :master, Bool
    field :relation, String
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
admin_resource(Guardian, Repo)

Kemal::Session.config do |config|
  config.secret = "sTHxjX3R"
  config.secret = ENV["ADMIN_SECRET"] if ENV.has_key?("ADMIN_SECRET")
end

Kemal.run 3001

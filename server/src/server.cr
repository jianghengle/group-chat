require "pg"
require "crecto"
require "kemal"
require "json"
require "crypto/bcrypt/password"

require "./http/models/*"
require "./http/errors/*"
require "./http/controllers/*"
require "./http/middleware/*"

module Repo
  extend Crecto::Repo

  config do |conf|
    conf.adapter = Crecto::Adapters::Postgres
    conf.uri = ENV["DB_URL"]
  end
end

Query = Crecto::Repo::Query

module MyServer
  class Server
    def initialize
      # Middlewares
      add_handler MyServer::HttpAPI::ApiHandler.new

      get "/" do |env|
        env.redirect "/index.html"
      end

      post "/get_auth_token" do |env|
        HttpAPI::UserController.get_auth_token(env)
      end

      get "/guardian_get_children" do |env|
        HttpAPI::GuardianController.guardian_get_children(env)
      end

      post "/guardian_add_child" do |env|
        HttpAPI::GuardianController.guardian_add_child(env)
      end

      get "/guardian_get_child/:child_id" do |env|
        HttpAPI::GuardianController.guardian_get_child(env)
      end

      post "/guardian_update_child/:child_id" do |env|
        HttpAPI::GuardianController.guardian_update_child(env)
      end

      post "/guardian_delete_child/:child_id" do |env|
        HttpAPI::GuardianController.guardian_delete_child(env)
      end

      post "/guardian_remove_guardian/:guardian_id" do |env|
        HttpAPI::GuardianController.guardian_remove_guardian(env)
      end

      get "/get_groups" do |env|
        HttpAPI::GroupController.get_groups(env)
      end

      post "/add_group" do |env|
        HttpAPI::GroupController.add_group(env)
      end

      post "/update_group/:group_id" do |env|
        HttpAPI::GroupController.update_group(env)
      end

      post "/delete_group/:group_id" do |env|
        HttpAPI::GroupController.delete_group(env)
      end

      get "/get_group_members/:group_id" do |env|
        HttpAPI::GroupController.get_group_members(env)
      end

      post "/update_group_membership/:membership_id" do |env|
        HttpAPI::GroupController.update_group_membership(env)
      end

      post "/delete_group_membership/:membership_id" do |env|
        HttpAPI::GroupController.delete_group_membership(env)
      end

      get "/get_public_groups" do |env|
        HttpAPI::GroupController.get_public_groups(env)
      end

      post "/enroll_group/:group_id" do |env|
        HttpAPI::GroupController.enroll_group(env)
      end

      Kemal.run
    end
  end
end

MyServer::Server.new

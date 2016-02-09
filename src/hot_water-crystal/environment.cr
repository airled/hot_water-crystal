require "ambience"
require "mysql"

module HotWater::Crystal
  ENV["env"] ||= "development"
  config_path = File.expand_path("../../../config/environment.yml", __FILE__)
  Ambience::Application.new(config_path, ENV["env"]).load
  SERVER = ENV["source_server"]
  DB     = MySQL.connect("127.0.0.1", "root", "", ENV["database"], 3306_u16, nil)
end

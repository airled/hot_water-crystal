require "kemal"
require "./hot_water-crystal/*"
require "ambience"

module HotWater::Crystal
  ENV["env"] ||= "development"
  config_path = File.expand_path("../../config/environment.yml", __FILE__)
  amb = Ambience::Application.new(config_path, ENV["env"])
  amb.load
  server = ENV["source_server"]

  get "/" do
    render "views/index.ecr"
  end
end

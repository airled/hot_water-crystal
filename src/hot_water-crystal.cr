require "kemal"
require "mysql"
require "active_record"
require "./hot_water-crystal/*"

module HotWater::Crystal
  get "/" do
    render "views/index.ecr"
  end

  get "/date" do |env|
    if (env.params.size == 2) &&
       (env.params.has_key?("street")) &&
       (env.params.has_key?("house")) # &&
      # (env.params["street"].match(/[^А-Яа-я0-9ё\.\ \-]/).nil?) &&
      # (env.params["house"].match(/[^А-Яа-яё0-9\.\ ]/).nil?)
      street = env.params["street"]
      house = env.params["house"]
      #        date = Finder.new.date_find(street, house)
      # env.content_type = "application/json"
      # {date: date}.to_json
    else
      "Params error"
    end
  end

  get "/auto_street" do |env|
    term = env.params["term"]
    #   addresses = Address.distinct.select(:street).where('street LIKE ?', "#{term}%").limit(10)
    #   (addresses.map { |address| {id: nil, label: address.street, value: address.street} }).to_json
    env.content_type = "application/json"
    term.to_json
  end

  get "/test" do |env|
    q = env.params["q"]
    Offdate.create({"date" => q})
    "test"
  end
end

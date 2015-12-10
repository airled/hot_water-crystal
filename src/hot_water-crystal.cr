require "kemal"
require "mysql"
require "active_record"
require "./hot_water-crystal/*"

module HotWater::Crystal
  get "/" do
    render "views/index.ecr"
  end

  get "/date" do |env|
    #   if (params.size == 2) &&
    #      (params.has_key?('street')) && (params.has_key?('house')) &&
    #      (params[:street].match(/[^А-Яа-я0-9ё\.\ \-]/).nil?) && (params[:house].match(/[^А-Яа-яё0-9\.\ ]/).nil?)
    #        street = params[:street]
    #        house = params[:house]
    #        date = Finder.new.date_find(street, house)
    #        {date: date}.to_json
    #   else
    #     'Params error'
    #   end
    env.content_type = "application/json"
    "something will be here".to_json
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

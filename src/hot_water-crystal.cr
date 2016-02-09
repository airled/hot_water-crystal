require "./hot_water-crystal/*"
require "ambience"
require "mysql"
require "kemal"

module HotWater::Crystal
  get "/" do |env|
    render "views/index.ecr"
    # p DB.query("SELECT * FROM offdates")
    # p ENV
    # p env
  end

  # get "/auto_street" do
  #   term = params[:term]
  #   # addresses = Address.distinct.select(:street).where("street LIKE ?", "#{term}%").limit(10)
  #   # (addresses.map { |address| {id: nil, label: address.street, value: address.street} }).to_json
  #   p env
  # end
end

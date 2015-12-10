db = MySQL.connect("localhost", "root", "", "hotwater_crystal", 3306_u16, nil)

class Offdate < ActiveRecord::Model
  adapter mysql
  table_name offdates
  primary id :: Int
  field date :: String
end

class Address < ActiveRecord::Model
  adapter mysql
  table_name addresses
  primary id :: Int
  field offdate_id :: Int
  field street :: String
  field house :: String
end

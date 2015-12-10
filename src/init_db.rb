require "yaml"
require "sequel"
require "mysql2"
require './config/environment'

DB = Sequel.connect(
  adapter: 'mysql2',
  host: 'localhost',
  user: 'root',
  database: ENV['database']
)

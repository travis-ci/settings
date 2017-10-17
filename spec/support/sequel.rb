require 'sequel'

DB = Sequel.connect('postgres://localhost/settings')
DB.test_connection

Repository = Class.new(Sequel::Model(:repositories))
User = Class.new(Sequel::Model(:users))
Organization = Class.new(Sequel::Model(:organizations))

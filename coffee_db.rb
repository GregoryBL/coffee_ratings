require 'sequel'

DB = Sequel.connect('postgres://localhost/coffee')

if !DB[:users]
  create_tables
end

users = DB[:users]
roasters = DB[:roasters]
coffees = DB[:coffees]
preparations = DB[:preparations]
reviews = DB[:reviews]

def create_tables

  DB.create_table :users do 
    primary_key :id
    String :name  
  end

  DB.create_table :roasters do
    primary_key :id
    String :name
    String :city
  end

  DB.create_table :coffees do
    primary_key :id
    String :name
    String :country
    Time :roast_date
    foreign_key :roaster_id, :roasters
  end

  DB.create_table :preparations do
    primary_key :id
    String :name
    String :type
  end

  DB.create_table :reviews do
    primary_key :id
    foreign_key :user_id, :users
    foreign_key :coffee_id, :coffees
    foreign_key :preparation_id, :preparations
    String :preparer
    Time :date
    Float :rating
    String :comment
  end

end

def add_user(name)
  users.insert(:name => name)
end

def add_roaster(name, city)
  roasters.insert(:name => name, :city => city)
end

def add_coffee(name, country, roaster, roast_date = nil)
  this_roaster = roasters[:name => roaster)].select(:id)
  p this_roaster
  if !this_roaster
    add_roaster(name, "")
    this_roaster = roasters[:name => roaster)].select(:id)
  end
  coffees.insert(:name => name, :country => country, :roast_date => roast_date, :roaster => this_roaster)
end


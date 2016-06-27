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
  coffees.insert(:name => name, :country => country, :roast_date => roast_date, :roaster_id => roaster)
end

def add_preparation(name, type)
  preparations.insert(:name => name, :type => type)
end

def add_review(user, coffee, preparation, preparer, date, rating, comment)
  reviews.insert(:user_id => user, :coffee_id => coffee, :preparation_id => preparation, :preparer => preparer, :date => date, :rating => rating, :comment => comment)
end

def get_user_id(name)
  users[:name => name][:id]
end

def get_roaster_id(name)
  roasters[:name => name][:id]
end

def get_coffee_id(name)
  coffees[:name => name][:id]
end

def get_preparation_id(name)
  preparations[:name => name][:id]
end

def all_user_reviews(user)
  user_id = get_user_id(user)
  reviews.where(:id => user_id).join(:users, :id => :user_id).join(:coffees, :id => :coffee_id).join(:preparations, :id => :preparation_id)
end

def average_user_score(user)
  user_id = get_user_id(user)
  reviews.where(:id => user_id).ave(:review)
end

def average_coffee_score(coffee)
  coffee_id = get_coffee_id(coffee)
  reviews.where(:coffee => coffee_id).ave(:review)
end

def print_user_review(review)
  puts "Review of #{review[:coffee]}"
end










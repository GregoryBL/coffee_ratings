require 'sqlite3'

coffee_db = SQLite3::Database.new "coffee.db"

def create_tables(db)

  db.execute <<-SQL
  create table if not exists users (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255)
  );
  SQL

  db.execute <<-SQL
  create table if not exists roasters (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255),
  city VARCHAR(255)
  );
  SQL

  db.execute <<-SQL
  create table if not exists coffees (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255),
  country VARCHAR(255),
  roaster_id INT,
  FOREIGN KEY (roaster_id) REFERENCES roaster(id)
  );
  SQL

  db.execute <<-SQL
  create table if not exists preparations (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255),
  type VARCHAR(255)
  );
  SQL

  db.execute <<-SQL
  create table if not exists reviews (
  id INTEGER PRIMARY KEY,
  user_id INT,
  coffee_id INT,
  preparation_id INT,
  preparer VARCHAR(255),
  roast_date INT,
  review_date INT,
  rating REAL,
  comment VARCHAR(255),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (coffee_id) REFERENCES coffees(id),
  FOREIGN KEY (preparation_id) REFERENCES preparations(id)
  );
  SQL

end

def get_user_id(db, name_string)
  db.execute("SELECT id FROM users WHERE name=?", name_string)[0][:id]
end

def get_roaster_id(db, name_string)
  db.execute("SELECT id FROM roasters WHERE name=?", name_string)[0][:id]
end

def get_coffee_id(db, name_string, roaster_id = nil)
  if !roaster_id
    db.execute("SELECT id FROM coffee WHERE name=?", name_string)[0][:id]
  else
    db.execute("SELECT id FROM coffee WHERE name=? AND roaster_id=?", [name_string, roaster_id])[0][:id]
  end
end

def get_preparation_id(db, name_string)
  db.execute("SELECT id FROM preparations WHERE name=?", name_string)[0][:id]
end

def add_user(db, name)
  db.execute("INSERT INTO users (name) VALUES ?", name)
  get_user_id(db, name)
end

def add_roaster(db, name, city)
  db.execute("INSERT INTO roasters (name, city) VALUES (?, ?)", [name, city])
end

def add_coffee(db, name, country, roaster_id)
  db.execute("INSERT INTO coffees (name, country, roaster_id) VALUES (?, ?, ?, ?)", [name, country, roaster_id])
end

def add_preparation(db, name, type)
  db.execute("INSERT INTO preparations (name, type) VALUES (?, ?)", [name, type])
end

def add_review(db, user_id, coffee_id, preparation_id, preparer, roast_date, review_date, rating, comment)
  db.execute("INSERT INTO reviews (user_id, coffee_id, preparation_id, preparer, roast_date, review_date, rating, comment) VALUES (?, ?, ?, ?, ?, ?, ?)" [user_id, coffee_id, preparation_id, preparer, roast_date, review_date, rating, comment])
end

def all_roasters(db)
  db.execute("SELECT * FROM roasters")
end

def all_coffees_from_roaster(db, roaster_id)
  db.execute("SELECT * FROM coffees WHERE roaster_id = ?", roaster_id)
end

# INTERFACE

# Convenience helpers
def get_yes_no
  while true
    check_in = gets.chomp
    if check_in.downcase == 'y'
      return true
    elsif check_in.downcase == 'n'
      return false
    end
    puts "Please answer 'y' or 'n'."
  end
end

# get info for each table entry from user
def get_user
  user_valid = false
  while !user_valid
    puts "Who are you?"
    name_input = gets.chomp
    user = get_user_id(coffee_db, name_input)
    if !user
      puts "User doesn't exist. Should we create an account for you? (y/n)"
      if get_yes_no(gets.chomp)
        user = add_user(coffee_db, name)
      end
    end
    if user
      user_valid = true 
    end
  end
  user
end

def get_roaster
  roaster_valid = false
  while !roaster_valid
    puts "What roaster roasted your coffee?"
    roaster_list = list_roasters
    puts "#{roaster_list.length + 1} - Other Roaster"
    roaster_input = gets.chomp.to_i
    if roaster_input <= roaster_list.length && roaster_input > 0
      roaster = roaster_list[roaster_input - 1][:id]
      roaster_valid = true
    elsif roaster_input == roaster_list.length + 1
      puts "What is the roaster's name?"
      roaster_name = gets.chomp
      puts "In what city is #{roaster_name} located?"
      roaster_city = gets.chomp
      puts "Confirm add of #{roaster_name}, located in #{roaster_city}. (y/n)"
      if get_yes_no
        add_roaster(coffee_db, roaster_name, roaster_city)
        roaster = get_roaster_id(coffee_db, roaster_name)
        roaster_valid = true
      end
    end
  end
  roaster
end

def list_roasters
  roasters = all_roasters
  roasters.each_with_index { |roaster, ind|
    puts "#{ind + 1} - #{roaster[:name]} in #{roaster[:city]}"
  }
  roasters
end

def get_coffee
  coffee_valid = false
  while !coffee_valid
    roaster_id = get_roaster
    coffee_list = list_coffees_from_roaster
    puts "#{coffee_list.length + 1} - Other Coffee"
    coffee_input = gets.chomp.to_i
    if coffee_input <= coffee_list.length && coffee_input > 0
      coffee = coffee_list[coffee_input - 1][:id]
    elsif coffee_input == coffee_list.length + 1
      puts "What is the name of the coffee?"
      coffee_name = gets.chomp
      puts "Is the coffee a blend?"
      coffee_blend = get_yes_no
      if !coffee_blend
        puts "What is the coffee's country of origin?"
        coffee_country = gets.chomp
        puts "Confirm add of #{coffee_name} from #{coffee_country}. (y/n)"
      else
        coffee_country = "blend"
        puts "Confirm add of #{coffee_name}."
      end
      add_coffee(coffee_db, coffee_name, coffee_country, roaster_id)
      coffee = get_coffee_id(coffee_db, coffee_name, roaster_id)
    end
  end
  coffee
end

def list_coffees_from_roaster
  coffees = all_coffees_from_roaster
  coffees.each_with_index do |coffee, ind|
    if roaster[:country] == "blend" || !roaster[:country] || roaster[:country] == ""
      puts "#{ind + 1} - #{roaster[:name]} (blend)"
    else
      puts "#{ind + 1} - #{coffee[:name]} from #{coffee[:country]}"
    end
  end
  coffees
end

def get_preparation
  
end

def list_preparations

end

# main interface
def interface
  user_id = get_user
  coffee_id = get_coffee
end

create_tables(coffee_db)
interface























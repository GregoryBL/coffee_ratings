require 'sqlite3'

coffee_db = SQLite3::Database.new "coffee.db"
coffee_db.results_as_hash = true

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
  users = db.execute("SELECT id FROM users WHERE name=?", name_string)
  if users == []
    return nil
  else
    users[0]["id"]
  end
end

def user_name(db, id)
    users = db.execute("SELECT name FROM users WHERE id=?", id)
  if users == []
    return nil
  else
    users[0]["name"]
  end
end

def get_roaster_id(db, name_string)
  roasters = db.execute("SELECT id FROM roasters WHERE name=?", name_string)
  if roasters == []
    return nil
  else
    roasters[0]["id"]
  end
end

def roaster_name(db, id)
  roasters = db.execute("SELECT name FROM roasters WHERE id=?", id)
  if roasters == []
    return nil
  else
    roasters[0]["name"]
  end
end

def get_coffee_id(db, name_string, roaster_id = nil)
  if !roaster_id
    coffees = db.execute("SELECT id FROM coffees WHERE name=?", name_string)
  else
    coffees = db.execute("SELECT id FROM coffees WHERE name=? AND roaster_id=?", [name_string, roaster_id])
  end
  if coffees == []
    return nil
  else
    coffees[0]["id"]
  end
end

def coffee_name(db, id)
  coffees = db.execute("SELECT name FROM coffees WHERE id=?", id)
  if coffees == []
    return nil
  else
    coffees[0]["name"]
  end
end

def get_preparation_id(db, name_string)
  preparations = db.execute("SELECT id FROM preparations WHERE name=?", name_string)
  if preparations == []
    return nil
  else
    preparations[0]["id"]
  end
end

def preparation_name(db, id)
  preparations = db.execute("SELECT name FROM preparations WHERE id=?", id)
  if preparations == []
    return nil
  else
    preparations[0]["name"]
  end
end

def add_user(db, name)
  db.execute("INSERT INTO users (name) VALUES (?)", name)
  get_user_id(db, name)
end

def add_roaster(db, name, city)
  db.execute("INSERT INTO roasters (name, city) VALUES (?, ?)", [name, city])
  get_roaster_id(db, name)
end

def add_coffee(db, name, country, roaster_id)
  db.execute("INSERT INTO coffees (name, country, roaster_id) VALUES (?, ?, ?)", [name, country, roaster_id])
  get_coffee_id(db, name)
end

def add_preparation(db, name, type)
  db.execute("INSERT INTO preparations (name, type) VALUES (?, ?)", [name, type])
  get_preparation_id(db, name)
end

def add_review(db, user_id, coffee_id, preparation_id, preparer, review_date, roast_date, rating, comment)
  db.execute("INSERT INTO reviews (user_id, coffee_id, preparation_id, preparer, roast_date, review_date, rating, comment) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", [user_id, coffee_id, preparation_id, preparer, roast_date, review_date, rating, comment])
end

def all_roasters(db)
  db.execute("SELECT * FROM roasters")
end

def all_coffees_from_roaster(db, roaster_id)
  db.execute("SELECT * FROM coffees WHERE roaster_id = ?", roaster_id)
end

def all_preparations(db)
  db.execute("SELECT * FROM preparations")
end

def all_reviews_for_user(db, user_id)
  select = <<-SQL 
  SELECT * FROM reviews
  WHERE user_id = ? 
  SQL

  db.execute(select, user_id)
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
def get_user(db)
  user_valid = false
  while !user_valid
    puts "Who are you?"
    name_input = gets.chomp
    user = get_user_id(db, name_input)
    p "user: #{user}"
    if !user
      puts "User doesn't exist. Should we create an account for you? (y/n)"
      if get_yes_no
        user = add_user(db, name_input)
      end
    end
    if user
      user_valid = true 
    end
  end
  user
end

def get_roaster(db)
  roaster_valid = false
  while !roaster_valid
    puts "What roaster roasted your coffee?"
    roaster_list = list_roasters(db)
    puts "#{roaster_list.length + 1} - Other Roaster"
    roaster_input = gets.chomp.to_i
    if roaster_input <= roaster_list.length && roaster_input > 0
      roaster = roaster_list[roaster_input - 1]["id"]
      roaster_valid = true
    elsif roaster_input == roaster_list.length + 1
      puts "What is the roaster's name?"
      roaster_name = gets.chomp
      puts "In what city is #{roaster_name} located?"
      roaster_city = gets.chomp
      puts "Confirm add of #{roaster_name}, located in #{roaster_city}. (y/n)"
      if get_yes_no
        add_roaster(db, roaster_name, roaster_city)
        roaster = get_roaster_id(db, roaster_name)
        roaster_valid = true
      end
    end
  end
  roaster
end

def list_roasters(db)
  roasters = all_roasters(db)
  p roasters
  roasters.each_with_index { |roaster, ind|
    puts "#{ind + 1} - #{roaster["name"]} in #{roaster["city"]}"
  }
  roasters
end

def get_coffee(db)
  coffee_valid = false
  while !coffee_valid
    roaster_id = get_roaster(db)
    puts "What coffee did you drink from #{roaster_name(db, roaster_id)}"
    coffee_list = list_coffees_from_roaster(db, roaster_id)
    puts "#{coffee_list.length + 1} - Other Coffee"
    coffee_input = gets.chomp.to_i
    if coffee_input <= coffee_list.length && coffee_input > 0
      coffee = coffee_list[coffee_input - 1]["id"]
      coffee_valid = true
    elsif coffee_input == coffee_list.length + 1
      puts "What is the name of the coffee?"
      coffee_name = gets.chomp
      puts "Is the coffee a blend? (y/n)"
      coffee_blend = get_yes_no
      if !coffee_blend
        puts "What is the coffee's country of origin?"
        coffee_country = gets.chomp
        puts "Confirm add of #{coffee_name} from #{coffee_country}. (y/n)"
      else
        coffee_country = "blend"
        puts "Confirm add of #{coffee_name}. (y/n)"
      end
      if get_yes_no
        add_coffee(db, coffee_name, coffee_country, roaster_id)
        coffee = get_coffee_id(db, coffee_name, roaster_id)
        coffee_valid = true
      end
    end
  end
  coffee
end

def list_coffees_from_roaster(db, roaster_id)
  coffees = all_coffees_from_roaster(db, roaster_id)
  coffees.each_with_index do |coffee, ind|
    if coffee["country"] == "blend" || !coffee["country"] || coffee["country"] == ""
      puts "#{ind + 1} - #{coffee["name"]} (blend)"
    else
      puts "#{ind + 1} - #{coffee["name"]} from #{coffee["country"]}"
    end
  end
  coffees
end

def get_preparation(db)
  method_valid = false
  while !method_valid
    puts "How was the coffee prepared?"
    prep_list = list_preparations(db)
    puts "#{prep_list.length + 1} - Other method"
    prep_input = gets.chomp.to_i

    if prep_input <= prep_list.length && prep_input > 0
      prep_method = prep_list[prep_input - 1]["id"]
      method_valid = true
    elsif prep_input == prep_list.length + 1
      puts "What method was used to prepare this coffee?"
      prep_name = gets.chomp
      puts "Is this method automatic, pourover, percolator, press, or other?"
      prep_type = gets.chomp
      if !["automatic", "pourover", "percolator", "press"].include?(prep_type)
        prep_input = "other"
      end
      puts "Confirm add of the preparation method: #{prep_name} of type:#{prep_type} (y/n)."
      if get_yes_no
        add_preparation(db, prep_name, prep_type)
        get_preparation_id(db, prep_name)
        method_valid = true
      end
    end
  end
  prep_method
end

def list_preparations(db)
  preparations = all_preparations(db)
  preparations.each_with_index do |method, ind|
    puts "#{ind + 1} - #{method["name"]}"
  end
  preparations
end

def get_date(input = nil)
  if !input
    input_date = gets.chomp
  else
    input_date = input
  end
  input_day = input_date.to_i
  input_month = input_date[3,2].to_i
  input_year = input_date[6,4].to_i
  Time.new(input_year, input_month, input_day)
end

def make_review(db, user_id)
  coffee_id = get_coffee(db)
  prep_id = get_preparation(db)

  puts "When did you taste the coffee? (DD-MM-YYYY)"
  review_date = get_date().strftime('%s')

  puts "When was the coffee roasted? (DD-MM-YYYY or [enter] if unknown)"
  roast_date_input = gets.chomp
  if roast_date_input == ""
    roast_date = 0
  else
    roast_date = get_date(roast_date_input)
  end

  puts "Who made this coffee? (name or [enter] for unknown)"
  preparer = gets.chomp

  puts "What is your rating (1-10)?"
  rating = gets.chomp.to_i

  puts "Do you have any comments about this coffee (max 255 characters)?"
  comment = gets.chomp[0,255]

  add_review(db, user_id, coffee_id, prep_id, preparer, review_date, roast_date, rating, comment)
  puts print_review_no_username(db, coffee_id, prep_id, review_date, rating, comment)

end

def print_review(db, user_id, coffee_id, prep_id, review_date, rating, comment)
  puts "--------------------"
  puts "#{user_name(db, user_id)}'s review of #{coffee_name(db, coffee_id)} on #{Time.at(review_date).strptime('%b-%d-%Y')}:"
  print_review_no_header(db, prep_id, rating, comment)
end

def print_review_no_username(db, coffee_id, prep_id, review_date, rating, comment)
  puts "--------------------"
  puts "Review of #{coffee_name(db, coffee_id)} on #{Time.at(review_date).strftime('%b-%d-%Y')}:"
  print_review_no_header(db, prep_id, rating, comment)
end

def print_review_no_header(db, prep_id, rating, comment)
  puts "Method: #{preparation_name(db, prep_id)}"
  puts "Rating: #{rating}"
  puts "Notes: #{comment}"
end

def print_all_user_reviews(db, user_id)
  all_reviews = all_reviews_for_user(db, user_id)
  puts "--------------------"
  puts "All reviews for #{user_name(db, all_reviews[0]['id'])}:"
  all_reviews.each do |review|
    coffee_id = review["coffee_id"]
    prep_id = review["prep_id"]
    review_date = review["review_date"]
    rating = review["rating"]
    comment = review["comment"]
    print_review_no_username(db, coffee_id, prep_id, review_date, rating, comment)
  end
end

def print_all_roaster_reviews(db, roaster_id)

end
# main interface
def interface(db)
  user_id = get_user(db)
  while true
    puts "--------------------"
    puts "What would you like to do?"
    puts "1 - Make a review"
    puts "2 - See all of your reviews"
    puts "3 - See all reviews of a roaster"
    puts "4 - End"
    menu_choice = gets.chomp.to_i
    case menu_choice
    when 1
      make_review(db, user_id)
    when 2
      print_all_user_reviews(db, user_id)
    when 3
      roaster_id = get_roaster(db)
      print_all_roaster_reviews(db, roaster_id)
    when 4
      break
    end
  end
  puts "Thanks for using Coffee Reviews!"
end

create_tables(coffee_db)
interface(coffee_db)























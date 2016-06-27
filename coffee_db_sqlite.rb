require_relative 'coffee_db_sqlite_setup'
require_relative 'coffee_db_sqlite_accessors'
require_relative 'coffee_db_sqlite_interface_accessors'

# larger getters

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

def all_reviews_for_roaster(db, roaster_id)
  select = <<-SQL 
  SELECT * FROM reviews
  JOIN coffees ON coffees.id = reviews.coffee_id
  WHERE roaster_id = ? 
  SQL
  db.execute(select, roaster_id)
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

# printers

def print_review(db, user_id, coffee_id, prep_id, review_date, rating, comment)
  puts "--------------------"
  puts "#{user_name(db, user_id)}'s review of #{coffee_name(db, coffee_id)} on #{Time.at(review_date).strftime('%b-%d-%Y')}:"
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
  puts "All reviews for #{user_name(db, user_id)}:"
  all_reviews.each do |review|
    coffee_id = review["coffee_id"]
    prep_id = review["preparation_id"]
    review_date = review["review_date"]
    rating = review["rating"]
    comment = review["comment"]
    print_review_no_username(db, coffee_id, prep_id, review_date, rating, comment)
  end
end

def print_all_roaster_reviews(db, roaster_id)
  all_reviews = all_reviews_for_roaster(db, roaster_id)
  puts "--------------------"
  puts "All reviews for #{roaster_name(db, roaster_id)}:"
  all_reviews.each do |review|
    user_id = review["user_id"]
    coffee_id = review["coffee_id"]
    prep_id = review["preparation_id"]
    review_date = review["review_date"]
    rating = review["rating"]
    comment = review["comment"]
    print_review(db, user_id, coffee_id, prep_id, review_date, rating, comment)
  end
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

create_tables($coffee_db)
interface($coffee_db)























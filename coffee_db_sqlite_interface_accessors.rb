def get_user(db)
  user_valid = false
  while !user_valid
    puts "Who are you?"
    name_input = gets.chomp
    user = get_user_id(db, name_input)
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

  add_review(db, user_id, coffee_id, prep_id, preparer, review_date, roast_date.strftime('%s'), rating, comment)
  print_review_no_username(db, coffee_id, prep_id, review_date, rating, comment)

end
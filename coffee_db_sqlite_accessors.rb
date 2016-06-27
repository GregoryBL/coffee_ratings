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
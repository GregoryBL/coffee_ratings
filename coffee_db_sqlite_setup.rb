require 'sqlite3'

$coffee_db = SQLite3::Database.new "coffee.db"
$coffee_db.results_as_hash = true

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
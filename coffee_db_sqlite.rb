require 'sqlite3'

coffee_db = SQLite3::Database.new "test.db"

def create_tables

  coffee_db.execute <<-SQL
    create table if not exists users (
    id INTEGER PRIMARY KEY,
    name VARCHAR(255)
    );
  SQL

  coffee_db.execute <<-SQL
    create table if not exists roasters (
    id INTEGER PRIMARY KEY,
    name VARCHAR(255),
    city VARCHAR(255)
    );
  SQL

  coffee_db.execute <<-SQL
    create table if not exists coffees (
    id INTEGER PRIMARY KEY,
    name VARCHAR(255),
    country VARCHAR(255),
    roast_date INT,
    roaster_id INT,
    FOREIGN KEY (roaster_id) REFERENCES roaster(id)
    );
  SQL

  coffee_db.execute <<-SQL
    create table if not exists preparations (
    id INTEGER PRIMARY KEY,
    name VARCHAR(255),
    type VARCHAR(255)
    );
  SQL

  coffee_db.execute <<-SQL
    create table if not exists reviews (
    id INTEGER PRIMARY KEY,
    user_id INT,
    coffee_id INT,
    preparation_id INT,
    preparer VARCHAR(255),
    review_date INT
    rating REAL,
    comment VARCHAR(255)
    );
  SQL

end
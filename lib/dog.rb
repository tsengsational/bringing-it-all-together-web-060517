require "pry"

class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
      sql = <<-SQL
      DROP TABLE dogs;
      SQL
      DB[:conn].execute(sql)
  end

  def save
    if self.id == nil
      id_query = "SELECT COUNT(*) FROM dogs;"
      @id = DB[:conn].execute(id_query).flatten[0] + 1
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
      arr = DB[:conn].execute(sql, [self.name, self.breed])
    else
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      arr = DB[:conn].execute(sql, [self.name, self.breed, self.id])
    end
    self
  end

  def self.create(name:, breed:)
    # binding.pry
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?
    SQL
    dog_arr = DB[:conn].execute(sql, id).first
    dog = self.new(name: dog_arr[1], breed: dog_arr[2], id: dog_arr[0])
    # binding.pry
    dog
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    # find the dog whose name and breed match the input
    dog_arr = DB[:conn].execute(sql, name, breed).first
    # binding.pry
    # if the dog exists
    if dog_arr != nil
      dog = self.new(name: dog_arr[1], breed: dog_arr[2], id: dog_arr[0])
    else
      self.create(name: name, breed: breed)
    end
  end

  def self.new_from_db(row)
    self.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL
    dog_arr = DB[:conn].execute(sql, name).first
    dog = self.new(name: dog_arr[1], breed: dog_arr[2], id: dog_arr[0])
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end

# Pry.start

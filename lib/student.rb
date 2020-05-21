require_relative "../config/environment.rb"
require 'pry'
class Student
  @@all=[]
  attr_accessor :name, :grade, :id
  def initialize(name, grade, id=nil)
    @name=name
    @grade=grade
    @id=id
    @@all << self
  end

  def self.create_table
    sql=<<-SQL
    create table if not exists students(
      id integer primary key,
      name text,
      grade text
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
  DB[:conn].execute("drop table students")
  end

  def save
    if @id
      self.update
    else
      sql=<<-SQL
      insert into students (name, grade) values (?,?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
    end
    @id=DB[:conn].execute("select last_insert_rowid() from students")[0][0]
  end
  def self.create(name, grade)
    s=Student.new(name, grade)
    s.save
  end

  def update
    DB[:conn].execute("update students set name=? , grade = ? where id = ?", self.name, self.grade, self.id)
  end

  def self.new_from_db(row)
    self.new(row[1], row[2], row[0])
  
  end

  def self.find_by_name(name)
    DB[:conn].execute("select * from students where name= ?", name).map do |row|
  self.new_from_db(row)
     
    end.first
  end

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]binding.pry
  

end

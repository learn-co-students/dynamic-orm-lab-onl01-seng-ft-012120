require_relative "../config/environment.rb"
require 'active_support/inflector'

# class Student < InteractiveRecord
#   self.column_names.each do |col_name|
#       attr_accessor col_name.to_sym
#     end
# end


class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end   
  
  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end   
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end
  
  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end
  
  def table_name_for_insert
    self.class.table_name
  end
  
  def col_names_for_insert 
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end   
  
  def values_for_insert 
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end   
  
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end
  require 'pry' 
  def self.find_by(input)
    #binding.pry input= 1 change to string
    column = input.keys[0].to_s
    value = input.values[0]
    
      sql = "SELECT * FROM #{self.table_name} WHERE #{column} = ?"
      DB[:conn].execute(sql, value)
  end 
  
end
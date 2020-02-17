require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    array = DB[:conn].execute("pragma table_info(#{self.table_name})").collect do |hash|
      hash['name']
    end
    array.compact
  end

  self.column_names.each do |attr|
    attr_accessor attr.to_sym
  end

  def initialize(options={})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.collect do |col|
      col unless col == 'id'
    end.compact.join(', ')
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col|
      values << "'#{self.send(col)}'" unless self.send(col).nil?
    end
    values.join(', ')
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.class.table_name}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
    
  end
   
  def self.find_by(hash)
    col = hash.keys[0].to_s
    value = hash[hash.keys[0]]
    DB[:conn].execute("SELECT * FROM students WHERE #{col} = '#{value}'")
  end
  
end
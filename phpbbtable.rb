# Define class that looks up data in the XMB table

class PTable
	# creates reader methods for these instance variables
	attr_reader :table_name, :pkey, :columns

	def initialize(t)
		@table_name = t
		@pkey = PHPBB_DB.query("SHOW KEYS FROM #{t} WHERE Key_name = 'PRIMARY'").first['Column_name']
		@columns = PHPBB_DB.query("DESCRIBE #{t}").map {|h| h['Field']}
	end

	def [](id)
		PHPBB_DB.query("SELECT * FROM #{@table_name} WHERE #{@pkey} = #{id}").first.to_h
	end

	def find_by(column, value)
		PHPBB_DB.query("SELECT * FROM #{@table_name} WHERE #{column} = '#{value}' LIMIT 1").first.to_h
	end

	def max(column=@pkey)
		PHPBB_DB.query("SELECT MAX(#{column}) FROM #{@table_name}").first.values[-1]
	end
end
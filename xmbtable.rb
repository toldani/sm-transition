# Define class that looks up data in the XMB table

class XTable
	# creates reader methods for these instance variables
	attr_reader :table_name, :pkey, :columns

	def initialize(t)
		@table_name = t
		@pkey = XMB_DB.query("SHOW KEYS FROM #{t} WHERE Key_name = 'PRIMARY'").first['Column_name']
		@columns = XMB_DB.query("DESCRIBE #{t}").map {|h| h['Field']}
	end

	def [](id)
		XMB_DB.query("SELECT * FROM #{@table_name} WHERE #{@pkey} = #{id}").first.to_h
	end

	def find_by(column, value)
		XMB_DB.query("SELECT * FROM #{@table_name} WHERE #{column} = '#{value}' LIMIT 1").first.to_h
	end

	def max(column=@pkey)
		XMB_DB.query("SELECT MAX(#{column}) FROM #{@table_name}").first.values[-1]
	end
end
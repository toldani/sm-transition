# Define class that looks up data in the XMB table

class XMBTable
	def initialize(t)
		@table_name = t
		@pkey = XMB_DB.query("SHOW KEYS FROM #{t} WHERE Key_name = 'PRIMARY'").first['Column_name']
	end

	def [](id)
		XMB_DB.query("SELECT * FROM #{@table_name} WHERE #{@pkey} = #{id}").first.to_h
	end

	def find_by(column, value)
		XMB_DB.query("SELECT * FROM #{@table_name} WHERE #{column} = '#{value}' LIMIT 1").first.to_h
	end
end
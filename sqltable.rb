# Define class that looks up data in SQL tables

class SQLTable
	include Enumerable

	# creates reader methods for these instance variables
	attr_reader :table_name, :pkey, :columns, :db

	# store a bunch of useful data in instance variables (database, table name, primary key, array of
	# column names, number of rows inserted)
	def initialize(t)
		@db = t.split('_')[0] == 'sm' ? PHPBB_DB : XMB_DB
		@table_name = t
		@pkey = @db.query("SHOW KEYS FROM #{t} WHERE Key_name = 'PRIMARY'").first['Column_name'] rescue nil
		@columns = @db.query("DESCRIBE #{t}").map {|h| h['Field']}
	end

	def inspect
		clist = @columns.map {|s| @pkey == s ? "\e[1m#{s} (PK)\e[0m" : s} * "\n\t"
		"\n\e[92m#{@table_name}\e[0m (#{self.class}, #{count} row#{"s" if count != 1}): \n\t#{clist}\n"
	end

  def random
  	h = {}
		while h.empty?
    	h = @db.query("SELECT * FROM #{@table_name} WHERE #{@pkey} = #{rand(max)}").first.to_h
		end
    return h
  end

	# puts some default values in the initial hash that's used as a template for inserting rows
	def default_row
		if @default_row.nil?
			@default_row = {}
			ar = @db.query("DESCRIBE #{@table_name}").to_a
			no_default = ar.select {|r| r['Null'] == "NO" && r['Default'].nil?}
			no_default.each do |h|
				@default_row[h['Field']] = guess_column_default(h['Type'])
			end
			puts @default_row.inspect
		end

		return @default_row
	end

	# returns non-empty rows in the order of their primary keys
	def each
		(1..self.max).each do |n|
			next if self[n].nil? || self[n].empty?
			yield self[n]
		end
	end


	# allows you to reference a row using the table's primary key
	def [](id)
		if @pkey.nil?
			nil
		else
			@db.query("SELECT * FROM #{@table_name} WHERE #{@pkey} = #{id}").first.to_h
		end
	end

	# look up a value in the the specified column. does not check for duplicates.
	def find_by(column, value)
		@db.query("SELECT * FROM #{@table_name} WHERE #{column} = #{sanitize(value)} LIMIT 1").first.to_h
	end

	# get a bunch of records that match a value of a single record (column_name: value, other_table_name: other_column_name)
	def where(*cols, **conditions)
		q = conditions.map {|k,v| "#{k} = #{sanitize(v)}"} * ' AND '
		c = (cols & @columns) * ', '
		c = "*" if c.empty?
		puts q
		return @db.query("SELECT #{c} FROM #{@table_name} WHERE #{q}").to_a
	end

	# get the maximum number stored in a column. default to primary key if no column is specified
	def max(column=@pkey)
		@db.query("SELECT MAX(#{column}) FROM #{@table_name}").first.values[-1]
	end

	# count the rows in a table
	def count
		@db.query("SELECT COUNT(*) FROM #{@table_name}").first.values[-1]
	end

protected

	# check if a table is from XMB before attempting to write to it
	#def can_write?(t=@table_name)
	#	return PHPBB_TABLES.include?(t)
	#end

end
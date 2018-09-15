# Define class that looks up data in SQL tables

class SQLTable
	include Enumerable

	@@rows_written = 0

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
				@default_row[h['Field']] = self.class.guess_column_default(h['Type'])
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
		@db.query("SELECT * FROM #{@table_name} WHERE #{column} = #{SQLTable.sanitize(value)} LIMIT 1").first.to_h
	end

	# get a bunch of records that match a value of a single record (column_name: value, other_table_name: other_column_name)
	def where(*cols, **conditions)
		q = conditions.map {|k,v| "#{k} = #{SQLTable.sanitize(v)}"} * ' AND '
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

	# write a row to the specified table. data is supplied as a hash, where key names correspond to column names
	def self.insert_record(r)
		# if the hash keys are all valid writable table names, then write rows to multiple tables
		return nil if (r.keys & PHPBB_TABLES) != r.keys

		r.each_pair do |t,h|
			h.delete_if {|k,v| v.nil?}
			vstring = h.values.map {|g| self.sanitize(g)} * ', '
			kstring = h.keys * ', '
			q = "INSERT INTO #{t} (#{kstring}) VALUES (#{vstring})"
			begin
				PHPBB_DB.query(q)
			rescue Mysql2::Error => e
				puts e
				next
			end

			if @@rows_written < 100 || @@rows_written % 20 == 0 # only output 1/10 of writes to the console after the first 100 writes
				puts "Wrote \e[32m#{h}\e[0m to \e[36m#{t}\e[0m"
			end
		end
		@@rows_written += 1
	end

	# class variables follow
	# format a value for assigment in SQL
	def self.sanitize(v)
		if v.is_a?(Numeric)
			return v.to_s
		elsif v.is_a?(String)
			return "'#{PHPBB_DB.escape(v)}'"
		end
	end

	# returns an empty value, corresponding to the data type of the column
	def self.guess_column_default(y)
		y = y['Type'] if y.is_a?(Hash)

		if !!y[/(char\(\d+\)|text)/] # column contains string
			return ""
		elsif !!y[/int\(\d+\)/] # column contains a type of int
			return 0
		else
			return 0.0
		end
	end

	# get SQLTable object by passing in table name as a string
	def self.lookup(str)
		d, t = str.match(/^(xmb|sm)_(\w+)/).captures
		if d == "xmb"
			return XMB[t]
		elsif d == "sm"
			return PHPBB[t]
		end
	end

#protected

	# check if a table is from XMB before attempting to write to it
	#def can_write?(t=@table_name)
	#	return PHPBB_TABLES.include?(t)
	#end

end
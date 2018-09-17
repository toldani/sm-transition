#
# sm_transition.rb
#
# Functions and constants that are needed for database conversion, from XMB to phpBB
#

require 'digest' # For MD5 and CRC hashing.  The gem 'digest-crc' needs to be installed to allow CRC hashing
require 'mysql2' # Ruby MySQL interface gem
require 'fileutils' # File utilities
require 'cgi' # Misc. network functions
require 'yaml' # useful for text parsing and other things

# The XMB database, running in a virtual machine.  Port forwarding is set up to allow communication
XMB_DB = Mysql2::Client.new(host: "127.0.0.1", username: "root", password: "science", port: 3333, database: "science_xmb1")
XMB_TABLES = XMB_DB.query("SHOW TABLES").to_a.map {|h| h.flatten[1]} # array of xmb table names

# The phpBB database, running on the local non-virtual machine.
PHPBB_DB = Mysql2::Client.new(host: "127.0.0.1", username: "sm", password: "science", port: 3306, database: "sm_phpbb")
PHPBB_TABLES = PHPBB_DB.query("SHOW TABLES").to_a.map {|h| h.flatten[1]} # array of phpbb table names

require './sqltable.rb'
require './usertable.rb'
require './posttable.rb'
require './attachmenttable.rb'

# calling .to_i on true or false will return 1 or 0
class FalseClass; def to_i; 0 end end
class TrueClass; def to_i; 1 end end

@table_class = Hash.new(SQLTable)
@table_class.merge!("users" => UserTable, "members" => UserTable, "posts" => PostTable, "attachments" => AttachmentTable)

# Automatically initialize a SQLTable object for each table in the XMB db
XMB = {}
XMB_TABLES.each do |t|
	n = t[/(?<=xmb_).+/]
  xt = @table_class[n].new(t)
  next if xt.count.nil? || xt.count == 0
  puts "Building XMB['#{n}'] ... #{xt.count} rows"
	XMB[n] = xt
  XMB.define_singleton_method(n.to_sym) { self.fetch(n) }
end

# Automatically initialize a SQLTable object for each table in the PHPBB db
PHPBB = {}
PHPBB_TABLES.each do |t|
	n = t[/(?<=sm_).+/]
  puts "Building PHPBB['#{n}'] ..."
	PHPBB[n] = @table_class[n].new(t)
  PHPBB.define_singleton_method(n.to_sym) { self.fetch(n) }
end


=begin
# Defining some objects to help interface with the XMB tables
X_MEMBERS = MySQLTable.new('xmb_members')
X_THREADS = MySQLTable.new('xmb_threads')
X_POSTS = MySQLTable.new('xmb_posts')
X_ATTACH = MySQLTable.new('xmb_attachments')
X_POSTS = MySQLTable.new('xmb_posts')

# Defining some objects to help interface with the phpBB tables
P_USERS = MySQLTable.new('sm_users')
P_PFD = MySQLTable.new('sm_profile_fields_data')
P_TOPICS = MySQLTable.new('sm_topics')
P_POSTS = MySQLTable.new('sm_posts')
P_ATTACH = MySQLTable.new('sm_attachments')
=end



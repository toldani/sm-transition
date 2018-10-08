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
require 'bb-ruby' # parse bbcode tags in ruby

require './x2p.rb'
include X2P

require './sqltable.rb'
require './usertable.rb'
require './posttable.rb'
require './attachmenttable.rb'
require './threadtable.rb'

# calling .to_i on true or false will return 1 or 0
class FalseClass; def to_i; 0 end end
class TrueClass; def to_i; 1 end end

@table_class = Hash.new(SQLTable)
@table_class.merge!("users" => UserTable, "members" => UserTable, "posts" => PostTable, "attachments" => AttachmentTable, "threads" => ThreadTable)

# Automatically initialize a SQLTable object for each table in the XMB db
if XMB_DB
  XMB = {}
  XMB_TABLES.each do |t|
  	n = t[/(?<=xmb_).+/]
    xt = @table_class[n].new(t)
    next if xt.count.nil? || xt.count == 0
    puts "Building XMB['#{n}'] ... #{xt.count} rows"
  	XMB[n] = xt
    XMB.define_singleton_method(n.to_sym) { self.fetch(n) }
  end
end

# Automatically initialize a SQLTable object for each table in the PHPBB db
if PHPBB_DB
  PHPBB = {}
  PHPBB_TABLES.each do |t|
  	n = t[/(?<=sm_).+/]
    puts "Building PHPBB['#{n}'] ..."
  	PHPBB[n] = @table_class[n].new(t)
    PHPBB.define_singleton_method(n.to_sym) { self.fetch(n) }
  end
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



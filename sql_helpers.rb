#
# xmb.rb
#
# Functions and constants that are needed for database conversion, from XMB to phpBB
#

require 'digest' # For MD5 and CRC hashing.  The gem 'digest-crc' needs to be installed to allow CRC hashing
require 'mysql2' # Ruby MySQL interface gem
require 'fileutils' # File utilities
require 'cgi' # Misc. network functions

# Regular expression for matching [rquote] bbcode tags
RQUOTE_RX = /\[rquote\=(\d+)&amp;tid=(\d+)&amp;author=(.*?)\]/

# The XMB database, running in a virtual machine.  Port forwarding is set up to allow communication
XMB_DB = Mysql2::Client.new(host: "127.0.0.1", username: "root", password: "science", port: 3333, database: "science_xmb1")
require './xmbtable.rb'

# The phpBB database, running on the local non-virtual machine.
PHPBB_DB = Mysql2::Client.new(host: "127.0.0.1", username: "sm", password: "science", port: 3306, database: "sm_phpbb")
require './phpbbtable.rb'

XMB_USERS = XMBTable.new('xmb_members')
XMB_POSTS = XMBTable.new('xmb_posts')

# generates the email hash that's stored in the phpbb users table
def email_hash(email)
	return nil if email.nil?
  Digest::CRC32.checksum(email.downcase).to_s + email.length.to_s
end

# return a post with all the rquote tags fixed and replaced with phpbb quote tags
def rquote_fix(post)
  str = post.gsub(RQUOTE_RX) do |m|
  	pid, tid, username = RQUOTE_RX.match(m).captures
  	post_time = XMB_POSTS[pid]['dateline']
  	uid = XMB_USERS.find_by('username', username)['uid']
  	"[quote=#{username} post_id=#{pid} time=#{post_time} user_id=#{uid}]"
  end
  str.gsub("[/rquote]", "[/quote]")
end
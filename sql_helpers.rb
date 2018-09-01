#
# xmb.rb
#
# Functions and constants that are needed for database conversion, from XMB to phpBB
#

require 'digest' # For MD5 and CRC hashing.  The gem 'digest-crc' needs to be installed to allow CRC hashing
require 'mysql2' # Ruby MySQL interface gem
require 'fileutils' # File utilities
require 'cgi' # Misc. network functions

# The following maps the XMB member fields to their corresponding fields in sm_users. Note that this only contains the
# fields that can be moved with no changes necessary.
USERS_MAP = {"uid" => "user_id", "username" => "username", "regip" => "user_ip", "regdate" => "user_regdate",
	"lastvisit" => "user_lastvisit", "email" => "user_email", "password" => "user_password", "postnum" => "user_posts",
	"sig" => "user_sig", "bday" => "user_birthday" }

# The following maps the XMB fields to their corresponding fileds in sm_profile_fields_data
PROFILE_FIELDS_DATA_MAP = {"uid" => "user_id", "location" => "pf_phpbb_location", "site" => "pf_phpbb_website", "mood" => "pf_mood", "bio" => "pf_bio"}

# Regular expression for matching [rquote] bbcode tags
RQUOTE_RX = /\[rquote\=(\d+)&amp;tid=(\d+)&amp;author=(.*?)\]/

# The XMB database, running in a virtual machine.  Port forwarding is set up to allow communication
XMB_DB = Mysql2::Client.new(host: "127.0.0.1", username: "root", password: "science", port: 3333, database: "science_xmb1")
require './xmbtable.rb'

# The phpBB database, running on the local non-virtual machine.
PHPBB_DB = Mysql2::Client.new(host: "127.0.0.1", username: "sm", password: "science", port: 3306, database: "sm_phpbb")
require './phpbbtable.rb'

# Defining some objects to help interface with the XMB tables
X_MEMBERS = XTable.new('xmb_members')
X_THREADS = XTable.new('xmb_threads')
X_POSTS = XTable.new('xmb_posts')

# Defining some objects to help interface with the phpBB tables
P_USERS = PTable.new('sm_users')
P_PFD = PTable.new('sm_profile_fields_data')
P_TOPICS = PTable.new('sm_topics')
P_POSTS = PTable.new('sm_posts')

# # get a list of column names for a table in either database
# def get_columns(t)
# 	if t.match?(/^xmb_/)
# 		return XMB_DB.query("DESCRIBE #{t}").map {|h| h['Field']}
# 	else
# 		return PHPBB_DB.query("DESCRIBE #{t}").map {|h| h['Field']}
# 	end
# end

# generates the email hash that's stored in the phpbb users table
def email_hash(email)
	return nil if email.nil?
  Digest::CRC32.checksum(email.downcase).to_s + email.length.to_s
end

# return a post with all the rquote tags fixed and replaced with phpbb quote tags
def rquote_fix(post)
  str = post.gsub(RQUOTE_RX) do |m|
  	pid, tid, username = RQUOTE_RX.match(m).captures
  	post_time = X_POSTS[pid]['dateline']
  	uid = X_MEMBERS.find_by('username', username)['uid']
  	"[quote=#{username} post_id=#{pid} time=#{post_time} user_id=#{uid}]"
  end
  str.gsub("[/rquote]", "[/quote]")
end

def sql_clean(v)
	if v.is_a?(Numeric)
		return v.to_s
	elsif v.is_a?(String)
		return "'#{v}'"
	end
end

# write a row to the specified table
def insert_phpbb_row(table, h)
	h.delete_if {|k,v| v.nil?}
	vstring = h.values.map {|g| sql_clean(g)} * ', '
	q = "INSERT INTO #{table} (#{h.keys * ', '}) VALUES (#{vstring})"
	puts q
	PHPBB_DB.query(q).inspect
end

# put an XMB user record into a hash that can be inserted into the corresponding phpbb table
def convert_xmb_user(u,debug=false)
	if u.is_a?(Integer)
		u = X_MEMBERS[u]
	end

	user = {"username_clean" => u['username'].downcase, "user_email_hash" => email_hash(u['email']), "user_permissions" => ""}
	USERS_MAP.each_pair {|k,v| user[v] = u[k]}
	
	if user['username'].to_s == ""
		puts "User ##{user['user_id']} is null. Aborting.\n"
	else
		pfd = {}
		PROFILE_FIELDS_DATA_MAP.each_pair {|k,v| pfd[v] = u[k]}

		if debug
			puts user
			puts pfd
			return [user, pfd]
		else
			insert_phpbb_row('sm_users2', user)
			insert_phpbb_row('sm_profile_fields_data', pfd)
		end
	end
end

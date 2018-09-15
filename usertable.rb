# has special methods unique to users tables

class UserTable < SQLTable

	# The following maps the XMB member fields to their corresponding fields in sm_users. Note that this only contains the
	# fields that can be moved with no changes necessary.
	USERS_MAP = {"uid" => "user_id", "username" => "username", "regip" => "user_ip", "regdate" => "user_regdate",
		"lastvisit" => "user_lastvisit", "email" => "user_email", "password" => "user_password", "postnum" => "user_posts",
		"sig" => "user_sig", "bday" => "user_birthday"}	

	# The following maps the XMB fields to their corresponding fileds in sm_profile_fields_data
	PROFILE_FIELDS_DATA_MAP = {"uid" => "user_id", "location" => "pf_phpbb_location", "site" => "pf_phpbb_website", 
    "mood" => "pf_mood", "bio" => "pf_bio"}

  # For tables of users, allows passing a string in square brackets to look up a row by username
	def [](id)
		if id.is_a?(String)
			@db.query("SELECT * FROM #{@table_name} WHERE username = '#{id}'").first.to_h
		else
			super
		end
	end

	# put an XMB user record into a hash that can be inserted into the corresponding phpbb table
	def import_user(id,debug=false)
		# if u.is_a?(Integer)
		# 	u = self[u]
		# elsif u.is_a?(String)
		# 	u = self.find_by('username', u)
		# end
		u = self[id]

    return nil if u.empty?

		user = default_row.merge("username_clean" => u['username'].downcase, "user_email_hash" => email_hash(u['email']))
		USERS_MAP.each_pair {|k,v| user[v] = u[k]}
		
		if user['username'].to_s == ""
			puts "User ##{user['user_id']} is null. Aborting.\n"
		else
			fields = %w"interests occupation location youtube facebook skype twitter website"
			pfd = fields.inject({}) {|h,s| h.merge("pf_phpbb_#{s}" => "")}
			PROFILE_FIELDS_DATA_MAP.each_pair {|k,v| pfd[v] = u[k]}

			if debug
				puts user
				puts pfd
				return [user, pfd]
			else
				# insert_phpbb_row('sm_users2', user)
				# insert_phpbb_row('sm_profile_fields_data', pfd)
				puts [user, pfd] if user['user_id'] % 20 == 0
				return {'sm_users' => user, 'sm_profile_fields_data' => pfd}
			end
		end
	end

private

	# generates the email hash that's stored in the phpbb users table
	def email_hash(email)
		return nil if email.nil? || email.empty?
	  (Digest::CRC32.checksum(email.downcase).to_s + email.length.to_s).to_i
	end

end
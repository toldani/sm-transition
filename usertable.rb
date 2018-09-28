# has special methods unique to users tables

class UserTable < SQLTable

  # For tables of users, allows passing a string in square brackets to look up a row by username
	def [](id)
		if id.is_a?(String)
			@db.query("SELECT * FROM #{@table_name} WHERE username = '#{id}'").first.to_h
		else
			super
		end
	end

	# put an XMB user record into a hash that can be inserted into the corresponding phpbb table
	def to_phpbb(id)
		# if u.is_a?(Integer)
		# 	u = self[u]
		# elsif u.is_a?(String)
		# 	u = self.find_by('username', u)
		# end
		u = XMB.members[id]

    return nil if u.empty?

    user = {
    	user_id: u['uid'],
			user_type: 0,
			group_id: 3,
			user_permissions: "",
			user_ip: u['regip'],
			user_regdate: u['regdate'],
			username: u['username'],
			username_clean: u['username'].downcase,
			user_password: u['password'],
			user_email: u['email'],
			user_email_hash: email_hash(u['email']),
			user_birthday: u['bday'],
			user_lastvisit: u['lastvisit'],
			user_posts: u['postnum'],
			user_sig: u['sig'].to_s
		}

		pfd = {
			user_id: u['uid'],
			pf_phpbb_interests: "",
			pf_phpbb_occupation: "",
			pf_phpbb_location: u['location'],
			pf_phpbb_youtube: "",
			pf_phpbb_facebook: "",
			pf_phpbb_skype: "",
			pf_phpbb_twitter: "",
			pf_phpbb_website: u['site'],
			pf_mood: u['mood'],
			pf_bio: u['bio']
		}

		return {'sm_users' => user, 'sm_profile_fields_data' => pfd}
	end

private

	# generates the email hash that's stored in the phpbb users table
	def email_hash(email)
		return nil if email.nil? || email.empty?
	  (Digest::CRC32.checksum(email.downcase).to_s + email.length.to_s).to_i
	end

end
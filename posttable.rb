# has special methods unique to post tables

class PostTable < SQLTable

	# given an id for an XMB forum, return the columns and values in phpBB format using XMB data
	def to_phpbb(post)
		if post.is_a?(Hash)
			x = post
		else
			x = self[post]
		end

		pid = x['pid']

		u = XMB.members[x['author']]

		has_attach = !!PHPBB.attachments.find_by('post_msg_id', pid)

		rquote_regex = /\[rquote\=(\d+)&amp;tid=\d+&amp;author=(.*?)\]/

		text = x['message'].gsub(rquote_regex) do |m|
			pid, username = RQUOTE_RX.match(m).captures
	  	post_time = XMB.posts[pid]['dateline']
	  	uid = XMB.members[username]['uid']
			"[quote=#{username} post_id=#{pid} time=#{post_time} user_id=#{uid}]"
		end

		text.gsub!("[/rquote]", "[/quote]")

		h = {
			post_id: x['pid'],
			topic_id: x['tid'],
			forum_id: X2P_FID[x['fid']],
			poster_id: u['uid'],
			icon_id: POST_ICONS[x['icon']].to_s,
			poster_ip: x['useip'],
			post_time: x['dateline'],
			post_reported: 0,
			enable_bbcode: SHITTY_XMB_LOGIC[x['bbcodeoff']],
			enable_smilies: SHITTY_XMB_LOGIC[x['smileyoff']],
			enable_magic_url: 1,
			enable_sig: SHITTY_XMB_LOGIC[x['usesig']]^1,
			post_username: u['username'],
			post_subject: x['subject'],
			post_text: text,
			post_checksum: "",
			post_attachment: has_attach.to_i,
			bbcode_bitfield: "",
			bbcode_uid: "",
			post_postcount: 1,
			post_edit_time: 0,
			post_edit_reason: "",
			post_edit_user: 0,
			post_edit_count: 0,
			post_edit_locked: 0,
			post_visibility: 1,
			post_delete_time: 0,
			post_delete_reason: "",
			post_delete_user: 0
		}

		return {"sm_posts" => h}
	end

end
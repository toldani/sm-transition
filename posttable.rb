require './sm_transition.rb'

# has special methods unique to post tables
class PostTable < SQLTable

	# given a thread id, return all the posts in that thread converted for phpBB
	def to_phpbb(tid)

		# if post.is_a?(Hash)
		# 	x = post
		# else
		# 	x = self[post]
		# end

		# z = x['pid']

		# u = XMB.members[x['author']]

		# has_attach = !PHPBB.attachments.find_by('post_msg_id', z).empty?

		q = "SELECT xmb_posts.*, xmb_members.uid, xmb_attachments.aid FROM xmb_posts 
					LEFT JOIN xmb_members ON xmb_posts.author = xmb_members.username
					LEFT JOIN xmb_attachments ON xmb_posts.pid = xmb_attachments.pid
					WHERE xmb_posts.tid = #{tid} GROUP BY xmb_posts.pid"
		post_array = XMB_DB.query(q).to_a

		row_list = []

		rquote_regex = /\[rquote\=(\d+)&amp;tid=\d+&amp;author=.*?\]/

		post_array.each do |x|
			text = x['message'].gsub(rquote_regex) do |m|
				begin
					pid = rquote_regex.match(m).captures.first.to_i
					quoted_post = post_array.find {|z| z['pid'] == pid}
					"[quote=#{quoted_post['author']} post_id=#{pid} time=#{quoted_post['dateline']} user_id=#{quoted_post['uid']}]"
				rescue => e
					puts "Error #{e} when replacing rquote tag"
					"[quote]"
				end
			end

			text.gsub!("[/rquote]", "[/quote]")

			text = CGI.unescape_html(text).gsub(/\\(?=['"])/, '')

			h = {
				post_id: x['pid'],
				topic_id: x['tid'],
				forum_id: X2P_FID[x['fid']],
				poster_id: x['uid'],
				icon_id: POST_ICONS[x['icon']],
				poster_ip: x['useip'],
				post_time: x['dateline'],
				post_reported: 0,
				enable_bbcode: bool2int(x['bbcodeoff'], invert: true),
				enable_smilies: bool2int(x['smileyoff'], invert: true),
				enable_magic_url: 1,
				enable_sig: bool2int(x['usesig']),
				post_username: x['author'],
				post_subject: x['subject'],
				post_text: text,
				post_checksum: "",
				post_attachment: bool2int(!!x['aid']),
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

			row_list << {"sm_posts" => h}
		end

		return row_list
	end

	#AFTER = "<QUOTE author=\"Arrhenius\" post_id=\"185095\" time=\"1281689105\" user_id=\"13738\"><s>[quote=Arrhenius post_id=185095 time=1281689105 user_id=13738]</s>"

	#BBCODE_RX = /\[(?<tag>[A-Za-z]+)\=?(?<params>.*?)?\](?<body>.*?)\[\/\k<tag>\]/ # /\[([A-Za-z]+)\=?(.*?)?\](.*?)\[\/\1\]/
	#PARSED_RX = /<(s|e)>.*?<\/\1>/

end
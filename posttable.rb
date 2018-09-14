# has special methods unique to post tables

class PostTable < SQLTable

	# Regular expression for matching [rquote] bbcode tags
	RQUOTE_RX = /\[rquote\=(\d+)&amp;tid=(\d+)&amp;author=(.*?)\]/

private

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

end
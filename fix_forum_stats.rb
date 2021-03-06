require './sm_transition.rb'

# import custom ranks

PHPBB.forums.each do |f|
  next if f['forum_type'] == 0

  post_count = PHPBB_DB.query("SELECT COUNT(*) FROM sm_posts WHERE forum_id = #{f['forum_id']}").first.values[0]
  topic_count = PHPBB_DB.query("SELECT COUNT(*) FROM sm_topics WHERE forum_id = #{f['forum_id']}").first.values[0]

  next if topic_count == 0

  last_post = PHPBB_DB.query("SELECT * FROM sm_posts WHERE forum_id = #{f['forum_id']} ORDER BY post_id DESC LIMIT 1").first
  last_subject = PHPBB.topics[last_post['topic_id']]['topic_title']

  h = {
    forum_last_post_id: last_post['post_id'],
    forum_last_poster_id: last_post['poster_id'],
    forum_last_post_subject: last_subject,
    forum_last_post_time: last_post['post_time'],
    forum_last_poster_name: last_post['post_username'],
    forum_topics_approved: topic_count,
    forum_posts_approved: post_count
  }

  ar = []
  h.each_pair {|k,v| ar << "#{k} = #{sanitize(v)}"}

  puts "UPDATE sm_forums SET #{ar * ', '} WHERE forum_id = #{f['forum_id']}"

  PHPBB_DB.query("UPDATE sm_forums SET #{ar * ', '} WHERE forum_id = #{f['forum_id']}")
end

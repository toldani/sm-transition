require './sm_transition.rb'

# tmax = PHPBB.topics.max

# PHPBB_DB.query("DELETE FROM sm_topics WHERE topic_id = #{tmax}")
# PHPBB_DB.query("DELETE FROM sm_posts WHERE topic_id = #{tmax}")

PHPBB.topics.each do |t|
  plist = XMB.posts.to_phpbb(t['tid'])  #where(tid: t['tid']).sort_by {|i| i['pid']}
  topic = XMB.threads.to_phpbb(t, plist)
  insert_record(topic)
  puts "Topic added, #{plist.length} posts found.  Adding them to posts table..."

  plist.each {|p| insert_record(p)}
end
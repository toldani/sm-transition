require './sm_transition.rb'

XMB.threads.each do |t|
  plist = XMB.posts.where(tid: t['tid']).sort_by {|i| i['pid']}
  topic = XMB.threads.to_phpbb(t, plist)
  insert_record(topic)
  puts "Topic added, #{plist.length} posts found.  Adding them to posts table..."

  plist.each {|p| insert_record(XMB.posts.to_phpbb(p))}
end
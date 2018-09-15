
require './sm_transition.rb'

hdpath = "/mnt/vmdisk/attachments/"

dlist = Dir.glob(hdpath+"*")

dlist.each do |p|
  Dir.glob(p+"/*/*").sort.each do |f|
  	next if f[/-thumb\.jpg$/]
  	aid = f.split('/')[-2].to_i
  	a = XMB.attachments.to_phpbb(aid, f)
  	puts a
  	SQLTable.insert_record(a)
  end
end



  

=begin

(1..X_ATTACH.max).each do |n|
	a = X_ATTACH[n]
	next if a.nil?
	`gsutil mv 
	if a['parentid'] == 0
		p = X_POSTS[a["pid"]]
		u = X_MEMBERS.find_by('username', p['author'])
		h = {
			"attach_id" => a["aid"],
			"post_message_id" => a["pid"],
			"topic_id" => p["tid"],
			"in_message" => 0,
			"poster_id" => u["user_id"],
			"is_orphan" => 0,
			"physical_filename" => 



sql = "SELECT aid AS attach_id, pid AS post_message_id,"
=end
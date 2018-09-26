
require './sm_transition.rb'

amap = {}

PHPBB_DB.query("SELECT attach_id, real_filename, post_msg_id FROM sm_attachments WHERE post_msg_id IS NOT NULL").each do |h|
  amap[h['post_msg_id']] = amap[h['post_msg_id']].to_h.merge(h['attach_id'] => h['real_filename'])
end

amap.keys.each do |p|
  txt = PHPBB.posts[p]['post_text']
  orig = txt.dup
  next unless txt.is_a?(String)

  aid_list = amap[p].keys.sort.reverse
  aid_list.each_with_index do |f,i|
    s = "<FILE content=\"#{f}\"><s>[file]</s>#{f}<e>[/file]</e></FILE>"
    r = "<ATTACHMENT filename=\"#{amap[p][f]}\" index=\"#{i}\"><s>[attachment=#{i}]</s>#{amap[p][f]}<e>[/attachment]</e></ATTACHMENT>"
    txt.sub!(s, r)
  end

  unless orig == txt
    q = "UPDATE sm_posts SET post_text = #{sanitize(txt)} WHERE post_id = #{p}"
    puts q if rand(0..20) == 0
    PHPBB_DB.query(q)
  end
end
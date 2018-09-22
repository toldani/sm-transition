require './sm_transition.rb'

# import custom ranks

ranks = XMB_DB.query("SELECT DISTINCT customstatus, uid FROM xmb_members WHERE customstatus != ''").to_a

next_rank = PHPBB.ranks.max

ranks.each do |r|
  next_rank += 1
  insert_record('sm_ranks' => {rank_id: next_rank, rank_title: r['customstatus'], rank_min: 0, rank_special: 1})
  PHPBB_DB.query("UPDATE sm_users SET user_rank = #{next_rank} WHERE user_id = #{r['uid']}")
end
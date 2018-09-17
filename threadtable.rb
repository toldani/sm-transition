# has special methods unique to post tables

class ThreadTable < SQLTable

  #get sorted array of posts in a thread
  def post_list(thread)
    if thread.is_a?(Hash) && thread['tid']
      tid = thread['tid']
    else
      tid = thread
    end

    return XMB.posts.where(tid: tid).sort_by {|i| i['pid']}
  end

  # thread id and a reference to an array of all the posts in that thread
  def to_phpbb(thread, arp)

    if thread.is_a?(Hash) && thread['tid']
      tid = thread['tid']
    else
      tid = thread
    end

    x = self[tid]

    has_attach = PHPBB.attachments.find_by('topic_id', tid).empty? == false

    first_post = arp.first
    first_poster = XMB.members[first_post['author']]

    last_post = arp.last
    last_poster = XMB.members[last_post['author']]

    h = {
      topic_id: x['tid'],
      forum_id: X2P_FID[x['fid']],
      icon_id: POST_ICONS[x['icon']].to_s,
      topic_attachment: has_attach.to_i,
      topic_reported: 0,
      topic_title: x['subject'],
      topic_poster: x['author'],
      topic_time: first_post['dateline'],
      topic_time_limit: 0,
      topic_views: x['views'],
      topic_status: 0,
      topic_type: 0,
      topic_first_post_id: first_post['pid'],
      topic_first_poster_name: first_poster['username'],
      topic_first_poster_colour: "",
      topic_last_post_id: last_post['pid'],
      topic_last_poster_id: last_poster['uid'],
      topic_last_poster_name: last_post['author'],
      topic_last_poster_colour: "",
      topic_last_post_subject: last_post['subject'],
      topic_last_post_time: last_post['dateline'],
      topic_last_view_time: last_post['dateline'],
      topic_moved_id: 0,
      topic_bumped: 0,
      topic_bumper: 0,
      poll_title: "<t></t>",
      poll_start: 0,
      poll_length: 0,
      poll_max_options: 1,
      poll_last_vote: 0,
      poll_vote_change: 0,
      topic_visibility: 1,
      topic_delete_time: 0,
      topic_delete_reason: "",
      topic_delete_user: 0,
      topic_posts_approved: x['length'],
      topic_posts_unapproved: 0,
      topic_posts_softdeleted: 0
    }


    return {"sm_topics" => h}
  end

end
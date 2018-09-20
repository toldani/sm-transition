# has special methods unique to post tables

class ThreadTable < SQLTable

  def initialize(t)
    @start_row = PHPBB_DB.query("SELECT MAX(topic_id) FROM sm_topics").first.values.first
    super
  end

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

    has_attach = !PHPBB.attachments.find_by('topic_id', tid).empty?

    first_post = arp.first['sm_posts']
    last_post = arp.last['sm_posts']

    h = {
      topic_id: x['tid'],
      forum_id: X2P_FID[x['fid']],
      icon_id: POST_ICONS[x['icon']],
      topic_attachment: has_attach.to_i,
      topic_reported: 0,
      topic_title: x['subject'],
      topic_poster: first_post[:poster_id],
      topic_time: first_post[:post_time],
      topic_time_limit: 0,
      topic_views: x['views'],
      topic_status: 0,
      topic_type: x['topped'],
      topic_first_post_id: first_post[:post_id],
      topic_first_poster_name: first_post[:post_username],
      topic_first_poster_colour: "",
      topic_last_post_id: last_post[:post_id],
      topic_last_poster_id: last_post[:poster_id],
      topic_last_poster_name: last_post[:post_username],
      topic_last_poster_colour: "",
      topic_last_post_subject: last_post[:post_subject],
      topic_last_post_time: last_post[:post_time],
      topic_last_view_time: last_post[:post_time],
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
      topic_posts_approved: arp.length,
      topic_posts_unapproved: 0,
      topic_posts_softdeleted: 0
    }


    return {"sm_topics" => h}
  end

end
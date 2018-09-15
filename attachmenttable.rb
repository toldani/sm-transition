# has special methods unique to attachment tables

class AttachmentTable < SQLTable

	CSPATH = "/var/www/html/talk/files/attachments/"
	HDPATH = "/mnt/vmdisk/attachments/"

	def to_phpbb(aid, path)
		x = self[aid]
		thumb_path = path.sub("/#{aid}/", "/#{aid+1}/") + "-thumb.jpg"
		i = File.exist?(thumb_path) ? 1 : 0
		md5 = self.class.md5sum(path)
		tid = XMB.posts[x['pid']]['tid']

		h = {
					attach_id: x['aid'],
					post_msg_id: x['pid'],
					topic_id: tid,
					in_message: 0,
					poster_id: x['uid'],
					is_orphan: 0,
					physical_filename: md5,
					real_filename: x['filename'],
					download_count: x['downloads'],
					attach_comment: "",
					extension: x['filename'].split('.')[-1],
					mimetype: x['filetype'],
					filesize: x['filesize'],
					filetime: x['updatetime'].to_i,
					thumbnail: i
				}

		unless File.exist?(CSPATH+md5)
			FileUtils.cp(path, CSPATH+md5)
			FileUtils.cp(thumb_path, CSPATH+"thumb_"+md5) if i > 0
		end

		return {"sm_attachments" => h}
	end


	# return md5 checksum of a file	
	def self.md5sum(path)
		return `md5sum #{path}`[/^[0-9a-f]+/] if File.exist?(path)
	end
end
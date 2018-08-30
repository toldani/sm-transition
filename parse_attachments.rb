#!/usr/bin/env ruby

require 'mysql2'
require 'fileutils'
require 'cgi'

ATTACH_DIR = "/mnt/vmdisk/attachments"

# This script connects to the MySQL XMB database, then downloads and saves each attachment locally, uses CGI::escape to sanitize the
# filename, updates the filename in the DB to the sanitized version, and sets the attachment data to NULL
#
# In order to connect directly to the virtual machine mysql server, you need to set up port forwarding.  You at least
# need SSH and MySQL ports set up. Running a headless VM, the following commands worked:
#
# vboxmanage modifyvm "SM-offline2" --natpf1 "guestssh,tcp,,2222,,22" (ssh -p 2222 root@localhost to connect to guest)
# vboxmanage modifyvm "SM-offline2" --natpf1 "guestmysql,tcp,,3333,,3306" (forwards 3333 to guest's MySQL TCP port)

@client = Mysql2::Client.new(host: "127.0.0.1", username: "root", password: "science", port: 3333, database: "science_xmb1")

# Get the current value of the incrementor for the attachment table's primary key

aid_query = 'SELECT AUTO_INCREMENT FROM information_schema.TABLES WHERE TABLE_SCHEMA = "science_xmb1" AND TABLE_NAME = "xmb_attachments"'
aid_max = @client.query(aid_query).first["AUTO_INCREMENT"]

(0..aid_max).each do |aid|
	result = @client.query("SELECT aid, pid, filename, filesize, attachment FROM xmb_attachments WHERE aid = #{aid}").first
	unless result.nil? || result["attachment"].length == 0
		# in case of filename conflicts, put each file in folders corresponding to the attachment id and post id
		attachment_path = "#{ATTACH_DIR}/#{result['pid']}/#{result['aid']}/"
		FileUtils.mkdir_p(attachment_path)
		# strip the filename of special characters that might cause problems
		filename = CGI::escape(File.basename(result["filename"]))
		attachment_path << filename
		# write the data extracted from the attachment blob field to a folder
		bytes = File.write(attachment_path, result["attachment"])
		puts "#{bytes} bytes written to #{attachment_path}"
		# The following line would have deleted attachments as it converted them into files:
		# @client.query("UPDATE xmb_attachments SET attachment = NULL, filename = '#{filename}' WHERE aid = #{result['aid']}")
		# However, it's easier to just go back into MySQL and run ALTER TABLE xmb_attachments DROP COLUMN attachments;
	end
end

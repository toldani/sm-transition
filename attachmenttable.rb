# has special methods unique to attachment tables

class AttachmentTable < SQLTable



	# return md5 checksum of a file	
	def self.md5sum(path)
		return `md5sum #{path}`[/^[0-9a-f]+/] if File.exist?(path)
	end
end
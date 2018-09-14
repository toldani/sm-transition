# has special methods unique to attachment tables

class AttachmentTable < SQLTable



	# return md5 checksum of a file	
	def self.md5sum(path)
		if File.exist?(path)
		return `md5sum #{path}`[/^[0-9a-f]+/]
	end
end
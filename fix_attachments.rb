
require './sql_helpers.rb'

P_ATTACH = PTable.new('sm_attachments')
X_ATTACH = XTable.new('xmb_attachments')

(1..X_ATTACH.max).each do |a|

/var/www/html/talk/files/cloudstorage/attachments/
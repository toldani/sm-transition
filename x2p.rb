module X2P

  # The XMB database, running in a virtual machine.  Port forwarding is set up to allow communication
  XMB_DB = Mysql2::Client.new(host: "127.0.0.1", username: "root", password: "science", port: 3307, database: "science_xmb1", connect_timeout: 3) rescue nil
  
  if XMB_DB
    XMB_TABLES = XMB_DB.query("SHOW TABLES").to_a.map {|h| h.flatten[1]} # array of xmb table names
  else
    puts "XMB database unable to connect, continuing anyway."
  end

  # The phpBB database, running on the local non-virtual machine.
  PHPBB_DB = Mysql2::Client.new(host: "127.0.0.1", username: "sm", password: "science", port: 3306, database: "sm_phpbb", connect_timeout: 3) rescue nil

  if PHPBB_DB
    PHPBB_TABLES = PHPBB_DB.query("SHOW TABLES").to_a.map {|h| h.flatten[1]} # array of phpbb table names
  else
    puts "phpBB database unable to connect, continuing anyway."
  end

  # A hash mapping XMB forums numbers to their phpbb counterparts
  X2P_FID = {2=>5, 11=>21, 3=>12, 13=>1, 5=>7, 6=>9, 7=>18, 9=>11, 10=>6, 12=>8, 14=>3, 15=>13, 16=>4,
        19=>19, 20=>16, 22=>15, 23=>14, 24=>10, 8=>20}

  POST_ICONS = PHPBB_DB.query("SELECT SUBSTRING_INDEX(icons_url, '/', -1), icons_id FROM sm_icons").map {|h| h.values}.to_h

  SIZE_MAP = {-2 => 75, -1 => 85, 0 => 100, 1 => 110, 2 => 125, 3 => 140, 4 => 160, 5 => 180, 6 => 200}
  UNPROCESSED_RX = /<s>\[.*?\]<\/s>|(\[[^\/E\d].*?\])/

  $rows_written = 0

  #SHITTY_XMB_LOGIC = {"no" => 1, "yes" => 0}

  # format a value for assigment in SQL
  # don't escape the quotes if they're already escaped
  def sanitize(v)
    if v.is_a?(Numeric)
      return v.to_s
    elsif v.is_a?(String)
      return "'#{PHPBB_DB.escape(v)}'"
    end
  end

  # returns an empty value, corresponding to the data type of the column
  def guess_column_default(y)
    y = y['Type'] if y.is_a?(Hash)

    if !!y[/(char\(\d+\)|text)/] # column contains string
      return ""
    elsif !!y[/int\(\d+\)/] # column contains a type of int
      return 0
    else
      return 0.0
    end
  end

  # get SQLTable object by passing in table name as a string
  def lookup(str)
    d, t = str.match(/^(xmb|sm)_(\w+)/).captures
    if d == "xmb"
      return XMB[t]
    elsif d == "sm"
      return PHPBB[t]
    end
  end

  # write a row to the specified table. data is supplied as a hash, where key names correspond to column names
  def insert_record(r)
    # if the hash keys are all valid writable table names, then write rows to multiple tables
    return nil if (r.keys & PHPBB_TABLES) != r.keys

    r.each_pair do |t,h|
      h.delete_if {|k,v| v.nil?}
      vstring = h.values.map {|g| sanitize(g)} * ', '
      kstring = h.keys * ', '
      q = "INSERT INTO #{t} (#{kstring}) VALUES (#{vstring})"
      begin
        PHPBB_DB.query(q)
      rescue Mysql2::Error => e
        puts "Error with query: #{q}"
        puts "Record is: #{h}" 
        puts e.backtrace.join("\n")
        puts e
        next
      end

      if $rows_written < 100 || $rows_written % 20 == 0 # only output 1/10 of writes to the console after the first 100 writes
        puts "Wrote \e[32m#{h}\e[0m to \e[36m#{t}\e[0m"
      end
    end
    $rows_written += 1
  end

  # return md5 checksum of a file 
  def md5sum(path)
    return `md5sum #{path}`[/^[0-9a-f]+/] if File.exist?(path)
  end

  # return the integer representation of a boolean value
  def bool2int(str, **opts)
    invert = opts[:invert]
    bool = YAML.load(str.to_s) != invert # inverts bool if invert=true
    return {true => 1, false => 0}[bool]
  end

  def update_bbcode(tid)
    PHPBB.posts.where("post_id", "post_text", topic_id: tid).each do |t|
      txt = t['post_text']
      repl = fix_bbcode(txt)
      if repl
        q = "UPDATE sm_posts SET post_text = #{sanitize(repl)} WHERE post_id = #{t['post_id']}"
        puts q
        PHPBB_DB.query(q)
      else
        puts "Nothing to change..."
      end
    end
  end

#  def bb2rx(tag)
#    return "<#{tag.upcase}.*?><s>[#{tag}.*?]</s>
#    [/img]<e>[/url]</e></URL>"
#
# repl:  "<IMG src=\"\\1\"><s>[img]</s><URL url=\"\\1\">\\1</URL><e>[/img]</e></IMG>"
#
# where: "post_text LIKE '<r>%' AND post_text LIKE '%[img]<URL%'"
# rx:    /\[img\]<URL url=\"(.+?)\">.+?<\/URL>\[\/img\]/i
# 
# where: "post_text LIKE '<r>%' AND post_text LIKE '%</LINK_TEXT>[/img]%'"
# rx:    /\[img\]<LINK_TEXT .+?>(.+?)<\/LINK_TEXT>\[\/img\]/i
# 
# where: "post_text LIKE '<r>%' AND post_text LIKE '%</LINK_TEXT>[/IMG]<e>[/URL]</e></URL>%'"
# rx:    /<URL .+?><s>\[URL .+?\]<\/s>\[IMG\]<LINK_TEXT .+?>(http.+?)<\/LINK_TEXT>\[\/IMG\]<e>\[\/URL\]<\/e><\/URL>/i


  def replace_in_posts(where,rx,repl)
    counter = 0
    ar = PHPBB_DB.query("SELECT post_id, post_text FROM sm_posts WHERE #{where}").to_a
    ar.each do |h|
      txt = h['post_text'].dup
      txt.gsub!(rx, repl)
      if txt != h['post_text']
        q = "UPDATE sm_posts SET post_text = #{sanitize(txt)} WHERE post_id = #{h['post_id']}"
        puts "Post \e[32m#{h['post_id']}\e[0m Query: #{q}\n\n" if counter % 10 == 0 
        PHPBB_DB.query(q)
        counter += 1
      end
    end
    puts "#{counter} replacements performed."
  end

  def fix_bbcode(text)
    txt = text.dup
    bb = txt.scan(UNPROCESSED_RX).flatten.compact
    bb.each do |x|
      case x
      when /(?<!<s>)\[quote\]/i #, "[img]", "[sup]"
        txt.sub!(/(?<!<s>)\[quote\]/i, "<QUOTE><s>[quote]</s>")
        txt.sub!(/(?<!<e>)\[\/quote\]/i, "<e>[/quote]</e></QUOTE>")
      when /(?<!<s>)\[quote=(.+?) post_id=(\d+) time=(\d+) user_id=(\d+)\]/
        username, pid, time, uid = /\[quote=(.+?) post_id=(\d+) time=(\d+) user_id=(\d+)\]/.match(x).captures
        repl = "<QUOTE author=\"#{username}\" post_id=\"#{pid}\" time=\"#{time}\" user_id=\"#{uid}\"><s>#{x}</s>"
        txt.sub!(x, repl)
        txt.sub!(/(?<!<e>)\[\/quote\]/, "<e>[/quote]</e></QUOTE>")
      when /(?<!<s>)\[size=(-[12]|[1-6])\]/i
        n = x[/(?<=\[size=)-?\d+/i].to_i
        m = SIZE_MAP[n]
        txt.sub!(x, "<SIZE size=\"#{m}\"><s>[size=#{m}]</s>")
        txt.sub!(/(?<!<e>)\[\/size\]/i, "<e>[/size]</e></SIZE>")
      else
        bb = []
      end
    end

    unless bb.empty?
      body = txt[/(?<=^<t>).*(?=<\/t>$)/m]
      txt = "<r>#{body}</r>" unless body.nil?
    end
    
    return bb.empty? ? nil : txt
  end

  def unescape(text)
    return CGI.unescape_html(text).gsub(/\\(?=['"])/, '')
  end
end

# <a href="./download/file.php?id={NUMBER}&amp;mode=view"><img src="./download/file.php?id={NUMBER}&amp;t=1" class="postimage" alt="DSCN0675.JPG" title="DSCN0675.JPG (1.79 MiB) Viewed 26 times"></a>
# [img]<URL url=\"http://i1329.photobucket.com/albums/w541/mmpchem/photo_zps291c1ad8.jpg\"><LINK_TEXT text=\"http://i1329.photobucket.com/albums/w54 ... 1c1ad8.jpg\">http://i1329.photobucket.com/albums/w541/mmpchem/photo_zps291c1ad8.jpg</LINK_TEXT></URL>[/img]
# <URL url=\"http://s454.photobucket.com/user/Arkoma_USA/media/digizooms/104_0014.jpg.html\"><s>[URL=http://s454.photobucket.com/user/Arkoma_USA/media/digizooms/104_0014.jpg.html]</s>[IMG]<LINK_TEXT text=\"http://i454.photobucket.com/albums/qq26 ... 4_0014.jpg\">http://i454.photobucket.com/albums/qq261/Arkoma_USA/digizooms/th_104_0014.jpg</LINK_TEXT>[/IMG]<e>[/URL]</e></URL>
# /<URL .+?><s>\[URL .+?\]<\/s>\[IMG\]<LINK_TEXT .+?>(http.+?)<\/LINK_TEXT>\[\/IMG\]<e>\[\/URL\]<\/e><\/URL>/i
# http://i454.photobucket.com/albums/qq261/Arkoma_USA/celestron/th_2012-10-09-034404.jpg
# http://i454.photobucket.com/albums/qq261/Arkoma_USA/celestron/2012-10-09-034404.jpg
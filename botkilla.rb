require 'mechanize'
require 'logger'
require 'open-uri'
require 'yaml'

START_THREAD_CUTOFF = 96000
POPULAR_DOMAINS = open("sm-linked-domains.txt").read.split("\n")

@log = Logger.new "/home/tom/workspace/mechlog.txt"
@log.level = Logger::DEBUG

@uri = URI("http://www.sciencemadness.org/talk/")

@tid_cutoff = START_THREAD_CUTOFF

@username = "Melgar"
puts "Password?"
@password = gets.chop

@botkilla = Mechanize.new {|a| a.log = @log}

@botkilla.user_agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/69.0.3497.81 Chrome/69.0.3497.81 Safari/537.36"

@botkilla.get("http://www.sciencemadness.org/talk/misc.php?action=login")

@login_form = @botkilla.page.forms.first

@last_error = ""

@checked_threads = []

@login_form.field_with(:name => "username").value = @username
@login_form.field_with(:name => "password").value = @password

@login_form.click_button

class Nokogiri::XML::Element
  def grandchildren
    self.children.children
  end

  def great_grandchildren
    self.children.children.children
  end

  def descendents(n)
    x = self
    n.times { x = x.children }
    return x
  end
end

def posts_today
  @botkilla.get(@uri.to_s + "today.php")
  ar = []

  @botkilla.page.xpath("//tr[@class='tablerow']").each do |tr|
    h = {}
    begin
      # pull link and title out of the nested Nokogiri mess
      title_cell = tr.at_xpath("./td[@width='43%']/font/a")
      h['link'] = title_cell['href']
      h['title'] = title_cell.text
      h['username'] = tr.at_xpath("./td[@width='14%' and @bgcolor='#fffbe8']").text
      h['replies'] = tr.xpath("./td[@width='5%']/font").first.text.to_i
      h['last_poster'] = tr.at_xpath("./td[@width='23%']/table/tr/td/font/a").text
      h['tid'] = h['link'][/(?<=tid=)\d+/].to_i
    rescue => e
      if @last_error == e.to_s
        print "."
      else
        @last_error = e.to_s
        print e.to_s
      end
      next
    end
    ar << h
  end

  return ar
end

# new posts since posts were last checked
def new_posts
  return posts_today.select {|h| h['tid'] > @tid_cutoff}
end

def delete_thread(h)
  begin
    @botkilla.get("http://www.sciencemadness.org/talk/topicadmin.php?tid=#{h['tid']}&action=delete")
    @botkilla.page.forms.first.click_button
    puts "Deleted thread with title '#{h['title']}' for #{h['flags'].join(', ')}."
  rescue => e
    puts e
  end
end

def kill_spam(ar)
  @botkilla.get(@uri.to_s + "misc.php?action=list&desc=desc")
  rows = @botkilla.page.search("tr")
  users = rows[11].text.scan(/(?<=\r\n)(.+?)\r\nMember[\r\n]+(\d+\/\d+\/\d+)\r\n(\d+)/)
  users.map! {|a| [a[0], {"reg_date" => DateTime.strptime(a[1], '%m/%d/%y').to_time, "post_count" => a[2].to_i}]}
  users = users.to_h

  ar.each do |h|
    next if @checked_threads.include?(h['tid'])
    # If the title contains words common in spam titles
    if h['title'][/(sex|passionate|adult|galleries|unencumbered|mature|callow)/i]
      h['spam_score'] = h['spam_score'].to_i + 5
      h['flags'] = h['flags'].to_a + ['spam words in title']
    elsif h['title'][/\p{C}/]
      h['spam_score'] = h['spam_score'].to_i + 5
      h['flags'] = h['flags'].to_a + ['strange characters in title']
    end

    # if the list of most recently registered users includes the user in question, add
    # 5 points for registereing in the last 36 hours, 3 points oherwise.
    if users.keys.include? h['username']
      if (Time.now - users[h['username']]['reg_date']) / 3600 < 36 
        h['spam_score'] = h['spam_score'].to_i + 5
        h['flags'] = h['flags'].to_a + ['registered since yesterday']
      else
        h['spam_score'] = h['spam_score'].to_i + 3
        h['flags'] = h['flags'].to_a + ['registered recently']
      end
    end

    # scan the text of a post for links, then determine if they're appropriate links for this site
    @botkilla.get(@uri.to_s + h['link'])
    h['thread_text'] = @botkilla.page.xpath("//td[@class='tablerow' and @valign='top' and @style='height: 80px; width: 82%']/font")[1].text
    domains = h['thread_text'].to_s.scan(/https?:\/\/([\w\.-]+)/).flatten
    verdict = domains.group_by {|d| POPULAR_DOMAINS.include?(d)}

    # number of links to unrecognized domains that were posted
    if verdict[true].to_a.length < verdict[false].to_a.length
      h['spam_score'] = h['spam_score'].to_i + 5
      h['flags'] = h['flags'].to_a + ['linking to an unrecognized domain']
    end

    # 
    if h['spam_score'].to_i > 8 && h['tid'] > @tid_cutoff
      @last_error = ""
      puts "\n\n"
      puts h.to_yaml
      puts "Spam score is #{h['spam_score']}. Deleting it..."
      #x = gets.chop
      delete_thread(h) #if x.downcase == "y"
    else
      @checked_threads << h['tid']
    end
  end
end   
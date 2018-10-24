require 'mechanize'
#require 'logger'
require 'open-uri'
require 'yaml'

START_THREAD_CUTOFF = 98000
POPULAR_DOMAINS = open("sm-linked-domains.txt").read.split("\n")

#@log = Logger.new "/home/tom/workspace/mechlog.txt"
#@log.level = Logger::DEBUG

@uri = URI("http://www.sciencemadness.org/talk/")

@tid_cutoff = START_THREAD_CUTOFF

@username = "Melgar"
print "Password: \e[8m"
@password = gets.chop
@password.define_singleton_method(:inspect) { "[REDACTED]" }
puts "\e[0m"

@botkilla = Mechanize.new # {|a| a.log = @log}

@botkilla.user_agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/69.0.3497.81 Chrome/69.0.3497.81 Safari/537.36"

@botkilla.get("http://www.sciencemadness.org/talk/misc.php?action=login")

@login_form = @botkilla.page.forms.first

@last_error = ""

@checked_threads = []
@kill_count = 0
@start_time = Time.now

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
      h['replies'] = tr.xpath("./td[@width='5%']/font").text.to_i
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
    puts "Deleted thread with title \e[1m'#{h['title']}'\e[0m at \e[1m#{Time.now.ctime}\e[0m because \e[1m#{h['flags'].join(', ')}\e[0m."
    @kill_count += 1
    run_time = Time.now - @start_time
    puts "Killed #{@kill_count} spam posts in #{(run_time/3600).to_i} hours and #{((run_time % 3600)/60).to_i} minutes. (#{((@kill_count*3600)/run_time).round(2)} kills/hour)"
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
    if h['title'][/(sex|passionate|adult|galleries|unencumbered|mature|callow|casino|passports)/i]
      h['spam_score'] = h['spam_score'].to_i + 3
      h['flags'] = h['flags'].to_a + ['spam words in title']
    elsif h['title'][/\p{C}/]
      h['spam_score'] = h['spam_score'].to_i + 3
      h['flags'] = h['flags'].to_a + ['strange characters in title']
      h['title'] = h['title'].force_encoding("UTF-8").encode("ISO-8859-1").force_encoding("UTF-8") rescue "UTF-8 ERROR!"
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
    @botkilla.get(@uri.to_s + h['link']) rescue next
    body = @botkilla.page.xpath("//td[@class='tablerow' and @valign='top' and @style='height: 80px; width: 82%']/font[@class='mediumtxt']").first
    h['thread_text'] = ([body.text] + body.xpath("./a").map {|e| e['href']}).join(' ') # adds linked urls to body text for scanning
    h['thread_text'] = h['thread_text'].force_encoding("UTF-8").encode("ISO-8859-1").force_encoding("UTF-8") rescue "UTF-8 ERROR!" # try to fix encoding if needed
    domains = h['thread_text'].to_s.scan(/https?:\/\/([\w\.-]+)/).flatten
    verdict = domains.group_by {|d| POPULAR_DOMAINS.include?(d)}

    # number of links to unrecognized domains that were posted
    if verdict[true].to_a.length < verdict[false].to_a.length
      h['spam_score'] = h['spam_score'].to_i + 6
      h['flags'] = h['flags'].to_a + ['linking to an unrecognized domain']
    end

    # check and see if the same word/words are used way too much
    if h['thread_text'].scan(/(passport)/i).flatten.length > 50
      h['spam_score'] = h['spam_score'].to_i + 5
      h['flags'] = h['flags'].to_a + ['repeating the same word too much']
    end

    # checks to see if user is creating a poll for first post, or is submitting a link for first post
    posts = @botkilla.page.xpath("//div[@class='smalltxt']").text[/(?<=Posts: )\d+/].to_i
    if posts < 1
      h['spam_score'] = h['spam_score'].to_i + 6
      h['flags'] = h['flags'].to_a + ['poll as first post']
    elsif posts == 1
      h['spam_score'] = h['spam_score'].to_i + 3
      h['flags'] = h['flags'].to_a + ['first post ever']
    end

    # delete if cumulative spam score is 10 or more
    if h['spam_score'].to_i >= 10 && h['tid'] > @tid_cutoff
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



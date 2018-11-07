# To parse bbcode, whole threads will be loaded into memory and parsed at once.  This not only reduces
# SQL calls, but it allows posts within a thread to reference each other without needing to pull any
# additional data from the DB.  
#
# Steps:
# 1. Scan for escaped HTML and replace with equivalent bbcode
# 2. 

BBCODE_MAP =  {
  "Bold"=>
    [/\[b(:.*)?\](.*?)\[\/b\1?\]/mi,
      "<B><s>[b]</s>\\2<e>[/b]</e></B>",
      "Embolden text",
      "Look [b]here[/b]",
      :bold],
  "Italics"=>
    [/\[i(:.+)?\](.*?)\[\/i\1?\]/mi,
      "<I><s>[i]</s>\\2<e>[/i]</e></I>",
      "Italicize or emphasize text",
      "Even my [i]cat[/i] was chasing the mailman!",
      :italics],
  "Underline"=>
    [/\[u(:.+)?\](.*?)\[\/u\1?\]/mi,
      "<U><s>[u]</s>\\2<e>[/u]</e></U>",
      "Underline",
      "Use it for [u]important[/u] things or something",
      :underline],
  "Code"=>
    [/\[code(:.+)?\](.*?)\[\/code\1?\]/mi,
      "<CODE><s>[code]</s>\\2<e>[/code]</e></CODE>",
      "Code Text",
      "[code]some code[/code]",
      :code],
  "Size"=>
    [/\[size=(&quot;|&apos;|)(\d*?)\1\](.*?)\[\/size\]/mi,
      "<SIZE size=\"#{SIZE_MAP['\2'.to_i]}\"><s>[size=\\2]</s>\\3<e>[/size]</e></SIZE>",
      "Change text size",
      "[size=5]Here is some larger text[/size]",
      :size],
  "Color"=>
    [/\[color=(&quot;|&apos;|)(\w+|\#\w{6})\1(:.+)?\](.*?)\[\/color\3?\]/mi,
      "<COLOR color=\"\\2\"><s>[color=\\2]</s>\\4<e>[/color]</e></COLOR>",
      "Change text color",
      "[color=red]This is red text[/color]",
      :color],
  "List Item"=>
    [/\[\*(:[^\[]+)?\]([^(\[|\<)]+)/mi,
      "<LI><s>[*]</s>\\2</LI>",
      "List item (alternative)",
      "[*]list item",
      :listitem],
  "Unordered list (alternative)"=>
    [/\[list(:.*)?\]((?:(?!\[list(:.*)?\]).)*)\[\/list(:.)?\1?\]/mi,
      "<LIST><s>[list]</s>\\2<e>[/list]</e></LIST>",
      "Unordered list item",
      "[list][*]item 1[*] item2[/list]",
      :list],
  "Ordered list (numerical)"=>
    [/\[list=1(:.*)?\](.+)\[\/list(:.)?\1?\]/mi,
      "<LIST type=\"decimal\"><s>[list=1]</s>\\2<e>[/list]</e></LIST>",
      "Ordered list numerically",
      "[list=1][*]item 1[*] item2[/list]",
      :list],
  "Ordered list (lowercase alphabetical)"=>
    [/\[list=a(:.*)?\](.+)\[\/list(:.)?\1?\]/mi,
      "<LIST type=\"lower-alpha\"><s>[list=a]</s>\\2<e>[/list]</e></LIST>",
      "Ordered list alphabetically",
      "[list=a][*]item 1[*] item2[/list]",
      :list],
  "Ordered list (uppercase alphabetical)"=>
    [/\[list=a(:.*)?\](.+)\[\/list(:.)?\1?\]/mi,
      "<LIST type=\"upper-alpha\"><s>[list=A]</s>\\2<e>[/list]</e></LIST>",
      "Ordered list alphabetically",
      "[list=a][*]item 1[*] item2[/list]",
      :list],
  "Quote"=>
    [/\[quote(:.*)?\](.*?)\[\/quote\]/mi,
      "<QUOTE><s>[quote]</s>\\2<e>[/quote]</e></QUOTE>",
      "Quote",
      "[quote]Now is the time...[/quote]",
      :quote],
  "RQuote"=>
    [/\[rquote\=(\d+)&amp;tid=\d+&amp;author=(.*?)\](.*?)\[\/rquote\]/mi,
      "<QUOTE author=\"\\2\" post_id=\"\\1\" time=\"@time@\" user_id=\"@uid@\"><s>[quote=\\2 post_id=\\1 time=@time@ user_id=@uid@]</s>\\3<e>[/quote]</e></QUOTE>",
      "XMB rquote tag, like quote tag but with more info",
      "[rquote=451651&amp;tid=66461&amp;author=Melgar]how 2 make p2p?[/rquote]",
      :rquote],
  "Link"=>
    [/\[url=(?:&quot;)?(.*?)(?:&quot;)?\](.*?)\[\/url\]/mi,
      "<URL url=\"\\1\"><s>[url]</s>\\2<e>[/url]</e></URL>",
      "Hyperlink to somewhere else",
      "Maybe try looking on [url=http://google.com]Google[/url]?",
      :link],
  "Link (Implied)"=>
    [/\[url\](.*?)\[\/url\]/mi,
      "<URL url=\"\\1\"><s>[url=\\1]</s>\\1<e>[/url]</e></URL>",
      "Hyperlink (implied)",
      "Maybe try looking on [url]http://google.com[/url]",
      :link],
  "Image"=>
    [/\[img(:.+)?\]([^\[\]].*?)\.(png|bmp|jpg|gif|jpeg)\[\/img\1?\]/mi,
      "<IMG src=\"\\2.\\3\" /><s>[img]</s>\\2.\\3<e>[/img]</e>",
      "Display an image",
      "Check out this crazy cat: [img]http://catsweekly.com/crazycat.jpg[/img]",
      :image],
  "Align"=>
    [/\[align=(left|right|center)\](.*?)\[\/align\]/mi,
      "<ALIGN align=\"\\1\"><s>[align=\\1]>/s>\\2<e>[/align]</e></ALIGN>",
      "Align this object using float",
      "Here's a wrapped image: [align=right][img]image.png[/img][/align]",
      :align]
  }

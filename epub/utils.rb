
def line_to_html(line, wrap: nil, attrib: nil)
  line = line.strip
  line.chomp!('\\\\')
  line.strip!
  return '' if line.empty?
  start_tag = ''
  end_tag = ''
  if wrap
    start_tag = attrib ? "<#{wrap} #{attrib}>" : "<#{wrap}>"
    end_tag = "</#{wrap}>"
  end
  if line.include?('\\vspace')
    return "#{start_tag}<br/>#{end_tag}"
  end
  line.gsub!(/\\jpfont\s+/, '')
  # \ruby{1}{2}
  line.gsub!(/\\ruby\{(.+?)\}\{(.+?)\}/) do
    rb = $1
    rt = $2
    remove_format = lambda do |s|
      s.delete!('|')
    end
    remove_format.call rb
    remove_format.call rt
    "<ruby><rb>#{rb}</rb><rt>#{rt}</rt></ruby>"
  end
  return '<ul>' if line.include?('\\begin{itemize}')
  return '</ul>' if line.include?('\\end{itemize}')

  # \footnote{1}
  footnotes = []
  line.gsub!(/\\footnote\{(.+)\}/) do
    footnote_contents = line_to_html before_brace($1)
    icon, id = make_footnote_icon
    footnotes.push [footnote_contents, id]
    icon
  end

  if /\\item\s+(.+)/ =~ line
    contents = line_to_html($1)
    return "<li>#{contents}</li>"
  end

  line.delete!('{}')

  result = +"#{start_tag}#{line}#{end_tag}"
  result << make_footnote(footnotes)
  result
end

def tex_to_html(tex_str)
  html_str = +""
  tex_str.each_line do |line|
    html_str << line_to_html(line, wrap: 'p')
  end
  html_str
end

def parse_chapter(tex_str, numbering)
  html_str = +""
  chapter_title_plain = ''
  number_str = numbering < 10 ? "0#{numbering}" : numbering.to_s
  tex_str.each_line do |line|
    # \subsection{1}, \subsection[1]{2}
    if /\\subsection(?:\[(.+?)\])?\{(.+)\}/ =~ line
      chapter_title_contents = before_brace($2)
      chapter_title_plain = line_to_html($1 || chapter_title_contents)
      chapter_title_contents = "#{number_str} #{chapter_title_contents}"
      chapter_title_contents = line_to_html(chapter_title_contents, wrap: 'h1', attrib: 'class="color1"')
      title = line_to_html "#{number_str} #{chapter_title_plain}"
      html_str << <<~TEMPLATE
        <?xml version="1.0" encoding="utf-8"?>
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
          "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

        <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="zh-CN">
        <head>
          <link href="../Styles/style.css" rel="stylesheet" type="text/css"/>
          <title>#{title}</title>
        </head>
        <body>
        <div>
        #{chapter_title_contents}
      TEMPLATE
      next
    end
    html_str << line_to_html(line, wrap: 'p')
  end
  html_str << '</div></body></html>'
  [html_str, chapter_title_plain]
end

def make_footnote_icon
  id = Time.now.to_i * 1000000 + Time.now.usec
  [<<~ICON, id]
    <a class="duokan-footnote" href="##{id}"><img class="w10" src="../Images/zhu.png"/></a>
  ICON
end

def make_footnote(contents)
  return "" if contents.empty?
  result = +'<ol class="duokan-footnote-content">'
  contents.each do |c, id|
    result << <<~LI
      <li class="duokan-footnote-item" id="#{id}"><p class="po">#{c}</p></li>
    LI
  end
  result << '</ol>'
  result
end

def before_brace(string)
  stack = 0
  pos = 0
  string.each_char do |c|
    if c == '{'
      stack += 1
    elsif c == '}'
      stack -= 1
    end

    pos += 1

    if stack < 0
      return string[0, pos]
    end
  end

  string
end

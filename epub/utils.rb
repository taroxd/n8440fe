
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
    "<ruby>#{rb}<rt>#{rt}</rt></ruby>"
  end
  return '<ul>' if line.include?('\\begin{itemize}')
  return '</ul>' if line.include?('\\end{itemize}')

  # \footnote{1}
  footnotes = []
  line.gsub!(/\\footnote\{(.+)\}/) do
    footnote_contents = line_to_html before_brace($1)
    icon, footnote_id = make_footnote_icon
    footnotes.push [footnote_contents, footnote_id]
    icon
  end

  if /\\item\s+(.+)/ =~ line
    contents = line_to_html($1)
    return "<li>#{contents}</li>"
  end

  line.delete!('{}')

  result = +"#{start_tag}#{line}#{end_tag}"
  footnotes.each do |content, footnote_id|
    result << make_footnote(content, footnote_id)
  end
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
  number_str = least_2_digits(numbering)
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
        <!DOCTYPE html>

        <html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
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
  footnote_id = "#{Time.now.usec}-#{rand(0x100000000).to_s(36)}"
  [<<~ICON, footnote_id]
    <a class="duokan-footnote" href="##{footnote_id}"><img class="w10" alt="note" src="../Images/zhu.png"/></a>
  ICON
end

def make_footnote(contents, id)
  <<~OL
    <ol class="duokan-footnote-content" id="#{id}">
      <li class="duokan-footnote-item"><p class="po">#{contents}</p></li>
    </ol>
  OL
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

def least_2_digits(numbering)
  numbering < 10 ? "0#{numbering}" : numbering.to_s
end

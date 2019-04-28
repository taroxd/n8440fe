
def line_to_html(line, wrap: nil, attrib: nil)
  line = line.sub(/(?<!\\)%.*/, '')
  line.strip!
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
  line.gsub!(/\\ruby\{(.+)/) do
    rb, pos = before_brace_with_index $1
    rt, pos = before_brace_with_index $1, pos + 2
    rest = line_to_html $1[(pos + 1)..]
    gsub_result = ""
    [rb, rt].each { |r| r.delete!('{}') }
    rb.split('|').zip(rt.split('|')).map { |rb_part, rt_part|
      "<ruby>#{rb_part}<rt>#{rt_part}</rt></ruby>"
    }.join + rest
  end
  return '<ul>' if line.include?('\\begin{itemize}')
  return '</ul>' if line.include?('\\end{itemize}')

  # \footnote{1}
  footnotes = []
  line.gsub!(/\\footnote\{(.+)\}/) do
    footnote_content = line_to_html before_brace($1)
    footnote_id = generate_footnote_id
    icon = make_footnote_icon footnote_id
    footnotes.push [footnote_content, footnote_id]
    icon
  end

  if /\\item\s+(.+)/ =~ line
    contents = line_to_html($1)
    return "<li>#{contents}</li>"
  end

  line.delete!('{}\\')

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
      html_str << <<~TEMPLATE.chomp
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

def make_footnote_icon(footnote_id)
  <<~ICON.chomp
    <a epub:type="noteref" href="##{footnote_id}" id="#{footnote_id}-ref"><img class="w10" alt="note" src="../Images/zhu.png"/></a>
  ICON
end

def make_footnote(content, footnote_id)
  <<~FOOTNOTE.chomp
    <aside epub:type="footnote" id="#{footnote_id}" class="po"><a href="##{footnote_id}-ref"></a>
      #{content}
    </aside>
  FOOTNOTE
end

def before_brace(string, start_pos = 0)
  before_brace_with_index(string, start_pos).first
end

def before_brace_with_index(string, start_pos = 0)
  stack = 0
  start_pos.upto(string.length - 1) do |pos|
    c = string[pos]

    if c == '{'
      stack += 1
    elsif c == '}'
      stack -= 1
    end

    if stack < 0
      return string[start_pos...pos], pos
    end
  end

  [string, string.length]
end

def least_2_digits(numbering)
  numbering < 10 ? "0#{numbering}" : numbering.to_s
end

def generate_footnote_id
  "#{Time.now.usec}-#{rand(0x100000000).to_s(36)}"
end

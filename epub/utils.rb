
def line_to_html(line)
  line = line.strip
  line.chomp!('\\\\')
  line.strip!
  return '' if line.empty?
  if line.include?('\\vspace')
    return '<p></p>'
  end
  # \ruby{1}{2}
  line.gsub!(/\\ruby\{(.+?)\}\{(.+?)\}/) do
    rb = $1
    rt = $2
    remove_format = lambda do |s|
      s.delete('|')
      s.gsub!(/\\jpfont\s+/, '')
    end
    remove_format.call rb
    remove_format.call rt
    "<ruby><rb>#{rb}</rb><rt>#{rt}</rt></ruby>"
  end
  # \footnote{1}
  line.gsub!(/\\footnote\{(.+?)\}/) do
    "" # TODO
  end
  "<p>#{line}</p>"
end

def line_to_plain(line)
  line = line.strip
  line.chomp!('\\\\')
  line.strip!
  return '' if line.empty?
  if line.include?('\\vspace')
    return "\n"
  end
  # \ruby{1}{2}
  line.gsub!(/\\ruby\{(.+?)\}\{(.+?)\}/) do
    rb = $1
    remove_format = lambda do |s|
      s.delete('|')
      s.gsub!(/\\jpfont\s+/, '')
    end
    remove_format.call rb
    rb
  end
  # \footnote{1}
  line.gsub!(/\\footnote\{(.+?)\}/) do
    ""
  end
  line
end

def tex_to_html(tex_str)
  html_str = String.new
  tex_str.each_line do |line|
    html_str << line_to_html(line)
  end
  html_str
end

def parse_chapter(tex_str, numbering)
  html_str = String.new
  title = ''
  number_str = numbering < 10 ? "0#{numbering}" : numbering.to_s
  tex_str.each_line do |line|
    # \subsection{1}, \subsection[1]{2}
    if /\\subsection(?:\[(.+?)\])?\{(.+?)\}/ =~ line
      chapter_title = line_to_plain($1 || $2)
      title = "#{number_str} #{chapter_title}"
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

        <h1 class="color1">#{title}</h1>
      TEMPLATE
      next
    end
    html_str << line_to_html(line)
  end
  html_str << '</div></body></html>'
  [html_str, title]
end

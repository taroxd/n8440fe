#!/usr/bin/env ruby

require 'gepub'
require_relative 'utils'

title = '关于邻家的天使大人不知不觉把我惯成了废人这档子事'
author = '佐伯さん'
translators = ['taroxd', 'tongyuantongyu', '浪人',
  'kae', '冰川镜华', '纱优纱优', '安诺尔',
  'Konri', '葳蕤百媚生', 'Muzz', 'youfu']
reviewers = ['taroxd', '追影', '墨镜', 'Muzz']

Dir.chdir __dir__

book = GEPUB::Book.new
book.primary_identifier('https://www.lightnovel.cn/thread-960506-1-1.html')
book.language = 'zh'

book.add_title title,
  title_type: GEPUB::TITLE_TYPE::MAIN,
  lang: 'zh'

book.add_creator author
translators.each do |d|
  book.add_contributor d
end

File.open 'style.css', mode: 'rb', encoding: 'utf-8' do |f|
  book.add_item('Styles/style.css', content: f)
end

File.open 'cover.jpg', mode: 'rb' do |f|
  book.add_item('Images/cover.jpg', content: f).cover_image
end

maintex = File.read '../n8440fe.tex', encoding: 'utf-8'

abstract_match = /\\begin{abstract}(.+)\\end{abstract}/m.match(maintex)
abstract = tex_to_html abstract_match[1]

max_chapter = maintex.scan(/\\addchaps\{\d+\}\{(\d+)\}/).map { |(chap_id)| chap_id.to_i }.max
chapter_lists = (1..max_chapter).map { |c| sprintf('%04d', c) }

chapter_contents = []
contents_table = +""
chapter_lists.each do |chap_id|
  chap_file = File.read("../#{chap_id}.tex", encoding: 'utf-8')
  id_int = chap_id.to_i
  id_prefix = least_2_digits(id_int)
  content, chap_title = parse_chapter(chap_file, id_int)
  item_href = "Text/#{chap_id}.xhtml"
  toc_text = "#{id_prefix} #{chap_title}"
  contents_table << <<~TR.chomp
    <tr>
      <td class="tdtop tocidprefix tocitem"><a href="../#{item_href}">#{id_prefix}</a></td>
      <td class="left tocitem"><a href="../#{item_href}">#{chap_title}</a></td>
    </tr>
  TR
  chapter_contents.push([item_href, content, toc_text])
end

book.ordered do
  book.add_item('Text/cover.xhtml', content: StringIO.new(<<~COVER.chomp)).landmark(type: 'cover', title: '封面')
    <?xml version="1.0" encoding="utf-8"?>
    <!DOCTYPE html>

    <html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
    <head>
      <link href="../Styles/style.css" rel="stylesheet" type="text/css"/>
      <title>封面</title>
    </head>
    <body>
      <div class="cover"><img alt="" src="../Images/cover.jpg"/></div>
    </body>
    </html>
  COVER

  book.add_item('Text/title.xhtml').add_content(StringIO.new(<<~TITLE.chomp))
    <?xml version="1.0" encoding="utf-8"?>
    <!DOCTYPE html>

    <html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
    <head>
      <link href="../Styles/style.css" rel="stylesheet" type="text/css"/>
      <title>#{title}</title>
    </head>
    <body>
      <div>
    <p class="titlet1 center">#{title}</p>
    <p><br/></p>
    <p class="titlet2 center">作者</p>
    <p class="titlet3 center">#{author}</p>
    <p class="titlet2 center">译者</p>
    <p class="titlet3 center">#{translators.join(', ')}</p>
    <p class="titlet2 center">校对</p>
    <p class="titlet3 center">#{reviewers.join(', ')}</p>
      </div>
    </body>
    </html>
  TITLE

  book.add_item('Text/message.xhtml').add_content(StringIO.new(<<~MESSAGE.chomp))
    <?xml version="1.0" encoding="utf-8"?>
    <!DOCTYPE html>

    <html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
    <head>
      <link href="../Styles/style.css" rel="stylesheet" type="text/css"/>
      <title>制作信息</title>
    </head>
    <body>
    <div>
    <p class="makertitle">制作信息</p>
    <div class="infobox">
      <p class="top">作者：#{author}</p>
      <p>译者：#{translators.join(', ')}</p>
      <p>校对：#{reviewers.join(', ')}</p>
      <p>制作：大括号不换行汉化组</p>
      <p>轻之国度：https://www.lightnovel.cn</p>
      <p>仅供个人学习交流使用，禁作商业用途</p>
      <p>下载后请在24小时内删除，LK不负担任何责任</p>
      <p class="bottom">请尊重翻译、扫图、录入、校对的辛勤劳动，转载请保留信息</p>
    </div>
    </div>
    </body>
    </html>
  MESSAGE

  book.add_item('Text/introduction.xhtml').add_content(StringIO.new(<<~INTRODUCTION.chomp))
    <?xml version="1.0" encoding="utf-8"?>
    <!DOCTYPE html>

    <html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
    <head>
      <link href="../Styles/style.css" rel="stylesheet" type="text/css"/>
      <title>简介</title>
    </head>
    <body>
    <div>
    <h1>简介</h1>
    #{abstract}
    </div>
    </body>
    </html>
  INTRODUCTION

  book.add_item('Text/contents.xhtml').add_content(StringIO.new(<<~CONTENTS.chomp)).toc_text('目录')
    <?xml version="1.0" encoding="utf-8"?>
    <!DOCTYPE html>

    <html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
    <head>
      <link href="../Styles/style.css" rel="stylesheet" type="text/css"/>
      <title>目录</title>
    </head>
    <body>
    <div>
    <h1 id="toctitle">目录</h1>

    <table id="toctable">
      <tbody>
        #{contents_table}
      </tbody>
    </table>

    </div>
    </body>
    </html>
  CONTENTS

  chapter_contents.each do |item_href, content, chap_title|
    book.add_item(item_href).add_content(StringIO.new(content)).toc_text(chap_title)
  end
end

book.generate_nav_doc '目录'
book.generate_epub '../n8440fe.epub'

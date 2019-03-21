require 'gepub'
require_relative 'utils'

title = '关于邻家的天使大人不知不觉把我惯成了废人这档子事'
author = '佐伯さん'
translators = ['taroxd', 'tongyuantongyu']
book = GEPUB::Book.new
book.primary_identifier('https://www.lightnovel.cn/thread-960506-1-1.html')
book.language = 'zh'

book.add_title title,
  title_type: GEPUB::TITLE_TYPE::MAIN,
  lang: 'zh',
  file_as: 'taroxd'

book.add_creator author
translators.each do |d|
  book.add_contributor d
end

File.open 'style.css', mode: 'rb', encoding: 'utf-8' do |f|
  book.add_item('Styles/style.css', content: f)
end

File.open 'zhu.png', mode: 'rb' do |f|
  book.add_item('Images/zhu.png', content: f)
end

maintex = File.read '../n8440fe.tex', encoding: 'utf-8'

abstract_match = /\\begin{abstract}(.+)\\end{abstract}/m.match(maintex)
abstract = tex_to_html abstract_match[1]

chapter_lists = maintex.scan(/^\\input\{(\d+)\}/).map { |(chap_id)| chap_id }

chapter_contents = []
contents_table = +""
chapter_lists.each do |chap_id|
  chap_file = File.read("../#{chap_id}.tex", encoding: 'utf-8')
  id_int = chap_id.to_i
  id_prefix = id_int < 10 ? "0#{id_int}" : id_int.to_s
  content, chap_title = parse_chapter(chap_file, id_int)
  item_href = "Text/#{chap_id}.xhtml"
  toc_text = "#{id_prefix} #{chap_title}"
  contents_table << <<~TR
    <tr>
      <td class="tdtop w40 pbt09"><a class="nodeco colorg" href="../#{item_href}">#{id_prefix}</a></td>
      <td class="left pbt09"><a class="nodeco colorg" href="../#{item_href}">#{chap_title}</a></td>
    </tr>
  TR
  chapter_contents.push([item_href, content, toc_text])
end

book.ordered do
  book.add_item('text/title.xhtml').add_content(StringIO.new(<<~TITLE)).toc_text(title)
    <?xml version="1.0" encoding="utf-8"?>
    <!DOCTYPE html>

    <html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
    <head>
      <link href="../Styles/style.css" rel="stylesheet" type="text/css"/>

      <title>#{title}</title>
    </head>
    <body>
      <div>
    <p class="mt15 colorc1 center font16">#{title}</p>
    <p><br/></p>
    <p class="font09 center">作者</p>
    <p class="font10 color1 mtb05 center">#{author}</p>
    <p class="font09 center">译者</p>
    <p class="font10 color1 mtb05 center">#{translators.join(', ')}</p>
      </div>
    </body>
    </html>
  TITLE

  book.add_item('text/message.xhtml').add_content(StringIO.new(<<~MESSAGE))
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
    <p class="cutline">≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡</p>
    <p class="makerifm">作者：#{author}</p>
    <p class="makerifm">译者：#{translators.join(', ')}</p>
    <p class="makerifm">轻之国度：https://www.lightnovel.cn</p>
    <p class="makerifm">仅供个人学习交流使用，禁作商业用途</p>
    <p class="makerifm">下载后请在24小时内删除，LK不负担任何责任</p>
    <p class="makerifm">请尊重翻译、扫图、录入、校对的辛勤劳动，转载请保留信息</p>
    <p class="cutline">≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡</p>

      </div>
    </body>
    </html>
  MESSAGE

  book.add_item('text/introduction.xhtml').add_content(StringIO.new(<<~INTRODUCTION))
    <?xml version="1.0" encoding="utf-8"?>
    <!DOCTYPE html>

    <html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
    <head>
      <link href="../Styles/style.css" rel="stylesheet" type="text/css"/>

      <title>简介</title>
    </head>
    <body>
      <div>

    <h1 class="color1">简介</h1>
    #{abstract}

      </div>
    </body>
    </html>
  INTRODUCTION

  book.add_item('Text/contents.xhtml').add_content(StringIO.new(<<~CONTENTS))
    <?xml version="1.0" encoding="utf-8"?>
    <!DOCTYPE html>

    <html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
    <head>
      <link href="../Styles/style.css" rel="stylesheet" type="text/css"/>

      <title>contents</title>
    </head>
    <body>
      <div>
    <h1 class="mbt15 colorco">目录</h1>

    <table class="tdcenter">
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

book.generate_epub '../n8440fe.epub'

#!/usr/bin/env ruby

if ARGV.length != 1
  puts "Usage: ./make_tex_recent_version.rb CHAPTER"
end

Dir.chdir __dir__
desired_chapter_start = Integer ARGV[0]
tex_src = File.read 'n8440fe.tex', mode: 'rb', encoding: 'utf-8'
tex_src.sub! '% \setcounter{subsection}{<N8440FE_SUBSECTION_COUNTER>}',
  "\\setcounter{subsection}{#{desired_chapter_start - 1}}"
tex_src.gsub!(/\\input\{(\d{4})\}/) do |match|
  Regexp.last_match(1).to_i >= desired_chapter_start ? match : ''
end

puts tex_src

@pushd %~dp0
ruby epub\make_epub.rb
latexmk -cd -f -lualatex -interaction=nonstopmode -synctex=1 n8440fe.tex
ruby make_tex_recent_version.rb 57 > n8440fe_recent.tex
latexmk -cd -f -lualatex -interaction=nonstopmode -synctex=1 n8440fe_recent.tex
@popd
@IF %0 == "%~0" pause

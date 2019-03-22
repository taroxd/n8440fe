@pushd %~dp0
ruby epub\make_epub.rb
latexmk -cd -f -lualatex -interaction=nonstopmode -synctex=1 n8440fe.tex
@popd
@IF %0 == "%~0" pause

@pushd %~dp0
git checkout gh-pages
git reset HEAD~
git rebase master
ruby epub\make_epub.rb
latexmk -cd -f -lualatex -interaction=nonstopmode -synctex=1 n8440fe.tex
git commit -m "update"
git push -f
git checkout master
@popd
@IF %0 == "%~0" pause

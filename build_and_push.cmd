@pushd %~dp0
git checkout gh-pages
git reset HEAD~
git rebase master
call .\build.cmd
git add .
git commit -m "update"
git push -f

@REM cleaning
latexmk -C
del n8440fe.ltjruby
del n8440fe_recent.*

git checkout master

@popd
@IF %0 == "%~0" pause

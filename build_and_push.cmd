@pushd %~dp0
git checkout gh-pages
git reset HEAD~
@call .\cleanup.cmd
git rebase master
@call .\build.cmd
git add .
git commit -m "update"
git push -f
@call .\cleanup.cmd
git checkout master

@popd
@IF %0 == "%~0" pause

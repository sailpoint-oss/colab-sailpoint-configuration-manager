::=================================================================

:: Perform basic git-pull, git-add, git-commit, git-push actions
::=================================================================

echo off
set action=%1
set msg=%2

if %action%==add (git add .)
if %action%==pull (git pull)
if %action%==push (git push)
if %action%==commit (git commit -a -m %msg%)
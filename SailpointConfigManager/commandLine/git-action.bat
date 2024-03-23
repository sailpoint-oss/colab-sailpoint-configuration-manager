::=================================================================

:: Perform basic git-pull, git-add, git-commit, git-push actions
::=================================================================

@echo off
set action=%1
set param=%2

if %action%==add (git add %param%)
if %action%==pull (git pull)
if %action%==push (git push)
if %action%==commit (git commit -a -m %param%)
if %action%==branch (git branch %param%)
if %action%==checkout (git checkout %param%)
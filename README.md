# devops

The runner is trying to run your file as a script, but it looks like your file is missing the execute bit.

Example Error:
/home/runner/work/_temp/62e75df7-5b8e-4d5b-b728-cbac6fff4ad1.sh: line 1: devops/scripts/*.sh: Permission denied
Error: Process completed with exit code 126.

On Linux or macOS, run:

chmod +x scripts/
git add .

On Windows, run:

git add --chmod=+x -- scripts/*
git add --chmod=+x -- scripts/*.*

And then push the changes back up.
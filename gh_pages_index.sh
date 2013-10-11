#! /bin/bash
# http -j --pretty all https://api.github.com/users/1and1/repos | less -R

http -j --pretty format "https://api.github.com/users/1and1/repos" | grep "branches_url" | readarray lines
echo $lines
echo ${#lines[@]}
exit

while read link; do
    link=$(cut -f4 -d'"' <<<"$link" | sed -e 's~{/branch}~/gh-pages~')
    echo "$link"
    echo http -j -h "$link"
    http -j -h "$link" | grep "200 OK" && echo "!!! HAS PAGES"
done </tmp/gh-makeindex-$USER.tmp

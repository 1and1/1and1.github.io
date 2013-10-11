#! /bin/bash
# http -j --pretty all https://api.github.com/users/1and1/repos | less -R

cached=true; test "$1" = "-c" && shift || cached=false
$cached || rm "/tmp/gh_pages_index-$USER"*".txt"

tmpidx="/tmp/gh_pages_index-$USER.txt"
$cached && test -f "$tmpidx" \
    || http -j --pretty format "https://api.github.com/users/1and1/repos" | grep "branches_url" >"$tmpidx"

declare -a lines
#sort "$tmpidx" | tee /dev/stderr | readarray lines
readarray lines <"$tmpidx"
echo "<!-- GH Pages Index: ${#lines[@]} projects found -->"
echo "        <ul>"

for link in "${lines[@]}"; do
    link=$(cut -f4 -d'"' <<<"$link" | sed -e 's~{/branch}~/gh-pages~')
    tmplink="/tmp/gh_pages_index-$USER-"$(shasum <<<"$link" | tr -dc '0-9a-z')".txt"
    $cached && test -f "$tmplink" || http -j --pretty format "$link" >"$tmplink"
    if grep -qs "name.*gh-pages" <"$tmplink"; then
        grep "html.*/tree/gh-pages" <"$tmplink" | cut -f5 -d/
    fi
done | sort | while read project; do
    cat <<.
            <li>
                <a href="https://github.com/1and1/$project/tree/gh-pages">✍</a>
                <a href="http://1and1.github.io/$project/">$project</a>
            </li>
.
done

echo "        </ul>"
echo "<!-- GH Pages Index: END -->"
echo

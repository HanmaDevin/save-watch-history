#!/usr/bin/env nu
def main [] { help }
# The repository path and history file
let REPO = $"($env.HOME)/save-watch-history"
let WATCHLIST = $"($REPO)/watch-history.txt"
if not ($WATCHLIST | path exists) { touch $WATCHLIST }
def sync-repo [] {
    if not ($REPO | path exists) { error make {
        msg: $"Repository not found at ($REPO)"
    } }
    cd $REPO
    git pull e> /dev/null
}
def get-history [] {
    if not ($WATCHLIST | path exists) { error make {
        msg: $"Could not find ($WATCHLIST)"
    } }
    open $WATCHLIST | lines | parse -r '(?P<Series>.*?) (?P<Details>(?:Episode|Part|S\d+E\d+).*)' | upsert Series { |it| 
        $it.Series 
        | str replace -r '\[Reaktor\](Ao no Exorcist).*' '$1'
        | str replace -r '(The Boondocks).*' '$1'
    }
}
def "main save" [] {
    sync-repo
    print "Tracking watch history..."
    loop {
        let watching = playerctl metadata xesam:title | str trim
        if ($watching | is-not-empty) {
            let history = (open $WATCHLIST | lines)
            if ($watching not-in $history) {
                $watching | save --append $WATCHLIST
                print $"Saved: ($watching)"
                git add $WATCHLIST
                git commit -m $"added ($watching)"
                git push e> /dev/null
            }
        }
        sleep 300sec
    }
}
# Show the last episode of a specific series (or just the last overall)
def "main last" [name?: string] {
    let history = (open $WATCHLIST | lines | wrap Title)
    if ($name | is-empty) { return ($history | last 1) }
    let matches = ($history | where {|it| $it.Title =~ ($name | str downcase)})
    if ($matches | is-empty) { print $"Sorry, you haven't watched anything like ($name) :\(" } else {
        $matches | last 1
    }
}
def "main all" [] {
    open $WATCHLIST | lines | each { |line|
        # Regex to strip Episode/Part/Season info
        $line 
        | str replace -r ' (Episode|Part [0-9]+|S[0-9]{2}E[0-9]{2}).*' ''
        | str replace -r '\[Reaktor\](Ao no Exorcist).*' '$1'
        | str replace -r '(The Boondocks).*' '$1'
    } | uniq | sort | wrap "Series Name"
}
def "main update" [] {
    sync-repo
    print "History updated from remote."
}

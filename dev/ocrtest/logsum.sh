#!/bin/bash
# logsum.sh ["yyyy-mm-dd HH:MM"]: summary of all profile logs since that time (default: last 24 h)
# writes dev/ocrtest/logsum_<date>.txt and prints it. Used by dev/LogSummary.bat
ROOT="$(cd "$(dirname "$0")/../.." && pwd)" # bot folder = 2 levels above this script (dev/ocrtest)
cd "$ROOT/Profiles" || exit 1
S=${1:-$(date -d '24 hours ago' '+%Y-%m-%d %H:%M')}
D0=$(echo "$S" | cut -c1-10)
OUT=$ROOT/dev/ocrtest/logsum_$(date '+%Y-%m-%d_%H%M').txt
ALL=$(mktemp)
for f in */Logs/20*.log; do
	fd=$(basename "$f" | cut -c1-10)
	[[ "$fd" < "$D0" ]] && [[ $(date -r "$f" '+%Y-%m-%d') < "$D0" ]] && continue
	a=${f%%/*}
	awk -v S="$S" -v A="$a" 'match($0,/\[(20[0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9:]+)/){t=substr($0,RSTART+1,19); if(t>=S) print A" "$0}' "$f"
done > "$ALL"
{
echo "LOG SUMMARY since $S (made $(date '+%F %T'))"
echo
echo "== account switches: $(grep -c 'Successfully Switch' "$ALL") ok, problems:"
grep -h -E "Switching account failed|not on its page grid|did not scroll|Village name did not change|account .* not clicked" "$ALL" | sed -E 's/^(\w+) .*\[([0-9-]+ [0-9:]+)\.[0-9]+\] /\1 \2 /' | tail -15
echo
echo "== gems per profile (a profile with 2 very different values played a wrong account)"
grep -h "\[GEM\]:[0-9]" "$ALL" | awk '{print $1, $NF}' | sort -u | awk '{a[$1]=a[$1]" "$2} END {for (k in a) print k":"a[k]}' | sort
echo
echo "== errors (red log lines), grouped"
grep -E "^\w+ .{0,4}E " "$ALL" | sed -E 's/^(\w+) .*\] /\1 /' | sed -E 's/[0-9]+/N/g' | sort | uniq -c | sort -rn | head -25
echo
echo "== crashes / restarts"
grep -h -i -E "AutoIt Error|Line [0-9]+ \(File|Restarting bot|Android .*reboot|CoC .*restart|gfxError" "$ALL" | cut -c1-160 | tail -10
echo
echo "== warnings that repeat (top 20)"
grep -h -i -E "fail|not found|cannot|not readable|unknown|wrong|skip" "$ALL" | grep -E " [LE] " | sed -E 's/^(\w+) .*\] /\1 /' | sed -E 's/^\w+ //' | sed -E 's/[0-9][0-9 ,.]*/N/g' | sort | uniq -c | sort -rn | head -20
echo
echo "== work done"
for k in "Wall upgrade started|Upgraded wall" "Auto Upgrade: .*cost|upgrade started" "Upgrade .* cost: " "Donating [0-9]" "Clan Capital Gold collected" "Treasury collected" "Rush TH" "Fill Request with cake"; do
	echo "  $(grep -c -E "$k" "$ALL")  $k"
done
echo
echo "== Build menu: cost not readable $(grep -c 'cost not readable' "$ALL"), list still moving $(grep -c 'still moving' "$ALL"), builders OCR bad $(grep -c 'Bad OCR read Free/Total' "$ALL")"
echo "== debug images saved since $D0:"
find . -path "*Temp/Debug/*" -type f -newermt "$D0" | sed -E 's#^\./([^/]+)/.*/Debug/([^/]+)/.*#\1 \2#' | sort | uniq -c
} > "$OUT"
rm -f "$ALL"
cat "$OUT"
echo
echo "saved: $OUT"

#!/usr/bin/env bash
# Fetch the BedMachine Antarctica netCDF from NSIDC (Earthdata Cloud) and
# record its URL, size and SHA-256 in fetch.tsv, the input of
# bedmachine_cog.py. Needs a NASA Earthdata login token in EDL_TOKEN.
#
#   EDL_TOKEN=... bash bytes/fetch.sh RAW
set -euo pipefail
[ $# -eq 1 ] || { sed -n '2,6p' "$0"; exit 1; }
: "${EDL_TOKEN:?set EDL_TOKEN to an Earthdata login token}"
raw=$1
f=NSIDC-0756_BedMachineAntarctica_19700101-20191001_V04.1.nc
u=https://data.nsidc.earthdatacloud.nasa.gov/nsidc-cumulus-prod-protected/MEASURES/NSIDC-0756/4/1970/01/01/$f
mkdir -p "$raw"
# the token goes in a header file, not on the command line
hdr=$(mktemp); trap 'rm -f "$hdr"' EXIT; chmod 600 "$hdr"
printf 'Authorization: Bearer %s\n' "$EDL_TOKEN" > "$hdr"
curl -L --fail -H @"$hdr" -o "$raw/$f" "$u"
printf '%s\t%s\t%s\t%s\n' "$f" "$(stat -c %s "$raw/$f")" "$(sha256sum "$raw/$f" | cut -d' ' -f1)" "$u" > "$raw/fetch.tsv"
cat "$raw/fetch.tsv"

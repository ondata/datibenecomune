#!/bin/bash

### requisiti ###
# Miller https://github.com/johnkerl/miller
### requisiti ###

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata

URL="https://www.change.org/api-proxy/-/petitions/25684771"

# leggi la risposta HTTP del sito
code=$(curl -s -L -o /dev/null -w "%{http_code}" ''"$URL"'')

# se il sito è raggiungibile scarica i dati
if [ $code -eq 200 ]; then

  curl -kLs "$URL" | jq . >"$folder"/../risorse/datiChange.json
  <"$folder"/../risorse/datiChange.json jq -r '.total_signature_count' >"$folder"/../risorse/firmatariChange

fi

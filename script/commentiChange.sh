#!/bin/bash

### requisiti ###
# Miller https://github.com/johnkerl/miller
### requisiti ###

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata

rm "$folder"/rawdata/commnenti.jsonl

check="false"
offset=0
# finché non sei all'ultima pagina dei commenti, scarica dati
while [[ "$check" == "false" ]]; do
  # scarica dati
  curl -kL "https://www.change.org/api-proxy/-/comments?offset="$offset"&commentable_type=Event&commentable_id=25684771" | jq . >"$folder"/rawdata/data.json
  # etrai i commenti in jsonline e aggiungili in append
  jq <"$folder"/rawdata/data.json -c '.items|.[]' >>"$folder"/rawdata/commnenti.jsonl
  # verifica se sia l'ultima pagina con commenti disponibili
  check=$(jq <"$folder"/rawdata/data.json -r '.last_page')
  # incrementa di 10 l'offset per sfogliare le pagine
  let offset=offset+10
done

# converti il jsonline in CSV
mlr --j2c cut -f id,comment,user:id,user:first_name,user:last_name,created_at,user:city,user:country_code,user:description,user:photo:url then unsparsify "$folder"/rawdata/commnenti.jsonl >"$folder"/rawdata/commnentiChange.csv

mv "$folder"/rawdata/commnentiChange.csv "$folder"/../risorse/commnentiChange.csv
mv "$folder"/rawdata/commnenti.jsonl "$folder"/../risorse/commnentiChange.jsonl

# cancella file temporanei di lavoro
rm "$folder"/rawdata/commnenti.jsonl
rm "$folder"/rawdata/data.json

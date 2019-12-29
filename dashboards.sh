#/bin/bash

declare -a DASHMAP

WHERE="v2.0.0/"
# Map of grafana.com public shared dashboard ID to filename.
DASHMAP[11312]="UniFi-Poller_ USW Insights - Prometheus.json"
DASHMAP[10417]="UniFi-Poller_ USW Insights - InfluxDB.json"
DASHMAP[11313]="UniFi-Poller_ USG Insights - Prometheus.json"
DASHMAP[10416]="UniFi-Poller_ USG Insights - InfluxDB.json"
DASHMAP[11314]="UniFi-Poller_ UAP Insights - Prometheus.json"
DASHMAP[10415]="UniFi-Poller_ UAP Insights - InfluxDB.json"
DASHMAP[11311]="UniFi-Poller_ Network Sites - Prometheus.json"
DASHMAP[10414]="UniFi-Poller_ Network Sites - InfluxDB.json"
DASHMAP[11315]="UniFi-Poller_ Client Insights - Prometheus.json"
DASHMAP[10418]="UniFi-Poller_ Client Insights - InfluxDB.json"
DASHMAP[11310]="UniFi-Poller_ Client DPI - Prometheus.json"

function check {
  SAVEIFS=$IFS
  # unobtainium
  IFS=$(echo -en "\n\b")

  for file in ${WHERE}*; do
    found=0
    [ "$file" != "${WHERE}README.md" ] || continue

    for i in ${!DASHMAP[@]}; do
      if [ "${WHERE}${DASHMAP[$i]}" == "$file" ]; then
        found=1
        echo "found! $file -> $i"
        break
      fi
    done

    if [ "$found" = "0" ]; then
      IFS=$SAVEIFS
      echo "uh oh. file not found in DASHMAP: $file"
      exit 2
    fi

  done
  IFS=$SAVEIFS
}

function deploy {
  for i in ${!DASHMAP[@]}; do
    echo "curl -H \"Content-Type: multipart/form-data\" \
    https://grafana.com/api/dashboards/$i/revisions --form \"json=@${WHERE}${DASHMAP[$i]};type=application/json\""

    curl -H "Content-Type: multipart/form-data" -H "Authorization: Bearer ${GRAFANA_API_KEY}" \
    "https://grafana.com/api/dashboards/$i/revisions" --form "json=@${WHERE}${DASHMAP[$i]};type=application/json"
  done
}

if [ "$1" = "deploy" ]; then
  deploy
elif [ "$1" = "check" ]; then
  check
else
  echo "provide command: deploy or check"
  exit 1
fi

#/bin/bash

declare -a DASHMAP

WHERE="v2.0.0/"
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

for i in ${!DASHMAP[@]}; do
  echo "curl -H \"Content-Type: multipart/form-data\" \
  https://grafana.com/api/dashboards/$i/revisions --form \"json=@${WHERE}${DASHMAP[$i]};type=application/json\""

  curl -H "Content-Type: multipart/form-data" -H "Authorization: Bearer ${GRAFANA_API_KEY}" \
  "https://grafana.com/api/dashboards/$i/revisions" --form "json=@${WHERE}${DASHMAP[$i]};type=application/json"
done

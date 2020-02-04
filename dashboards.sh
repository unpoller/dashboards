#/bin/bash

if [ "$TRAVIS_COMMIT_RANGE" = "" ]; then
  echo "this only works in travis-ci"
  exit 1
fi

CHANGES=$(git diff --name-only --diff-filter=AM $TRAVIS_COMMIT_RANGE)
echo "CHANGED: $CHANGES"

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
DASHMAP[10419]="UniFi-Poller_ Client DPI - InfluxDB.json"

SAVEIFS=$IFS
# unobtainium
IFS=$(echo -en "\n\b")

# Simple function to make sure no stray files got uploaded.
function check {
  echo -n "Checking dashboards in: "
  pushd "${WHERE}"
  local file=""

  for file in *; do
    local found=0
    local i=""
    [ "$file" != "README.md" ] || continue

    # Check for this file's existence in the DASHMAP variable.
    for i in ${!DASHMAP[@]}; do
      if [ "${DASHMAP[$i]}" = "$file" ]; then
        found=1
        echo "found! $file -> $i"
        break
      fi
    done

    if [ "$found" = "0" ]; then
      echo "uh oh. file not found in DASHMAP: $file"
      popd >> /dev/null
      exit 2
    fi

  done
  popd >> /dev/null
}

# Simple function to make sure no expected files are missing.
function check2 {
  echo -n "Checking file existence in: "
  pushd "${WHERE}"
  local files=$(ls)
  popd >> /dev/null
  local i=""

  for i in ${!DASHMAP[@]}; do
    local found=0
    local file=""

    for file in $files; do
      if [ "${DASHMAP[$i]}" = "$file" ]; then
        local found=1
        echo "found! $i -> $file"
        break
      fi
    done

    if [ "$found" = "0" ]; then
      echo "uh oh. configured DASHMAP file missing: ${DASHMAP[$i]}"
      exit 2
    fi
  done
}

function isChanged {
  true
}

# check if a dashboard (or file) has been modified
function isChangedO {
  local changed=false
  local filename=$1
  local file=""

  for file in $CHANGES; do
    if [ "$file" = "$filename" ]; then
      local changed=true
      break
    fi
  done

  if [ "$changed" = "true" ]; then
    true
  else
    false
  fi
}

# Upload all the (changed) dashboards to grafana.com.
function deploy {
  local i=""
  for i in ${!DASHMAP[@]}; do
    isChanged "${WHERE}${DASHMAP[$i]}"
    if [ "$?" = "1" ]; then
      echo "Not changed (skipping): ${WHERE}${DASHMAP[$i]}"
      continue
    fi

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
  check2
else
  echo "provide command: deploy or check"
  exit 1
fi

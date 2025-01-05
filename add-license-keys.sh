#!/bin/bash
SWITCHES=("r1" "r2" "r3" "r4" "r5" "r6")

for switch in ${SWITCHES[@]}; do
  echo -n "Checking for installed cRPD license on $switch..."
  license=$(docker exec -it clab-crpd-segment-routing-$switch cli show system license | grep SKU | xargs)
  if [ -z "$license" ]; then
    if [ ! -e junos.lic ]; then
      echo "please download your free eval license key from https://www.juniper.net/us/en/dm/crpd-free-trial.html"
      echo "(login required) and rename it to 'junos.lic' add place it in the root of this repository"
    fi
    echo -n "[FAILED] >>> Adding license key 'junos.lic' to clab-crpd-segment-routing-$switch..."
    docker cp junos.lic clab-crpd-segment-routing-$switch:/config/license/safenet/junos.lic >/dev/null 2>&1
    docker exec -it clab-crpd-segment-routing-$switch cli request system license add /config/license/safenet/junos.lic >/dev/null 2>&1
    echo "[OK]"
  else
    echo "[OK]"
  fi
done

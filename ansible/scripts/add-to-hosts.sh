#! /usr/bin/env bash
set -euo pipefail

INGRESS_IP="${INGRESS_IP:-192.168.56.95}"
ISTIO_IP="${ISTIO_IP:-192.168.56.91}"

entries=(
    "$INGRESS_IP dashboard.local"
    "$INGRESS_IP app.local"
    "$INGRESS_IP monitoring.local"
    "$ISTIO_IP istio.local"
)

for entry in "${entries[@]}"; do
    host="$(echo "$entry" | awk '{print $2}')"
    if grep -qE "[[:space:]]$host\$" /etc/hosts; then
        echo "Already exists: $host"
    else
        echo "Adding: $entry"
        echo "$entry" | sudo tee -a /etc/hosts >/dev/null
    fi
done

echo "Done. In case you need it: sudo systemd-resolve --flush-caches"
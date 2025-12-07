#!/bin/sh
set -u

echo "Starting entrypoint..."

TEMPLATE=/usr/share/nginx/html/index.template.html
TARGET=/usr/share/nginx/html/index.html

INSTANCE_ID="unknown"

# Basis-URL aus ECS (V4 bevorzugt, sonst V3)
META_BASE="${ECS_CONTAINER_METADATA_URI_V4:-${ECS_CONTAINER_METADATA_URI_V3:-}}"

if [ -n "$META_BASE" ]; then
  # WICHTIG: Task-Metadaten liegen unter /task
  TASK_URL="$META_BASE/task"
  echo "Fetching ECS task metadata from $TASK_URL"
  JSON=$(curl -s "$TASK_URL" || true)

  # Zum Debuggen siehst du im Log, ob was kommt
  echo "Task metadata JSON: $JSON"

  # TaskARN aus dem JSON holen
  TASK_ARN=$(echo "$JSON" | grep -o '"TaskARN":"[^"]*"' | head -n1 | sed 's/.*"TaskARN":"\([^"]*\)".*/\1/')

  if [ -n "$TASK_ARN" ]; then
    INSTANCE_ID="${TASK_ARN##*/}"
  fi
fi

echo "Using INSTANCE_ID=$INSTANCE_ID"

if [ -f "$TEMPLATE" ]; then
  # Platzhalter ersetzen
  sed "s/INSTANCE_ID_PLACEHOLDER/$INSTANCE_ID/g" "$TEMPLATE" > "$TARGET"
else
  echo "Template not found at $TEMPLATE, writing fallback index.html"
  echo "<html><body><h1>No template found</h1><p>INSTANCE_ID=$INSTANCE_ID</p></body></html>" > "$TARGET"
fi

echo "Starting nginx..."
exec nginx -g 'daemon off;'

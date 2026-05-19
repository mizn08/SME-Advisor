#!/usr/bin/env bash
# Backup Postgres volume from Docker Compose (run on EC2)
set -euo pipefail
STAMP=$(date +%Y%m%d_%H%M%S)
OUT="bnpl_backup_${STAMP}.sql"

docker compose exec -T db pg_dump -U "${POSTGRES_USER:-postgres}" "${POSTGRES_DB:-bnpl_db}" > "$OUT"
echo "Wrote $OUT — copy to S3: aws s3 cp $OUT s3://your-bucket/backups/"

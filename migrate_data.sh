#!/bin/bash
usage() {
echo "---"
echo "$0 <hostname where database resides> <database name> <database user> <database password> <gcp project> <gcp bucket> <gcp sql instance> <gcp database> <gcp db user> <service account email>"
}

if [ "$#" -lt 8 ]; then
  usage
  exit 1
fi

# der vi kopierer fra
DB_HOST=$1
DB_NAME=$2
DB_USER=$3
export PGPASSWORD=$4

# der vi kopierer til
GCP_PROJECT=$5 # etterlatte
GCP_INSTANCE=$6 # etterlatte-behandling
GCP_DATABASE=$7 # sakogbehandlinger
GCP_DB_USER=$8 # postgres
GCP_CONTEXT=$9

# dump database
pg_dump -h ${DB_HOST} -d ${DB_NAME} -U ${DB_USER} --data-only --exclude-table-data=flyway_schema_history -v \
	> /data/${DB_NAME}.dmp.gz

# move database dump to bucket
gcloud config set project ${GCP_PROJECT}
# miljø (trenger vi denne ref hvordan vi spesifiserer databaser)
gcloud config set context ${GCP_CONTEXT}
gcloud auth activate-service-account --key-file /var/run/secrets/nais.io/migration-user/user

# import database in gcp
gcloud sql import sql ${GCP_INSTANCE} /data/${DB_NAME}.dmp.gz \
  --database=${GCP_DATABASE} \
  --user=${GCP_DB_USER} \
  --quiet

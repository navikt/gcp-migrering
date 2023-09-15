#!/bin/bash
usage() {
  cat <<EOF
Usage: $0 <hostname> <database> <db_user> <db_password> <gcp_project> <gcp_bucket> <gcp_instance> <gcp_db> <gcp_db_user> <service_account_email> <pg_dump_flags>

Parameters:
  <hostname>               Hostname where the database resides
  <database>               Name of the database
  <db_user>                Database user
  <db_password>            Database password
  <gcp_project>            Google Cloud Platform project name
  <gcp_bucket>             GCP storage bucket name
  <gcp_instance>           GCP SQL instance name
  <gcp_db>                 GCP database name
  <gcp_db_user>            GCP database user
  <service_account_email>  GCP service account email
  <pg_dump_flags>          Additional flags for pg_dump
EOF
}

if [ "$#" -lt 9 ]; then
  usage
  exit 1
fi

DB_HOST=$1
DB_NAME=$2
DB_USER=$3
export PGPASSWORD=$4
GCP_PROJECT=$5
GCP_BUCKET=$6
GCP_INSTANCE=$7
GCP_DATABASE=$8
GCP_DB_USER=$9
GCP_SA_EMAIL=$10
PG_DUMP_FLAGS=$11



# dump database
pg_dump -h ${DB_HOST} -d ${DB_NAME} -U ${DB_USER} --format=plain --no-owner --no-acl ${PG_DUMP_FLAGS} -v \
	> /data/${DB_NAME}.dmp.gz

# move database dump to bucket
gcloud config set project ${GCP_PROJECT}
gcloud auth activate-service-account --key-file /var/run/secrets/nais.io/migration-user/user

gsutil mb -l EUROPE-NORTH1 gs://"${GCP_BUCKET}"
gsutil iam ch serviceAccount:"${GCP_SA_EMAIL}":objectAdmin gs://"${GCP_BUCKET}"

service_account_email=$(gcloud sql instances describe ${GCP_INSTANCE} | yq '.serviceAccountEmailAddress')
gsutil iam ch serviceAccount:"${service_account_email}":objectViewer gs://"${GCP_BUCKET}"

gsutil -m -o GSUtil:parallel_composite_upload_threshold=150M cp /data/${DB_NAME}.dmp.gz gs://"${GCP_BUCKET}"/

# import database in gcp
gcloud sql import sql ${GCP_INSTANCE} gs://${GCP_BUCKET}/${DB_NAME}.dmp.gz \
  --database=${GCP_DATABASE} \
  --user=${GCP_DB_USER} \
  --quiet

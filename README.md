# gcp-migrering

Verktøy for å gjennomføre databasemigrering fra on-premises databaser til Google Cloud SQL.

Les mer om migrering med `pg_dump` hos [docs.nais.io](https://docs.nais.io/persistence/postgres/how-to/migrating-databases-to-gcp).

## Bruk

Få tak i token for en egnet Google Service Account og legg inn i [secret.yaml](./secret.yaml).
Deploy denne til clusteret.

```
kubectl apply -f secret.yaml
```

Start appen som inneholder verktøyene ved å applye til ditt namespace: 
```
kubectl apply -f gcloud.yaml
```

Exec inn i pod'en for å kjøre ønskede kommandoer:
```
kubectl exec -it <navn på pod> -- sh
```

Kjør skriptet migrate_data.sh eller følg beskrivelsen i ovennevnte dokumentasjon. 
Parametere for kjøring av skriptet er:
1. DB_HOST: On-prem postgres server
2. DN_NAME: On-prem databasenavn
3. DB_USER: On-prem databasebruker
4. DB_PASS: On-prem databasepassord
5. GCP_PROJECT: Prosjektet der databasen ligger i Google Cloud
6. GCP_BUCKET: Bøtte i Google Cloud der dumpen legges (må være globalt unik)
7. GCP_INSTANCE: Google Cloud SQL instansnavn (som regel samme som app)
8. GCP_DATABASE: Google Cloud SQL databasenavn (som regel samme som app)
9. GCP_DB_USER: Google Cloud SQL databasebruker (som regel samme som app)
10. GCP_SA_EMAIL: Google Cloud service account 
11. PG_DUMP_FLAGS: On-prem postgres flagg som skal benyttes ved kjøring av pg_dump

```
sh migrate_data.sh DB_HOST DN_NAME DB_USER DB_PASS GCP_PROJECT GCP_BUCKET GCP_INSTANCE GCP_DATABASE GCP_DB_USER GCP_SA_EMAIL PG_DUMP_FLAGS
```

Når du er ferdig bør du slette secret og app:
```
kubectl delete -f gcloud.yaml
kubectl delete -f secret.yaml
```

## Innhold

[gcloud pod spec](./gcloud.yaml) er pod spec'en som innholder alle verktøy man trenger. Denne er bygget fra [gcloud-psql repository](https://github.com/nais/gcloud-psql). Pod'en har ikke lenger et fysisk volum mountet da dette ikke er støttet on-premises, så dersom man skal eksportere store databaser må man benytte en annen metode. Disk'en tilgjengelig er oppad begrenset til det nodenden kjører på  har tilgjengelig.

[skript for migrering](./migrate_data.sh) dersom man har opprettet secret med secret.yaml og har alle parametere kan dette skriptet brukes for å gjøre hele migreringsjobben. Dvs den lager bøtte, dumper on-prem postgres, setter opp rettigheter som trengs og importerer dumpen til basen i Google Cloud.

[skript for opprydding](./cleanup_migration.sh) sletter pod og secret.

[secret](./secret.yaml) kan brukes for å lagre hemmeligheten man benytter for å koble til gcloud/gcp i clusteret. I [gcloud app spec](./gcloud.yaml) er det referert til navnet på hemmeligheten (migration-user), så denne kubernetes hemmeligheten må hete det samme, evt må man også endre i app spec.

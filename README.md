# gcp-migrering

Verktøy for å gjennomføre databasemigrering fra on-premises databaser til Google Cloud SQL.

Les mer om migrering med `pg_dump` hos [docs.nais.io](https://docs.nais.io/persistence/postgres/how-to/migrating-databases-to-gcp).

## Bruk

Start appen som inneholder verktøyene ved å applye til ditt namespace: 
```
kubectl apply -f gcloud.yaml
```

Exec inn i pod'en for å kjøre ønskede kommandoer:
```
kubectl exec -it <navn på pod> -- sh
```

## Innhold

[gcloud pod spec](./gcloud.yaml) er pod spec'en som innholder alle verktøy man trenger. Denne er bygget fra [gcloud-psql repository](https://github.com/nais/gcloud-psql). Pod'en har ikke lenger et fysisk volum mountet da dette ikke er støttet on-premises, så dersom man skal eksportere store databaser må man benytte en annen metode. Disk'en tilgjengelig er oppad begrenset til det nodenden kjører på har tilgjengelig.

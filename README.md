# ds-helicone

The goal of this repo is to build a production-ready Helicone helm chart.

## Background 

### Helicone
* [website](helicone.ai) 
* [github](https://github.com/Helicone/helicone/tree/main/docker)
    * Helicone released a `docker-compose.yaml` file with their build. The app sits on the [supabase](https://supabase.com/docs/guides/self-hosting#managing-your-database) platform. 
* [supabase-kubernetes](https://github.com/supabase-community/supabase-kubernetes/tree/main)

## Progress to Date

* ✅ Translate Helicone's `docker-compose.yaml` to a helm chart based on the [supabase-kubernetes](https://github.com/supabase-community/supabase-kubernetes/tree/main) release.
  * supabase-kubernetes adjusted to work in Carta's k8s env
  *  added helicone k8s resources to chart. Includes:
    * helicone web
    * helicone worker
    * clickhouse
    * imgproxy
    * functions
* ✅ Move secrets to Carta's Hashicorp vault (automatically deploys ExternalSecret resource in k8s)
  * Includes JWT_TOKEN, ANON_KEY, and SERVICE_ROLE_KEY keys
  * Clickhouse username & password
  * SMTP setup
  * Terraformed secrets (S3 & RDS - RDS could not be used due to Supabase incompatibility)
* ✅ Confirmed chart runs in k8s


## Issues
1. Postgres container migrations not compatible with RDS
  * This works with a postgres container in k8s. This setup is not acceptable for production deployments @ Carta. We tried setting the chart up with RDS, but this is not currently possible. Supabase relies on several custom extensions that are not avaiable in RDS (issues filed w/ Supabase [here](https://github.com/supabase-community/supabase-on-aws/issues?q=is:issue+is:open+sort:updated-desc+pg)).
  
2. SMTP & SSO errors
  * When configuring SMTP, Helicone throws an error due to the user not having a Stripe account configured. 
  * Not sure how to get SSO running w/ Helicone / Supabase

# Helicone Helm Chart

Launch a self-hosted [Helicone](https://www.helicone.ai/) chart. 

## Architecture 

Helicone is built on top of [Supabase](https://supabase.com) (an open source Firebase alternative). 

![Supabase Infrastructure](.github/content/supabase_infra.png)
<span style="font-size: smaller;"><center><em>Helicone's underlying Supabase Infrastructure (functions and imgproxy components not shown)</em></center></span>

The Helicone components of the build are:

* helicone/web: Helicone's UI
* helicone/worker: The proxy that apps will send requests to
* clickhouse: an open source columnar analytics DB ([documentation](https://clickhouse.com/))

### Disclamer

We use [supabase/postgres](https://hub.docker.com/r/supabase/postgres) to create and manage the Postgres database. This permits you to use replication if needed but you'll have to use the Postgres image provided Supabase or build your own on top of it. You can also choose to use other databases provider like [StackGres](https://stackgres.io/) or [Postgres Operator](https://github.com/zalando/postgres-operator). Note that managed databases like RDS are not currently supported as they do not support [several required Supabase extensions](https://github.com/supabase-community/supabase-on-aws/issues?q=is:issue+pg+).

For the moment we are using a root container to permit the installation of the missing `pgjwt` and `wal2json` extension inside the `initdbScripts`. This is considered a security issue, but you can use your own Postgres image instead with the extension already installed to prevent this. Supabase provides an example of `Dockerfile` for this purpose, you can use [ours](https://hub.docker.com/r/tdeoliv/supabase-bitnami-postgres) or build and host it on your own.

The database configuration we provide is an example using only one master. If you want to go to production, we highly recommend you to use a replicated database.

## Quickstart

> For this section we're using Minikube and Docker to create a Kubernetes cluster

> The `ANON_KEY`, `JWT_SECRET`, and `SERVICE_ROLE_KEY` (under the `supabase` vault entry) were generated using the API KEYS tool at [supabase.com/docs/guides/self-hosting](https://supabase.com/docs/guides/self-hosting).

```bash
# Clone Repository
git clone https://github.com/helicone/helicone-helm-chart

# Switch to charts directory
cd /helicone-helm-chart/helm/helicone

# Create Supabase JWT-based secrets
kubectl -n default create secret generic helicone-supabase \
  --from-literal=ANON_KEY='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICAgInJvbGUiOiAiYW5vbiIsCiAgICAiaXNzIjogInN1cGFiYXNlIiwKICAgICJpYXQiOiAxNjc1NDAwNDAwLAogICAgImV4cCI6IDE4MzMxNjY4MDAKfQ.ztuiBzjaVoFHmoljUXWmnuDN6QU2WgJICeqwyzyZO88' \
  --from-literal=SERVICE_ROLE_KEY='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICAgInJvbGUiOiAic2VydmljZV9yb2xlIiwKICAgICJpc3MiOiAic3VwYWJhc2UiLAogICAgImlhdCI6IDE2NzU0MDA0MDAsCiAgICAiZXhwIjogMTgzMzE2NjgwMAp9.qNsmXzz4tG7eqJPh1Y58DbtIlJBauwpqx39UF-MwM8k' \
  --from-literal=JWT_SECRET='abcdefghijklmnopqrstuvwxyz123456'

# Create SMTP secret
kubectl -n default create secret generic helicone-smtp \
  --from-literal=SMTP_USERNAME='your-mail@example.com' \
  --from-literal=SMTP_PASSWORD='example123456'

# Create postgres secret
kubectl -n default create secret generic helicone-postgres \
  --from-literal=POSTGRES_USER='postgres' \
  --from-literal=POSTGRES_PASSWORD='example123456' 

# Create clickhouse secret
kubectl -n default create secret generic helicone-clickhouse \
  --from-literal=CLICKHOUSE_USER='default' \
  --from-literal=CLICKHOUSE_PASSWORD='default' 

# Install the chart
make helicone
```

The first deployment can take some time to complete (especially auth service). You can view the status of the pods using:

```bash
kubectl get pods -n default

NAME                                       READY   STATUS    RESTARTS   AGE
demo-helicone-auth-cc7498b64-hrtbx         1/1     Running   0          4m28s
demo-helicone-clickhouse-f496846fc-pgkbs   1/1     Running   0          4m28s
demo-helicone-db-6f7959757f-kqbrk          1/1     Running   0          4m27s
demo-helicone-functions-6b6f8b7975-zjs5b   1/1     Running   0          4m27s
demo-helicone-imgproxy-5947679bd-v2rr7     1/1     Running   0          4m28s
demo-helicone-kong-6d4f9b64b4-g87hp        1/1     Running   0          4m28s
demo-helicone-meta-5bd444855b-whch7        1/1     Running   0          4m28s
demo-helicone-realtime-6bfc6c8d79-4lj7m    1/1     Running   0          4m28s
demo-helicone-rest-576f65bc4c-2gf6f        1/1     Running   0          4m28s
demo-helicone-storage-6cc8d4df96-j9xx4     0/1     Pending   0          4m28s
demo-helicone-studio-854b565f6b-xs7kn      1/1     Running   0          4m27s
demo-helicone-web-6bdfc7d7dd-dt2dz         1/1     Running   0          4m28s
demo-helicone-worker-6c959b77f9-s62lr      1/1     Running   0          4m27s
```

### Ingress Configuration

You'll need to configure an ingress controller if you want to access Helicone via the web browser. We'll use NGINX as a reverse proxy in this demo, but your organization will likely use its own load balancer / ingress. 

Install an [NGINX ingress controller](https://kubernetes.github.io/ingress-nginx/) in your local k8s cluster by running:

```bash
make nginx
```

This will create self-signed SSL certificates for each of the Chart's 4 ingresses (kong, studio, web, and worker) and load them to k8s as tls secrets, referenced by each of the ingress configurations. SSL is required for Supabase's `auth` functionality.  

Most browsers do not trust self-signed certificates by default. You will need to manually tell your computer to "trust" these certs. 

> For Mac users, manually [add certificates](support.apple.com/guide/keychain-access/add-certificates-to-a-keychain-kyca2431/mac
) to your keychain and [make them trusted](support.apple.com/guide/keychain-access/change-the-trust-settings-of-a-certificate-kyca11871/mac).

If you just use the `value.example.yaml` file, you can access the following endpoints:

- Helicone App: <http://helicone.localhost>
- Helicone Worker: <http://worker.localhost>
- API: <http://api.localhost>
- Studio App: <http://studio.localhost>

### Uninstall

```Bash
# Uninstall Helm chart
make uninstall

# Delete secrets
kubectl -n default delete secret helicone-supabase
kubectl -n default delete secret helicone-smtp
kubectl -n default delete secret helicone-postgres
kubectl -n default delete secret helicone-clickhouse
```

## Customize

You should adjust the following values in `values.yaml`:

- `JWT_SECRET_NAME`: Reference to Kubernetes secret with JWT secret data `secret`, `anonKey` & `serviceKey`
- `SMTP_SECRET_NAME`: Reference to Kubernetes secret with SMTP credentials `username` & `password`
- `DB_SECRET_NAME`: Reference to Kubernetes secret with Postgres credentials `username` & `password`
- `RELEASE_NAME`: Name used for helm release
- `NAMESPACE`: Namespace used for the helm release
- `API.EXAMPLE.COM` URL to Kong API
- `STUDIO.EXAMPLE.COM` URL to Studio

If you want to use mail, consider to adjust the following values in `values.yaml`:

- `SMTP_ADMIN_MAIL`
- `SMTP_HOST`
- `SMTP_PORT`
- `SMTP_SENDER_NAME`

### JWT Secret

We encourage you to use your own JWT keys by generating a new Kubernetes secret and reference it in `values.yaml`:

```yaml
  jwt:
    secretName: "JWT_SECRET_NAME"
```

The secret can be created with kubectl via command-line:

```bash
kubectl -n NAMESPACE create secret generic JWT_SECRET_NAME \
  --from-literal=secret='JWT_TOKEN_AT_LEAST_32_CHARACTERS_LONG' \
  --from-literal=anonKey='JWT_ANON_KEY' \
  --from-literal=serviceKey='JWT_SERVICE_KEY'
```

> 32 characters long secret can be generated with `openssl rand 64 | base64`
> You can use the [JWT Tool](https://supabase.com/docs/guides/hosting/overview#api-keys) to generate anon and service keys.

### SMTP Secret

Connection credentials for the SMTP mail server will also be provided via Kubernetes secret referenced in `values.yaml`:

```yaml
  smtp:
    secretName: "SMTP_SECRET_NAME"
```

The secret can be created with kubectl via command-line:

```bash
kubectl -n NAMESPACE create secret generic SMTP_SECRET_NAME \
  --from-literal=username='SMTP_USER' \
  --from-literal=password='SMTP_PASSWORD'
```

### DB Secret

DB credentials will also be stored in a Kubernetes secret and referenced in `values.yaml`:

```yaml
  db:
    secretName: "DB_SECRET_NAME"
```

The secret can be created with kubectl via command-line:

```bash
kubectl -n NAMESPACE create secret generic DB_SECRET_NAME \
  --from-literal=username='DB_USER' \
  --from-literal=password='PW_USER'
```

> If you depend on database providers like [StackGres](https://stackgres.io/) or [Postgres Operator](https://github.com/zalando/postgres-operator) you only need to reference the already existing secret in `values.yaml`.

## How to use in Production

We didn't provide a complete configuration to go production because of the multiple possibility.

But here are the important points you have to think about:

- Use a replicated version of the Postgres database.
- Add SSL to the Postgres database.
- Add SSL configuration to the ingresses endpoints using either the `cert-manager` or a LoadBalancer provider.
- Change the domain used in the ingresses endpoints.
- Generate a new secure JWT Secret.

## Troubleshooting

### Ingress Controller and Ingress Class

Depending on your Kubernetes version you might want to fill the `className` property instead of the `kubernetes.io/ingress.class` annotations. For example:

```yml
kong:
  ingress:
    enabled: 'true'
    className: "nginx"
    annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /
```


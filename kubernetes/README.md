# Kubernetes deployment

The Secret Manager add-on and Secret Sync feature are enabled by Terraform in
`infra/modules/gke`. Before applying these manifests, replace
`REPLACE_WITH_GCP_PROJECT_ID` in `secret-provider-class.yaml` with the GCP
project that contains the secrets.

Set the API image before applying the kustomization, for example:

```bash
kubectl -n onepiecetcg set image deployment/onepiecetcg-api \
  api=REGION-docker.pkg.dev/PROJECT_ID/onepiecetcg/api:GIT_SHA
kubectl apply -k kubernetes/
```

The `SecretSync` resource creates the `api-secrets` Kubernetes Secret from
Secret Manager. The API consumes it with `envFrom`; the resulting environment
variables are loaded when the pod starts.

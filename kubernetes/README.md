# Déploiement Kubernetes sur GKE

Les ressources de ce dossier sont appliquées après la création du cluster par
Terraform. Le cluster attendu est l’Autopilot régional
`onepiecetcg-gke` dans `europe-west9`, avec le namespace `onepiecetcg`.

La configuration Terraform active le Secret Manager add-on et Secret Sync dans
`infra/modules/gke`. Les ressources partagées et les permissions IAM sont
décrites dans [../infra/README.md](../infra/README.md).

## Préparer l’accès au cluster

```bash
gcloud container clusters get-credentials onepiecetcg-gke \
  --region europe-west9 \
  --project decouverte-gke
```

## Appliquer les manifests

Depuis la racine du projet :

```bash
kubectl apply -k kubernetes/
```

Le `SecretProviderClass` référence les secrets du projet `decouverte-gke` :

- `database-url`
- `better-auth-secret`
- `oauth-google-client-id`
- `oauth-google-client-secret`

Ne remplace pas ces secrets par des valeurs en clair dans Git.

## Définir les images Artifact Registry

Terraform pousse les images avec le SHA du commit comme tag. Récupère ce tag et
mets à jour les Deployments directement avec `kubectl` :

```bash
cd infra
PROJECT_ID=$(gcloud config get-value project)
IMAGE_TAG=$(terraform output -raw image_tag)

kubectl set image deployment/onepiecetcg-api \
  api=europe-west9-docker.pkg.dev/$PROJECT_ID/onepiecetcg/api:$IMAGE_TAG \
  -n onepiecetcg

kubectl set image deployment/onepiecetcg-web \
  web=europe-west9-docker.pkg.dev/$PROJECT_ID/onepiecetcg/web:$IMAGE_TAG \
  -n onepiecetcg
```

`api.yaml` contient volontairement une image de remplacement pour rester
portable. La commande précédente définit l’image réellement déployée dans le
cluster.

## Secrets et Cloud SQL

`SecretSync` crée automatiquement le Secret Kubernetes `api-secrets`. L’API
le consomme via `envFrom`. Vérifie son état sans afficher les valeurs :

```bash
kubectl get secretsync api-secrets -n onepiecetcg
kubectl get secret api-secrets -n onepiecetcg
kubectl describe secret api-secrets -n onepiecetcg
```

L’API utilise le Cloud SQL Auth Proxy comme sidecar. Le proxy et l’API
partagent `/cloudsql`, ce qui permet de conserver le `DATABASE_URL` utilisé
par Cloud Run. Les logs du proxy sont utiles pour diagnostiquer une connexion
Cloud SQL :

```bash
kubectl logs deployment/onepiecetcg-api \
  -c cloud-sql-proxy \
  -n onepiecetcg
```

## Vérification

```bash
kubectl rollout status deployment/onepiecetcg-api -n onepiecetcg
kubectl rollout status deployment/onepiecetcg-web -n onepiecetcg
kubectl get pods -n onepiecetcg
kubectl get gateway onepiecetcg-gateway -n onepiecetcg
kubectl get httproutes -n onepiecetcg
```

Le Gateway utilise l’IP globale Terraform `gke_gateway_ip`. Configure chez OVH :

```text
optcg       A    <gke_gateway_ip>
api-optcg   A    <gke_gateway_ip>
```

Le certificat Google-managed devient `ACTIVE` après la propagation DNS.

## Dépannage rapide

- `ImagePullBackOff` : vérifie le chemin Artifact Registry et le tag SHA.
- `CreateContainerConfigError` : vérifie que `api-secrets` existe.
- `ProviderError` sur `SecretSync` : vérifie les noms des secrets, leurs
  versions actives et le rôle `roles/secretmanager.secretAccessor`.
- Erreur `/cloudsql/...` ou `ENOENT` : consulte les logs du conteneur
  `cloud-sql-proxy` et vérifie `roles/cloudsql.client`.

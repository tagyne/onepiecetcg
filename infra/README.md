# One Piece TCG — infrastructure GCP

Cette configuration déploie la production sur Google Cloud avec des modules
indépendants pour Cloud Run et GKE. Les ressources partagées restent dans le
module root : Cloud SQL, Artifact Registry, Secret Manager, APIs GCP et le
certificat TLS.

Le chemin GKE utilise un cluster Autopilot régional, Gateway API, Secret
Manager add-on, Secret Sync et le Cloud SQL Auth Proxy en sidecar pour l’API.

## Prérequis

- Terraform >= 1.10
- Docker démarré localement
- Git et Google Cloud CLI
- kubectl
- un projet GCP avec facturation active
- un bucket GCS privé pour le state Terraform si le backend distant est activé
- un client OAuth Google créé dans Google Auth Platform

Les secrets OAuth Google doivent exister dans Secret Manager avec les noms
`oauth-google-client-id` et `oauth-google-client-secret`. Terraform lit leurs
métadonnées ; les valeurs restent dans Secret Manager. Le secret `database-url`
et le secret Better Auth sont gérés par Terraform.

Si tu actives le backend GCS dans `backend.tf`, le bucket doit être privé,
versionné et créé avant `terraform init`. Le backend est actuellement commenté
pour permettre une première utilisation avec un state local.

Authentifie Terraform et Docker :

```bash
gcloud auth login
gcloud auth application-default login
gcloud auth configure-docker europe-west9-docker.pkg.dev
```

## Déployer l’infrastructure

Configure `infra/terraform.tfvars` :

```hcl
project_id       = "decouverte-gke"
region           = "europe-west9"
enable_cloud_run = false
enable_gke       = true
```

`enable_cloud_run` et `enable_gke` contrôlent les deux modules
indépendamment. Les images Docker sont construites localement, taguées avec le
SHA du commit, puis poussées dans Artifact Registry pendant `terraform apply`.

Le dépôt Git doit être propre avant Terraform, car le SHA du commit est utilisé
comme tag d’image.

```bash
cd infra
terraform init
terraform fmt -check
terraform validate
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Le module GKE crée le cluster Autopilot `onepiecetcg-gke` dans `europe-west9`,
active Workload Identity Federation, le Secret Manager add-on et Secret Sync,
et accorde au compte de service Kubernetes de l’API l’accès nécessaire à
Secret Manager et Cloud SQL.

## Déployer les workloads GKE

Récupère les credentials du cluster :

```bash
gcloud container clusters get-credentials onepiecetcg-gke \
  --region europe-west9 \
  --project decouverte-gke
```

Depuis la racine du projet, applique les manifests :

```bash
cd ..
kubectl apply -k kubernetes/
```

Après la création des Deployments, utilise le tag produit par Terraform :

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

Le Deployment API utilise le Secret Kubernetes `api-secrets`, créé par
`SecretSync`, pour injecter les secrets Secret Manager. Le Cloud SQL Auth Proxy
est exécuté comme sidecar et expose le socket Unix attendu par `DATABASE_URL`.

Vérifie les workloads :

```bash
kubectl rollout status deployment/onepiecetcg-api -n onepiecetcg
kubectl rollout status deployment/onepiecetcg-web -n onepiecetcg
kubectl get pods -n onepiecetcg
kubectl get secret api-secrets -n onepiecetcg
kubectl logs deployment/onepiecetcg-api -c cloud-sql-proxy -n onepiecetcg
```

Le secret `api-secrets` ne doit pas être créé manuellement. Si sa création
échoue, vérifie `SecretSync`, `SecretProviderClass` et les événements du
namespace sans afficher les valeurs des secrets.

## DNS et HTTPS

Le module GKE réserve une IP globale dédiée, disponible dans l’output
`gke_gateway_ip`. Chez OVH, configure :

```text
optcg       A    <gke_gateway_ip>
api-optcg   A    <gke_gateway_ip>
```

Le certificat Google-managed devient `ACTIVE` après propagation DNS.

L’output `load_balancer_ip` reste celui du Load Balancer Cloud Run et ne doit
pas être utilisé pour le Gateway GKE.

## Basculer entre Cloud Run et GKE

Modifie les deux flags dans `terraform.tfvars` :

```hcl
enable_cloud_run = false
enable_gke       = true
```

Puis relance `terraform plan` et `terraform apply`. Les ressources partagées
restent gérées par le root ; seuls les modules activés sont créés ou gérés.

## Secrets

Les secrets OAuth Google sont créés manuellement et récupérés avec des data
sources Terraform. Le secret Better Auth et le mot de passe PostgreSQL sont
générés automatiquement.

Les valeurs sensibles ne doivent pas être ajoutées à Git. Le bucket GCS du
backend et le state Terraform doivent rester privés.

## Destruction

La base Cloud SQL et les services Cloud Run ont la protection contre la
destruction activée. Désactive explicitement cette protection avant un
`terraform destroy` volontaire.

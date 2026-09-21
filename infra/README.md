# One Piece TCG — infrastructure GCP

Cette configuration déploie la production sur Google Cloud : Cloud Run,
GKE Autopilot, Cloud SQL, Artifact Registry, Secret Manager et le Load
Balancer global de Cloud Run.

## Prérequis

- Terraform >= 1.10
- Docker démarré localement
- Git et Google Cloud CLI
- kubectl
- un projet GCP avec facturation active
- un bucket GCS privé pour le state Terraform
- un client OAuth Google créé dans Google Auth Platform

Le bucket du state est fourni au premier `terraform init` ; il doit être privé,
versionné et créé avant l'initialisation.

Authentifier Terraform et Docker :

```bash
gcloud auth login
gcloud auth application-default login
gcloud auth configure-docker europe-west9-docker.pkg.dev
```

Les secrets OAuth Google doivent exister dans Secret Manager avec les noms
`oauth-google-client-id` et `oauth-google-client-secret`. Terraform lit leurs
métadonnées ; les valeurs restent dans Secret Manager et sont injectées
directement dans Cloud Run.

Le dépôt Git doit être propre. `terraform apply` récupère le SHA du commit,
construit localement les deux images Docker, les pousse dans Artifact Registry,
puis déploie Cloud Run avec ce SHA comme tag.

```bash
cd infra
terraform init -backend-config="bucket=YOUR_TERRAFORM_STATE_BUCKET"
terraform fmt -check
terraform validate
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Le module GKE crée le cluster Autopilot `onepiecetcg-gke` dans la région
`region` et active Secret Sync. Les manifests Kubernetes sont à la racine
du projet, dans `kubernetes/`. Remplacer
`REPLACE_WITH_GCP_PROJECT_ID` dans `kubernetes/secret-provider-class.yaml`,
puis appliquer les manifests avec :

```bash
kubectl apply -k kubernetes/
```

Le Deployment API utilise le Kubernetes Secret `api-secrets`, créé par la
ressource `SecretSync`, pour injecter les secrets Secret Manager dans ses
variables d'environnement.

Après l'apply, ajouter chez OVH les enregistrements DNS suivants avec la valeur
de l'output `load_balancer_ip` :

```text
optcg       A    <load_balancer_ip>
api-optcg   A    <load_balancer_ip>
```

Le certificat HTTPS géré par Google devient actif après propagation DNS.

Le module GKE réserve également une IP globale dédiée, disponible dans
l'output `gke_gateway_ip`. Lors de la migration vers GKE, faire pointer les
mêmes domaines vers cette IP. L'output `load_balancer_ip` reste celui du
Load Balancer Cloud Run.

## Secrets

Les secrets OAuth Google sont créés manuellement et récupérés avec des data
sources Terraform. Le secret Better Auth et le mot de passe PostgreSQL sont
générés automatiquement.

Les valeurs OAuth ne sont pas lues dans Terraform et n'apparaissent donc pas
dans son state. Le bucket GCS du backend doit néanmoins rester privé.

## Destruction

La base Cloud SQL et les services Cloud Run ont la protection contre la
destruction activée. Désactiver explicitement cette protection avant un
`terraform destroy` volontaire.

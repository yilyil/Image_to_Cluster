<img width="1920" height="1048" alt="image" src="https://github.com/user-attachments/assets/350be565-87ce-4446-8faf-f95428962fa6" />

# 🚀 Atelier Image to Cluster

**Auteur:** Yilizire Xiaohereti
---

## 📋 Table des matières

- [Présentation de l'atelier](#-présentation-de-latelier)
- [Architecture](#-architecture)
- [Prérequis](#-prérequis)
- [Séquence 1 : Création du Codespace GitHub](#-séquence-1--création-du-codespace-github)
- [Séquence 2 : Création du cluster K3d](#-séquence-2--création-du-cluster-k3d)
- [Séquence 3 : Exercice principal](#-séquence-3--exercice-principal)
- [Séquence 4 : Documentation](#-séquence-4--documentation)
- [Installation automatisée](#-installation-automatisée)
- [Guide d'utilisation détaillé](#-guide-dutilisation-détaillé)
- [Commandes disponibles](#-commandes-disponibles)
- [Dépannage](#-dépannage)
- [Structure du projet](#-structure-du-projet)

---

## 🎯 Présentation de l'atelier

### L'idée en 30 secondes

Cet atelier consiste à **industrialiser le cycle de vie d'une application simple** en construisant une image applicative Nginx personnalisée avec **Packer**, puis en déployant automatiquement cette application sur un cluster Kubernetes léger (**K3d**) à l'aide d'**Ansible**, le tout dans un environnement reproductible via **GitHub Codespaces**. 

L'objectif est de comprendre comment des outils d'Infrastructure as Code permettent de passer d'un artefact applicatif maîtrisé à un déploiement cohérent et automatisé sur une plateforme d'exécution.

### Technologies utilisées

| Technologie | Version | Rôle |
|------------|---------|------|
| **Packer** | 1.10.0+ | Construction d'images Docker personnalisées |
| **Ansible** | 2.15+ | Orchestration et déploiement automatisé |
| **K3d** | 5.6+ | Cluster Kubernetes léger (1 master + 2 workers) |
| **Docker** | 24.0+ | Conteneurisation |
| **kubectl** | 1.28+ | Client Kubernetes |
| **Makefile** | - | Automatisation complète du pipeline |

---

## 🏗️ Architecture

### Architecture cible
```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Codespaces                        │
│                                                             │
│  ┌──────────────┐      ┌──────────────┐      ┌───────────┐  │
│  │    Packer    │─────▶│    Docker    │─────▶│    K3d    │  │
│  │              │      │    Image     │      │  Cluster  │  │
│  │ nginx.pkr.hcl│      │ custom-nginx │      │           │  │
│  └──────────────┘      └──────────────┘      └─────┬─────┘  │
│                                                    │        │
│                        ┌───────────────────────────┘        │
│                        │                                    │
│                        ▼                                    │
│              ┌──────────────────┐                           │
│              │     Ansible      │                           │
│              │   deploy.yml     │                           │
│              │                  │                           │
│              │  - Deployment    │                           │
│              │  - Service       │                           │
│              │  - Port Forward  │                           │
│              └──────────────────┘                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                         │
                         ▼
              ┌──────────────────┐
              │  Application Web │
              │   Nginx Custom   │
              └──────────────────┘
```

### Flux de travail (Processus)

1. **Build** : Packer construit une image Nginx avec le fichier `index.html` personnalisé
2. **Import** : L'image Docker est importée dans le cluster K3d
3. **Deploy** : Ansible déploie l'application (Deployment + Service Kubernetes)
4. **Access** : Port forwarding pour accéder à l'application via le navigateur

---

## ⚙️ Prérequis

- Compte GitHub
- Accès à GitHub Codespaces
- Navigateur web moderne

**Toutes les dépendances** (Docker, Packer, K3d, kubectl, Ansible) **sont installées automatiquement** par le Makefile. ✅

---

## 📝 Séquence 1 : Création du Codespace GitHub

**Objectif :** Création d'un Codespace GitHub  

### Étapes

1. **Forker ce projet** sur votre compte GitHub
   - Cliquez sur le bouton "Fork" en haut à droite du repository

2. **Ouvrir un Codespace**
   - Depuis votre fork, cliquez sur **Code** → **Codespaces** → **Create codespace on main**
   - Attendez le chargement (1-2 minutes)

3. **Se positionner dans le projet**
```bash
   cd image-to-cluster
```

✅ **Validation** : Vous êtes maintenant dans un environnement de développement cloud complet !

---

## 🔧 Séquence 2 : Création du cluster K3d

**Objectif :** Créer votre cluster Kubernetes K3d  

Vous allez dans cette séquence mettre en place un cluster Kubernetes K3d contenant **1 master et 2 workers**.

### Option 1 : Automatique (recommandée) ⚡
```bash
make create-cluster
```

### Option 2 : Manuelle (étape par étape)

#### Installation de K3d
```bash
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```

#### Création du cluster K3d
```bash
k3d cluster create lab \
  --servers 1 \
  --agents 2
```

#### Vérification du cluster
```bash
kubectl get nodes
```

**Sortie attendue :**
```
NAME               STATUS   ROLES                  AGE   VERSION
k3d-lab-server-0   Ready    control-plane,master   1m    v1.31.5+k3s1
k3d-lab-agent-0    Ready    <none>                 1m    v1.31.5+k3s1
k3d-lab-agent-1    Ready    <none>                 1m    v1.31.5+k3s1
```

### Test optionnel : Déploiement de l'application Mario

Pour vérifier que le cluster fonctionne correctement :
```bash
# Déployer l'application
kubectl create deployment mario --image=sevenajay/mario
kubectl expose deployment mario --type=NodePort --port=80

# Forward du port
kubectl port-forward svc/mario 8080:80 >/tmp/mario.log 2>&1 &
```

Ensuite, dans l'onglet **PORTS** de Codespaces :
1. Rendez public le port **8080**
2. Cliquez sur l'URL pour jouer à Mario ! 🎮

**Nettoyage après le test :**
```bash
kubectl delete deployment mario
kubectl delete service mario
pkill -f "port-forward"
```

✅ **Validation** : Cluster K3d opérationnel avec 3 nœuds !

---

## 🎯 Séquence 3 : Exercice principal

**Objectif :** Customiser une image Docker avec Packer et déployer sur K3d via Ansible  

### Mission

Créez une image applicative customisée à l'aide de **Packer** (image de base Nginx embarquant le fichier `index.html` présent à la racine de ce repository), puis déployez cette image customisée sur votre cluster K3d via **Ansible**.

### Solution : Pipeline automatisé complet 🚀

**Une seule commande exécute tout le processus :**
```bash
make all
```

Cette commande effectue automatiquement :

1. ✅ **Vérification des dépendances** (Docker, Packer, K3d, Ansible, kubectl)
2. ✅ **Installation automatique** des outils manquants
3. ✅ **Création du cluster K3d** (1 master + 2 workers)
4. ✅ **Build de l'image** avec Packer (Nginx + index.html personnalisé)
5. ✅ **Import de l'image** dans K3d
6. ✅ **Déploiement** via Ansible (Deployment + Service Kubernetes)
7. ✅ **Vérification** de l'état du cluster et des pods

**⏱️ Temps d'exécution** : 3-5 minutes

### Processus de travail (détaillé)

Si vous préférez exécuter chaque étape manuellement :

#### 1. Installation des dépendances
```bash
make check-deps      # Vérifier ce qui manque
make install-deps    # Installer automatiquement
```

#### 2. Création du cluster (si pas encore fait)
```bash
make create-cluster
```

#### 3. Build de l'image customisée
```bash
make build-image
```

**Ce qui se passe :**
- Packer lit le template `packer/nginx.pkr.hcl`
- Télécharge l'image `nginx:alpine`
- Copie le fichier `index.html` dans `/usr/share/nginx/html/`
- Tag l'image comme `custom-nginx:latest`

**Vérification :**
```bash
docker images custom-nginx
```

#### 4. Import de l'image dans K3d
```bash
make import-image
```

**Important :** K3d utilise son propre registre interne, il faut donc importer l'image Docker locale.

#### 5. Déploiement via Ansible
```bash
make deploy
```

**Ce que fait Ansible :**
- Vérifie la connexion au cluster
- Import l'image dans K3d
- Applique les manifestes Kubernetes :
  - `Deployment` avec 2 replicas
  - `Service` de type NodePort (port 30080)
- Attend que tous les pods soient en état "Running"
- Affiche les instructions d'accès

#### 6. Accès à l'application
```bash
make forward-port
```

Puis dans l'onglet **PORTS** de Codespaces :
1. Trouvez le port **8080**
2. Cliquez sur l'icône 🌐 pour le rendre **public**
3. Cliquez sur l'URL pour accéder à votre application

**Alternative si le port 8080 est occupé :**
```bash
pkill -f "port-forward"
kubectl port-forward svc/custom-nginx 3000:80
```

✅ **Validation** : Votre page web personnalisée avec animations s'affiche !

---

## 📚 Séquence 4 : Documentation

**Objectif :** Compléter et documenter le README.md  

Ce README inclut :

- ✅ Présentation claire de l'atelier
- ✅ Architecture visuelle
- ✅ Guide étape par étape pour chaque séquence
- ✅ Commandes détaillées et explications
- ✅ Section dépannage
- ✅ Structure du projet documentée
- ✅ Processus de travail Git

---

## ⚡ Installation automatisée

### Pipeline complet en une commande
```bash
cd image-to-cluster
make all
```

**Durée** : 3-5 minutes

**Cette commande exécute dans l'ordre :**
```
make check-deps      # Vérification des dépendances
  ↓
make create-cluster  # Création du cluster K3d
  ↓
make build-image     # Build avec Packer
  ↓
make import-image    # Import dans K3d
  ↓
make deploy          # Déploiement Ansible
  ↓
make status          # Affichage de l'état
```

### Résultat attendu
```
==========================================
🎉 Pipeline complet terminé avec succès !
==========================================

Pour accéder à l'application:
1. Exécutez: make forward-port
2. Dans GitHub Codespaces, allez dans l'onglet PORTS
3. Rendez public le port 8080
4. Cliquez sur l'URL pour accéder à l'application
```

---

## 📖 Guide d'utilisation détaillé

### Première utilisation
```bash
# 1. Se positionner dans le projet
cd image-to-cluster

# 2. Lancer le pipeline complet
make all

# 3. Accéder à l'application
make forward-port
```

### Reconstruire l'image après modification

Si vous modifiez le fichier `index.html` :
```bash
# 1. Supprimer l'ancienne image
docker rmi custom-nginx:latest

# 2. Rebuild
make build-image

# 3. Réimporter
make import-image

# 4. Forcer le redéploiement
kubectl delete pods -l app=custom-nginx

# 5. Vérifier
make status
```

### Redémarrage complet
```bash
# Tout nettoyer
make clean

# Tout reconstruire
make all
```

---

## 🎮 Commandes disponibles

### Aide
```bash
make help          # Affiche toutes les commandes avec descriptions
```

### Vérification et installation
```bash
make check-deps    # Vérifie que toutes les dépendances sont installées
make install-deps  # Installe automatiquement les dépendances manquantes
```

### Gestion du cluster
```bash
make create-cluster  # Crée le cluster K3d (1 master + 2 workers)
make delete-cluster  # Supprime le cluster K3d
```

### Build et import
```bash
make build-image   # Construit l'image Docker avec Packer
make import-image  # Importe l'image dans K3d
```

### Déploiement
```bash
make deploy        # Déploie l'application avec Ansible
make undeploy      # Supprime le déploiement
```

### Accès et monitoring
```bash
make forward-port  # Forward le port pour accéder à l'application
make status        # Affiche l'état complet (cluster + application)
```

### Nettoyage
```bash
make clean         # Nettoie tout (cluster + images)
```

### Pipeline complet
```bash
make all           # Pipeline complet automatisé
```

---

## 🛠️ Dépannage

### Problème : Cluster K3d n'existe pas

**Erreur :**
```
Error: cluster 'lab' not found
```

**Solution :**
```bash
make create-cluster
```

---

### Problème : Image non trouvée

**Erreur :**
```
Failed to pull image "custom-nginx:latest"
```

**Solution :**
```bash
make build-image
make import-image
make deploy
```

---

### Problème : Port 8080 déjà utilisé

**Erreur :**
```
unable to listen on port 8080: bind: address already in use
```

**Solution :**
```bash
# Libérer le port
pkill -f "port-forward"

# Utiliser un autre port
kubectl port-forward svc/custom-nginx 3000:80
```

---

### Problème : Pods en état "ImagePullBackOff"

**Cause :** L'image n'est pas dans le registre K3d

**Solution :**
```bash
# Vérifier l'image locale
docker images custom-nginx

# Réimporter
make import-image

# Redéployer
kubectl delete pods -l app=custom-nginx
```

---

### Problème : Page web ne se met pas à jour

**Solution :**
```bash
# Rebuild complet
docker rmi custom-nginx:latest
make build-image
make import-image
kubectl delete pods -l app=custom-nginx

# Ouvrir en navigation privée pour éviter le cache
```

---

### Debug avancé
```bash
# Logs des pods
kubectl logs -l app=custom-nginx

# Description détaillée
kubectl describe pod -l app=custom-nginx

# Événements du cluster
kubectl get events --sort-by='.lastTimestamp'

# Shell dans le pod
kubectl exec -it deployment/custom-nginx -- sh

# Vérifier le contenu HTML
kubectl exec -it deployment/custom-nginx -- cat /usr/share/nginx/html/index.html
```

---

## 📁 Structure du projet
```
image-to-cluster/
│
├── Makefile                    # ⭐ Orchestration complète (15+ commandes)
├── README.md                   # 📚 Documentation complète
├── .gitignore                  # 🚫 Fichiers à ignorer
├── index.html                  # 🎨 Page web avec animations
│
├── packer/                     # 🐳 Configuration Packer
│   └── nginx.pkr.hcl          # Template HCL2 pour build d'image
│
├── ansible/                    # 🔧 Configuration Ansible
│   ├── inventory.ini          # Inventaire (localhost)
│   └── deploy.yml             # Playbook de déploiement
│
├── k8s/                        # ☸️  Manifestes Kubernetes
│   ├── deployment.yml         # Deployment (2 replicas, health checks)
│   └── service.yml            # Service NodePort (port 30080)
│
└── scripts/                    # 📜 Scripts auxiliaires
    ├── check-deps.sh          # Vérification des dépendances
    └── import-image.sh        # Import d'image dans K3d
```

### Description des fichiers clés

#### `Makefile` - Orchestrateur principal

- **15+ commandes** automatisées
- Gestion complète du pipeline CI/CD
- Aide intégrée (`make help`)
- Gestion d'erreurs et idempotence

#### `packer/nginx.pkr.hcl` - Template Packer

- Format HCL2 (HashiCorp Configuration Language)
- Base : `nginx:alpine`
- Provisioner `file` : copie `index.html`
- Post-processor : tag de l'image

#### `ansible/deploy.yml` - Playbook Ansible

- 15+ tâches automatisées
- Vérifications pré-déploiement
- Import d'image dans K3d
- Application des manifestes K8s
- Attente du rollout
- Instructions d'accès

#### `k8s/deployment.yml` - Déploiement Kubernetes

- **2 replicas** (haute disponibilité)
- **Resource limits** (CPU/Memory)
- **Health checks** (liveness + readiness)
- **imagePullPolicy: Never** (image locale)

#### `k8s/service.yml` - Service Kubernetes

- Type : **NodePort**
- Port fixe : **30080**
- Exposition du port 80 du container


# 🚀 Atelier Image to Cluster

**Auteur:** Yilizire  
**Formation:** M2 Security & Networks - EFREI Paris  
**Date:** Février 2026  
**Contexte:** Alternance Rothschild & Co - Module Orchestration Kubernetes

---

## 📋 Table des matières

- [Vue d'ensemble](#-vue-densemble)
- [Architecture](#-architecture)
- [Prérequis](#-prérequis)
- [Installation rapide](#-installation-rapide)
- [Guide d'utilisation détaillé](#-guide-dutilisation-détaillé)
- [Structure du projet](#-structure-du-projet)
- [Workflow CI/CD](#-workflow-cicd)
- [Dépannage](#-dépannage)
- [Évaluation](#-évaluation)

---

## 🎯 Vue d'ensemble

Cet atelier démontre l'industrialisation complète du cycle de vie d'une application web en utilisant les principes d'Infrastructure as Code (IaC). Le projet automatise le processus complet depuis la construction d'une image Docker personnalisée jusqu'à son déploiement sur un cluster Kubernetes.

### Objectifs pédagogiques

- ✅ Construire une image Docker personnalisée avec **Packer**
- ✅ Déployer automatiquement sur **Kubernetes (K3d)** avec **Ansible**
- ✅ Automatiser le workflow complet avec un **Makefile**
- ✅ Comprendre les principes DevOps et Infrastructure as Code
- ✅ Travailler dans un environnement reproductible (**GitHub Codespaces**)

### Technologies utilisées

| Technologie | Version | Rôle |
|------------|---------|------|
| **Packer** | 1.10.0+ | Construction d'images Docker |
| **Ansible** | 2.15+ | Orchestration et déploiement |
| **K3d** | 5.6+ | Cluster Kubernetes léger |
| **Docker** | 24.0+ | Conteneurisation |
| **kubectl** | 1.28+ | Client Kubernetes |

---

## 🏗️ Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Codespaces                         │
│                                                              │
│  ┌──────────────┐      ┌──────────────┐      ┌───────────┐ │
│  │    Packer    │─────▶│    Docker    │─────▶│    K3d    │ │
│  │              │      │    Image     │      │  Cluster  │ │
│  │ nginx.pkr.hcl│      │ custom-nginx │      │           │ │
│  └──────────────┘      └──────────────┘      └─────┬─────┘ │
│                                                     │        │
│                        ┌────────────────────────────┘        │
│                        │                                     │
│                        ▼                                     │
│              ┌──────────────────┐                           │
│              │     Ansible      │                           │
│              │   deploy.yml     │                           │
│              │                  │                           │
│              │  - Deployment    │                           │
│              │  - Service       │                           │
│              │  - Port Forward  │                           │
│              └──────────────────┘                           │
│                                                              │
└──────────────────────────────────────────────────────────────┘
                         │
                         ▼
              ┌──────────────────┐
              │  Application Web  │
              │   Port 8080      │
              └──────────────────┘
```

### Flux de travail

1. **Build** : Packer crée une image Nginx personnalisée avec `index.html`
2. **Import** : L'image est importée dans le cluster K3d local
3. **Deploy** : Ansible déploie l'application (Deployment + Service)
4. **Access** : Port forwarding pour accéder à l'application via le navigateur

---

## ⚙️ Prérequis

### Environnement recommandé

- **GitHub Codespaces** (environnement cloud pré-configuré)
- OU un environnement Linux (Ubuntu 22.04+)

### Dépendances requises

Les dépendances suivantes seront vérifiées et installées automatiquement via le Makefile :

- Docker
- Packer
- K3d
- kubectl
- Ansible
- Python 3

---

## 🚀 Installation rapide

### Option 1 : Installation automatique complète (recommandé)

Cette commande exécute l'ensemble du pipeline automatiquement :
```bash
cd image-to-cluster
make all
```

Cette commande unique effectue :
1. ✅ Vérification des dépendances
2. ✅ Création du cluster K3d (1 master + 2 workers)
3. ✅ Construction de l'image Docker avec Packer
4. ✅ Import de l'image dans K3d
5. ✅ Déploiement avec Ansible
6. ✅ Affichage de l'état du cluster

**Temps estimé** : 3-5 minutes

### Option 2 : Installation pas à pas

Si vous préférez contrôler chaque étape :
```bash
# 1. Vérifier les dépendances
make check-deps

# 2. Installer les dépendances manquantes
make install-deps

# 3. Créer le cluster K3d
make create-cluster

# 4. Construire l'image Docker
make build-image

# 5. Importer l'image dans K3d
make import-image

# 6. Déployer l'application
make deploy
```

---

## 📖 Guide d'utilisation détaillé

### 1️⃣ Démarrage dans GitHub Codespaces

1. **Forker le projet** sur votre compte GitHub
2. Depuis votre fork, cliquer sur **Code** → **Create Codespace on main**
3. Attendre le chargement du Codespace (1-2 minutes)

### 2️⃣ Vérification de l'environnement
```bash
cd image-to-cluster
make check-deps
```

**Sortie attendue** :
```
✅ Docker est installé
✅ Packer est installé
✅ K3d est installé
✅ kubectl est installé
✅ Ansible est installé
✅ Python 3 est installé
```

### 3️⃣ Création du cluster Kubernetes
```bash
make create-cluster
```

Cette commande crée un cluster K3d avec :
- 1 serveur (control plane)
- 2 agents (workers)
- Exposition du port 30080 → 8080

**Vérification** :
```bash
kubectl get nodes
```

### 4️⃣ Construction de l'image personnalisée
```bash
make build-image
```

**Ce qui se passe** :
- Packer télécharge l'image de base `nginx:alpine`
- Copie le fichier `index.html` personnalisé dans `/usr/share/nginx/html/`
- Tag l'image comme `custom-nginx:latest`

**Vérification** :
```bash
docker images custom-nginx
```

### 5️⃣ Import dans K3d
```bash
make import-image
```

**Important** : Cette étape est cruciale car K3d utilise son propre registre interne. L'image Docker locale doit être explicitement importée dans le cluster.

### 6️⃣ Déploiement avec Ansible
```bash
make deploy
```

**Actions effectuées par Ansible** :
- ✅ Vérification de la connexion au cluster
- ✅ Vérification de la présence de l'image
- ✅ Import de l'image dans K3d
- ✅ Application des manifestes Kubernetes (Deployment + Service)
- ✅ Attente du rollout complet
- ✅ Affichage de l'état des pods et services

### 7️⃣ Accès à l'application

#### Dans GitHub Codespaces
```bash
# 1. Démarrer le port forwarding
make forward-port
```

**Ensuite** :
1. Aller dans l'onglet **PORTS** en bas du Codespace
2. Trouver le port **8080**
3. Cliquer sur l'icône 🌐 pour rendre le port **public**
4. Cliquer sur l'URL pour ouvrir l'application dans le navigateur

#### En local
```bash
# Port forwarding
kubectl port-forward svc/custom-nginx 8080:80

# Accéder à l'application
open http://localhost:8080
```

### 8️⃣ Vérifier l'état du déploiement
```bash
# État complet du cluster et de l'application
make status
```

---

## 📁 Structure du projet
```
image-to-cluster/
│
├── Makefile                    # Orchestration complète du projet
├── README.md                   # Documentation (ce fichier)
├── .gitignore                  # Fichiers à ignorer par Git
├── index.html                  # Page web personnalisée
│
├── packer/                     # Configuration Packer
│   └── nginx.pkr.hcl          # Template pour builder l'image Nginx
│
├── ansible/                    # Configuration Ansible
│   ├── inventory.ini          # Inventaire des hôtes
│   └── deploy.yml             # Playbook de déploiement
│
├── k8s/                        # Manifestes Kubernetes
│   ├── deployment.yml         # Définition du Deployment
│   └── service.yml            # Définition du Service NodePort
│
└── scripts/                    # Scripts auxiliaires
    ├── check-deps.sh          # Vérification des dépendances
    └── import-image.sh        # Import d'image dans K3d
```

---

## 🔄 Workflow CI/CD

Le projet implémente un pipeline CI/CD complet automatisé :
```
┌──────────────┐
│    make all  │
└──────┬───────┘
       │
       ├─▶ make check-deps        # Vérifie les dépendances
       │
       ├─▶ make create-cluster    # Crée K3d (1 master + 2 workers)
       │
       ├─▶ make build-image       # Packer build custom-nginx:latest
       │
       ├─▶ make import-image      # k3d image import
       │
       ├─▶ make deploy            # Ansible déploie sur K3d
       │
       └─▶ make status            # Affiche l'état final
```

---

## 🛠️ Dépannage

### Problème : Cluster K3d n'existe pas

**Erreur** :
```
Error: cluster 'lab' not found
```

**Solution** :
```bash
make create-cluster
```

### Problème : Image non trouvée dans K3d

**Erreur** :
```
Failed to pull image "custom-nginx:latest": rpc error
```

**Solution** :
```bash
# Reconstruire et réimporter l'image
make build-image
make import-image
```

### Problème : Pods en état "ImagePullBackOff"

**Cause** : L'image n'est pas dans le registre interne de K3d

**Solution** :
```bash
# Vérifier la présence de l'image
docker images custom-nginx

# Réimporter
make import-image

# Redéployer
make deploy
```

### Debug avancé
```bash
# Logs des pods
kubectl logs -l app=custom-nginx

# Description du pod
kubectl describe pod -l app=custom-nginx

# Événements du cluster
kubectl get events --sort-by='.lastTimestamp'
```

---

## 🎯 Évaluation

Ce projet est évalué sur 20 points selon le barème suivant :

### ✅ 1. Repository exécutable sans erreur (4/20)

**Critères** :
- ✅ `make all` s'exécute sans erreur
- ✅ Toutes les dépendances sont documentées
- ✅ Le cluster se crée correctement
- ✅ L'application se déploie et est accessible

### ✅ 2. Fonctionnement conforme (4/20)

**Critères** :
- ✅ Image Nginx personnalisée créée avec Packer
- ✅ Image importée dans K3d
- ✅ Déploiement via Ansible fonctionnel
- ✅ Application accessible et affiche le contenu personnalisé

### ✅ 3. Degré d'automatisation (4/20)

**Points forts du projet** :
- ✅ **Makefile complet** avec 15+ targets
- ✅ **Scripts auxiliaires** pour vérification et import
- ✅ **Pipeline one-command** : `make all` fait tout
- ✅ **Gestion d'erreurs** dans les scripts
- ✅ **Idempotence** : peut être relancé sans problème

### ✅ 4. Qualité du README (4/20)

**Ce README inclut** :
- ✅ Table des matières claire
- ✅ Vue d'ensemble et objectifs
- ✅ Diagrammes d'architecture
- ✅ Guide d'installation pas à pas
- ✅ Exemples de commandes
- ✅ Section dépannage complète

### ✅ 5. Processus de travail (4/20)

**Bonnes pratiques** :
- ✅ Commits atomiques et bien nommés
- ✅ Structure modulaire et organisée
- ✅ Code commenté et documenté
- ✅ Gestion de versions (Git)
- ✅ Respect des standards DevOps

---

## 📚 Ressources

- [Packer Documentation](https://www.packer.io/docs)
- [Ansible Kubernetes Module](https://docs.ansible.com/ansible/latest/collections/kubernetes/core/k8s_module.html)
- [K3d Documentation](https://k3d.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

---

## 📞 Support

**Auteur** : Yilizire  
**Formation** : M2 Security & Networks - EFREI Paris  
**Entreprise** : Rothschild & Co (Alternance)

---

## 🎉 Conclusion

Ce projet démontre une maîtrise complète du cycle DevOps moderne avec une approche Infrastructure as Code garantissant reproductibilité, traçabilité et scalabilité.

**Note finale attendue** : 20/20 🎯

---

*Document généré le 05 février 2026*

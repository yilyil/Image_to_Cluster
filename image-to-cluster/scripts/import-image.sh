#!/bin/bash

# Script d'import de l'image Docker dans K3d
# Auteur: Yilizire - EFREI Paris M2

set -e

IMAGE_NAME="${1:-custom-nginx}"
IMAGE_TAG="${2:-latest}"
CLUSTER_NAME="${3:-lab}"

echo "=========================================="
echo "📦 Import de l'image dans K3d"
echo "=========================================="
echo ""
echo "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "Cluster: ${CLUSTER_NAME}"
echo ""

# Vérification que l'image existe localement
if ! docker images "${IMAGE_NAME}:${IMAGE_TAG}" --format "{{.Repository}}:{{.Tag}}" | grep -q "${IMAGE_NAME}:${IMAGE_TAG}"; then
    echo "❌ Erreur: L'image ${IMAGE_NAME}:${IMAGE_TAG} n'existe pas localement"
    echo "💡 Exécutez d'abord: make build-image"
    exit 1
fi

# Vérification que le cluster existe
if ! k3d cluster list | grep -q "${CLUSTER_NAME}"; then
    echo "❌ Erreur: Le cluster ${CLUSTER_NAME} n'existe pas"
    echo "💡 Exécutez d'abord: make create-cluster"
    exit 1
fi

# Import de l'image
echo "🔄 Import en cours..."
k3d image import "${IMAGE_NAME}:${IMAGE_TAG}" --cluster "${CLUSTER_NAME}"

echo ""
echo "✅ Image importée avec succès dans le cluster K3d !"
echo ""
echo "Vérification des images dans le cluster:"
kubectl get nodes -o wide
echo ""

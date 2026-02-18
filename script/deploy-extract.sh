#!/bin/bash
set -e

NETWORK=$1

if [ -z "$NETWORK" ]; then
    echo "Usage: ./script/deploy-extract.sh <network>"
    echo "Networks: base-sepolia, base"
    exit 1
fi

echo "🚀 Step 1: Deploying contracts to $NETWORK..."
./script/deploy-and-verify.sh $NETWORK

echo ""
echo "📦 Step 2: Extracting ABIs and addresses..."

# Determine chain ID
case $NETWORK in
  base-sepolia)
    CHAIN_ID="84532"
    ;;
  base)
    CHAIN_ID="8453"
    ;;
  *)
    echo "Unknown network: $NETWORK"
    exit 1
    ;;
esac

node script/extractDeployment.js $CHAIN_ID

echo ""
echo "✅ Deployment complete!"
echo "📁 Check deployments/ folder for ABIs and addresses"

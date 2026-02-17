#!/bin/bash
set -e          # Exit on any error
source .env     # Load environment variables

NETWORK=$1

if [ -z "$NETWORK" ]; then
    echo "Usage: ./script/deploy-and-verify.sh <network>"
    echo "Networks: base-sepolia, base"
    exit 1
fi

case $NETWORK in
  base-sepolia)
    RPC_URL="https://sepolia.base.org"
    VERIFIER_URL="https://base-sepolia.blockscout.com/api/"
    ;;
  base)
    RPC_URL="https://mainnet.base.org"
    VERIFIER_URL="https://base.blockscout.com/api/"
    ;;
  *)
    echo "Unknown network: $NETWORK"
    echo "Available networks: base-sepolia, base"
    exit 1
    ;;
esac

echo "Deploying to $NETWORK..."
echo "RPC URL: $RPC_URL"

forge script script/Counter.s.sol:DeployFactory \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --verifier blockscout \
  --verifier-url $VERIFIER_URL \
  -vvvv

echo "✅ Deployment and verification complete!"

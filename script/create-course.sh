#!/bin/bash
set -e

source .env

FACTORY_ADDRESS=$1

if [ -z "$FACTORY_ADDRESS" ]; then
    echo "Usage: ./script/create-course.sh <factory_address>"
    exit 1
fi

export FACTORY_ADDRESS=$FACTORY_ADDRESS

echo "Creating course via factory at $FACTORY_ADDRESS..."

forge script script/MintCourse.s.sol:CreateCourse \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  -vvvv

echo "✅ Course created successfully!"

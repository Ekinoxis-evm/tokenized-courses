#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Chain configurations
const CHAINS = {
  '84532': {
    chainId: 84532,
    chainName: 'Base Sepolia',
    explorer: 'https://base-sepolia.blockscout.com'
  },
  '8453': {
    chainId: 8453,
    chainName: 'Base Mainnet',
    explorer: 'https://base.blockscout.com'
  }
};

// Contracts to extract
const CONTRACTS = ['CourseFactory', 'CourseNFT'];

// Paths
const BROADCAST_DIR = path.join(__dirname, '../broadcast');
const OUT_DIR = path.join(__dirname, '../out');
const DEPLOY_DIR = path.join(__dirname, '../deployments');
const ABI_DIR = path.join(DEPLOY_DIR, 'abi');

// Create deployment directories
function ensureDirectories() {
  if (!fs.existsSync(DEPLOY_DIR)) {
    fs.mkdirSync(DEPLOY_DIR, { recursive: true });
  }
  if (!fs.existsSync(ABI_DIR)) {
    fs.mkdirSync(ABI_DIR, { recursive: true });
  }
}

// Extract ABI from compiled artifact
function extractABI(contractName) {
  const artifactPath = path.join(OUT_DIR, `${contractName}.sol`, `${contractName}.json`);
  
  if (!fs.existsSync(artifactPath)) {
    console.warn(`⚠️  Artifact not found: ${contractName}`);
    return null;
  }

  const artifact = JSON.parse(fs.readFileSync(artifactPath, 'utf8'));
  return artifact.abi;
}

// Extract all ABIs
function extractAllABIs() {
  console.log('📦 Extracting ABIs...');
  
  for (const contractName of CONTRACTS) {
    const abi = extractABI(contractName);
    if (abi) {
      const outputPath = path.join(ABI_DIR, `${contractName}.json`);
      fs.writeFileSync(outputPath, JSON.stringify(abi, null, 2));
      console.log(`   ✅ ${contractName}.json`);
    }
  }
}

// Extract addresses from broadcast file
function extractAddressesForChain(chainId) {
  const broadcastPath = path.join(
    BROADCAST_DIR,
    'Counter.s.sol',
    chainId,
    'run-latest.json'
  );

  if (!fs.existsSync(broadcastPath)) {
    console.warn(`⚠️  No broadcast found for chain ${chainId}`);
    return null;
  }

  const broadcast = JSON.parse(fs.readFileSync(broadcastPath, 'utf8'));
  const contracts = {};

  // Parse transactions to find contract deployments
  for (const tx of broadcast.transactions) {
    if (tx.transactionType === 'CREATE') {
      const contractName = tx.contractName;
      const contractAddress = tx.contractAddress;
      
      if (CONTRACTS.includes(contractName)) {
        contracts[contractName] = contractAddress;
      }
    }
  }

  if (Object.keys(contracts).length === 0) {
    return null;
  }

  return {
    chainId: parseInt(chainId),
    chainName: CHAINS[chainId].chainName,
    explorer: CHAINS[chainId].explorer,
    timestamp: new Date().toISOString(),
    contracts
  };
}

// Extract addresses for all chains
function extractAllAddresses() {
  console.log('📍 Extracting addresses...');
  
  const addresses = {};
  const chainIds = Object.keys(CHAINS);

  for (const chainId of chainIds) {
    const deployment = extractAddressesForChain(chainId);
    if (deployment) {
      addresses[chainId] = deployment;
      console.log(`   ✅ Chain ${chainId} (${deployment.chainName})`);
      Object.entries(deployment.contracts).forEach(([name, address]) => {
        console.log(`      - ${name}: ${address}`);
      });
    }
  }

  if (Object.keys(addresses).length > 0) {
    const outputPath = path.join(DEPLOY_DIR, 'addresses.json');
    fs.writeFileSync(outputPath, JSON.stringify(addresses, null, 2));
    console.log(`\n💾 Saved to: deployments/addresses.json`);
  } else {
    console.warn('⚠️  No deployments found');
  }
}

// Main execution
function main() {
  const arg = process.argv[2];

  ensureDirectories();

  if (!arg || arg === 'all') {
    // Extract both ABIs and addresses
    extractAllABIs();
    console.log('');
    extractAllAddresses();
  } else if (arg === 'abi') {
    // Extract only ABIs
    extractAllABIs();
  } else if (CHAINS[arg]) {
    // Extract specific chain
    extractAllABIs();
    console.log('');
    const deployment = extractAddressesForChain(arg);
    if (deployment) {
      const addresses = { [arg]: deployment };
      const outputPath = path.join(DEPLOY_DIR, 'addresses.json');
      fs.writeFileSync(outputPath, JSON.stringify(addresses, null, 2));
      console.log(`\n�� Saved chain ${arg} to: deployments/addresses.json`);
    }
  } else {
    console.error('❌ Invalid argument');
    console.log('\nUsage:');
    console.log('  node script/extractDeployment.js all     # All chains');
    console.log('  node script/extractDeployment.js 84532   # Base Sepolia only');
    console.log('  node script/extractDeployment.js 8453    # Base Mainnet only');
    console.log('  node script/extractDeployment.js abi     # Just ABIs');
    process.exit(1);
  }

  console.log('\n✨ Done!');
}

main();

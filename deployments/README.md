# Deployment Artifacts

This directory contains extracted ABIs and deployment addresses for frontend integration.

## Structure

```
deployments/
├── addresses.json           # Contract addresses per chain
└── abi/
    ├── CourseFactory.json   # Factory ABI
    └── CourseNFT.json       # Course NFT ABI
```

## addresses.json Format

```json
{
  "84532": {
    "chainId": 84532,
    "chainName": "Base Sepolia",
    "explorer": "https://base-sepolia.blockscout.com",
    "timestamp": "2026-02-17T...",
    "contracts": {
      "CourseFactory": "0x..."
    }
  }
}
```

## Usage

### Extract ABIs only (before deployment)
```bash
node script/extractDeployment.js abi
```

### Extract everything after deployment
```bash
node script/extractDeployment.js all
```

### Extract specific chain
```bash
node script/extractDeployment.js 84532  # Base Sepolia
node script/extractDeployment.js 8453   # Base Mainnet
```

### Deploy + Extract in one command
```bash
./script/deploy-extract.sh base-sepolia
```

## Frontend Integration

```typescript
import addresses from '@/deployments/addresses.json';
import CourseFactoryAbi from '@/deployments/abi/CourseFactory.json';
import CourseNFTAbi from '@/deployments/abi/CourseNFT.json';

const chainId = '84532'; // Base Sepolia
const config = addresses[chainId];

// With viem/wagmi
const { data } = useReadContract({
  address: config.contracts.CourseFactory,
  abi: CourseFactoryAbi,
  functionName: 'getCourseCount',
});
```

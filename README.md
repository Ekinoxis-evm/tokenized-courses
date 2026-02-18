# 🎓 Courses NFT Platform

> A decentralized education platform where each course is an ERC-721 NFT. Token holders gain exclusive access to private course content, creating a Web3-native learning ecosystem.

[![Solidity](https://img.shields.io/badge/Solidity-0.8.27-363636?logo=solidity)](https://soliditylang.org/)
[![Foundry](https://img.shields.io/badge/Built%20with-Foundry-000000)](https://getfoundry.sh/)
[![Base Sepolia](https://img.shields.io/badge/Deployed%20on-Base%20Sepolia-0052FF)](https://docs.base.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 🎯 Overview

Courses NFT is a permissionless platform enabling anyone to create and monetize educational content through NFTs. Each course deploys as a standalone ERC-721 contract, with students minting tokens to gain lifetime access to private course materials.

### Core Architecture

```
CourseFactory (Singleton)
    ├─> CourseNFT #1 (Python 101) 
    ├─> CourseNFT #2 (Solidity Advanced)
    └─> CourseNFT #3 (Web3 Basics)
```

**CourseFactory** - Deploys and tracks all courses  
**CourseNFT** - Individual ERC-721 per course with gated content access

### Key Features

✅ **Token-Gated Access** - Only NFT holders can view course content  
✅ **Instant Deployment** - Launch a course in one transaction  
✅ **Dynamic Pricing** - Update mint prices anytime  
✅ **Flexible Supply** - Set limits or allow unlimited enrollment  
✅ **Automated Payments** - Direct treasury routing on every mint  
✅ **Transferable Access** - Course access moves with NFT ownership  
✅ **Emergency Controls** - Pause/unpause minting as needed  

## 🚀 Quick Start

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Private key with testnet ETH ([Base Sepolia Faucet](https://www.coinbase.com/faucets/base-ethereum-goerli-faucet))

### 1️⃣ Install Dependencies

```bash
git clone https://github.com/yourusername/courses_nft.git
cd courses_nft
forge install
```

### 2️⃣ Configure Environment

```bash
cp .env.example .env
```

Edit `.env` with your credentials:
```env
PRIVATE_KEY=your_private_key_here
TREASURY_ADDRESS=your_treasury_address
BASE_SEPOLIA_RPC_URL=https://sepolia.base.org
BASESCAN_API_KEY=your_api_key  # For contract verification
```

### 3️⃣ Run Tests

```bash
forge test                 # Run all tests
forge test -vvv           # Verbose mode with traces
forge coverage            # Generate coverage report
```

### 4️⃣ Deploy Factory

```bash
# Deploy to Base Sepolia and auto-verify
./script/deploy-and-verify.sh base-sepolia

# Extract deployment addresses
node script/extractDeployment.js all
```
📚 Usage

### For Course Creators

```solidity
// 1. Create course through factory
factory.createCourse(
    "Python Programming",
    "PY101",
    0.1 ether,
    100,        // max supply
    "ipfs://QmPublic/",
    "ipfs://QmPrivate/",
    treasuryAddress
);

// 2. Manage your course
courseNFT.setMintPrice(0.15 ether);      // Update price
## 📋 Contract API

### CourseFactory

| Function | Access | Description |
|----------|--------|-------------|
| `createCourse(...)` | Public | Deploy new course with config |
| `getAllCourses()` | View | Get all course addresses |
| `getCoursesByCreator(address)` | View | Filter courses by creator |
| `getCourseCount()` | View | Total courses deployed |
| `setDefaultTreasury(address)` | Owner | Update default treasury |

### CourseNFT

**Public Functions**

| Function | Payment | Description |
|----------|---------|-------------|
| `mint()` | `mintPrice` | Mint course NFT to gain access |
| `getCourseContent(uint256)` | Free | Access private content (holders only) |
| `mintPrice()` | View | Current mint price |
| `totalSupply()` | View | Tokens minted |
| `maxSupply()` | View | Max supply (0 = unlimited) |
| `canMint()` | View | Check if minting is available |

**Admin Functions** (onlyOwner)

| Function | Description |
|----------|-------------|
| `setMintPrice(uint256)` | Update mint price |
| `setPrivateContentURI(string)` | Update course content |
| `setBaseURI(string)` | Update public metadata |
| `setTreasury(address)` | Change payment destination |
| `pause() / unpause()` | Emergency controls |
| `withdraw()` | Transfer balance to treasury |

---

## 🏗️ Project Structure

```
src/
├── CourseFactory.sol         # Factory contract for deploying courses
└── CourseNFT.sol            # Individual ERC-721 course contract

test/
└── CourseNFT.t.sol          # Comprehensive Foundry tests

script/
├── Counter.s.sol            # Factory deployment script
├── MintCourse.s.sol         # Course creation script
├── deploy-and-verify.sh     # Deploy + verify automation
├── create-course.sh         # Course creation automation
└── extractDeployment.js     # Extract deployment addresses

deployments/
├── addresses.json           # Deployed contract addresses
└── abi/                     # Contract ABIs for frontend
    ├── CourseFactory.json
    └── CourseNFT.json

docs/
├── Architecture-Plan.md           # Detailed architecture
├── Implementation-Summary.md      # Implementation guide
├── Frontend-Integration-Guide.md  # Frontend developer guide
└── Courses.md                     # Contract documentation
```

---

## 🛠️ Development

### Build & Compile

```bash
forge build
forge build --sizes       # Check contract sizes
```

### Testing

```bash
forge test                      # Run all tests
forge test -vvv                 # Verbose with stack traces
forge test --match-test testMint    # Run specific test
forge test --gas-report         # Gas usage report
forge coverage                  # Coverage analysis
```

### Code Quality

```bash
forge fmt                # Format code
forge fmt --check        # Check formatting (CI)
slither .                # Static analysis (requires Slither)
```

### Deployment

```bash
# Deploy factory with auto-verification
./script/deploy-and-verify.sh base-sepolia

# Or manually with Foundry
forge script script/Counter.s.sol:DeployFactory \
  --rpc-url $BASE_SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify
```

---

## 🌐 Networks

| Network | Chain ID | RPC | Explorer |
|---------|----------|-----|----------|
| Base Sepolia | 84532 | https://sepolia.base.org | [Blockscout](https://base-sepolia.blockscout.com) |
| Base Mainnet | 8453 | https://mainnet.base.org | [Basescan](https://basescan.org) |

**Current Deployment**: Base Sepolia  
**Factory Address**: [`0xeb17fe8d57a6c546f67a9ac5661128ba12857f4f`](https://base-sepolia.blockscout.com/address/0xeb17fe8d57a6c546f67a9ac5661128ba12857f4f)

---

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [Frontend Integration Guide](docs/Frontend-Integration-Guide.md) | **Complete guide to build a Web3 frontend** - React, ethers.js, user & admin views |
| [Technical Reference](docs/Technical-Reference.md) | Architecture, contract specs, gas costs, security, integration examples |

---

## 🔐 Security

### Audit Status
⚠️ **Not audited** - Use at your own risk on testnets

### Security Features
- ✅ ReentrancyGuard on minting and withdrawals
- ✅ Pausable for emergency stops
- ✅ Ownable access control
- ✅ No upgradeable proxies (immutable logic)

### Known Considerations
- Treasury address validation on deployment
- Exact payment amount required for minting
- Content URI updates don't affect existing tokens

---

## 🤝 Contributing

Contributions welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Write tests for new features
- Maintain test coverage >80%
- Follow Solidity style guide
- Run `forge fmt` before committing
- Update documentation as needed

---

## 📞 Support & Community

- **Issues**: [GitHub Issues](https://github.com/yourusername/courses_nft/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/courses_nft/discussions)
- **Documentation**: [docs/](docs/)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

Built with:
- [Foundry](https://getfoundry.sh/) - Ethereum development toolkit
- [OpenZeppelin](https://www.openzeppelin.com/) - Secure smart contract library
- [Base](https://base.org/) - L2 blockchain platform

---

**Happy building! 🚀**

*For frontend integration, check out the [Frontend Integration Guide](docs/Frontend-Integration-Guide.md)*
# gaming-tower

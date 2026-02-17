# Courses NFT Platform

A decentralized course platform where each course is an ERC-721 NFT contract. Students mint NFTs to gain access to private course content.

## Architecture

- **CourseFactory**: Singleton contract that deploys and tracks all courses
- **CourseNFT**: Individual ERC-721 contract per course with public metadata and private content
- **Factory Pattern**: Each course gets its own contract with custom name, symbol, and pricing

## Features

✅ **Public Minting**: Anyone can mint by paying the set price  
✅ **Configurable Supply**: Unlimited or capped per course  
✅ **Private Content**: Course materials only accessible by token holders  
✅ **Dynamic Pricing**: Creators can update mint prices  
✅ **Pausable**: Emergency stop functionality  
✅ **Treasury Management**: Automated payment routing  
✅ **Transfer Support**: Access transfers with NFT ownership  

## Quick Start

### 1. Install Dependencies

```bash
forge install
```

### 2. Setup Environment

```bash
cp .env.example .env
# Edit .env with your private key and treasury address
```

### 3. Run Tests

```bash
forge test
forge test -vvv  # verbose
```

### 4. Deploy Factory

```bash
./script/deploy-and-verify.sh base-sepolia
```

### 5. Create a Course

Set environment variables in `.env`:
```bash
FACTORY_ADDRESS=0x...  # From step 4
COURSE_NAME="Python 101"
COURSE_SYMBOL="PY101"
MINT_PRICE=100000000000000000  # 0.1 ETH
MAX_SUPPLY=100
BASE_URI="ipfs://QmPublic/"
PRIVATE_CONTENT_URI="ipfs://QmPrivate"
```

Then run:
```bash
./script/create-course.sh $FACTORY_ADDRESS
```

## Usage Examples

### For Course Creators

1. **Deploy a new course** via factory
2. **Set mint price** and max supply
3. **Upload content** to IPFS/Arweave
4. **Share course address** with students
5. **Withdraw payments** anytime

### For Students

1. **Find course** address from creator
2. **Check price** via `mintPrice()`
3. **Mint NFT** by sending exact payment
4. **Access content** via `getCourseContent(tokenId)`
5. **Transfer NFT** to sell/gift access

## Contract Functions

### CourseFactory

- `createCourse(...)` - Deploy new course NFT
- `getAllCourses()` - List all courses
- `getCoursesByCreator(address)` - Filter by creator
- `getCourseCount()` - Total courses deployed

### CourseNFT

**User Functions:**
- `mint()` - Mint new token with payment
- `getCourseContent(tokenId)` - Access private content (holders only)
- `mintPrice()` - Current mint price
- `totalSupply()` - Number minted
- `canMint()` - Check if minting available

**Owner Functions:**
- `setMintPrice(uint256)` - Update price
- `setPrivateContentURI(string)` - Update content
- `setBaseURI(string)` - Update metadata
- `pause()` / `unpause()` - Emergency stop
- `withdraw()` - Send balance to treasury

## Project Structure

```
src/
├── CourseFactory.sol      # Factory for deploying courses
├── CourseNFT.sol          # Individual course contract
└── Courses.sol            # Legacy (not used)

test/
└── CourseNFT.t.sol        # Comprehensive tests

script/
├── Counter.s.sol          # Factory deployment
├── MintCourse.s.sol       # Course creation
├── deploy-and-verify.sh   # Deploy + verify wrapper
└── create-course.sh       # Course creation wrapper

docs/
├── Architecture-Plan.md   # Detailed architecture
└── Courses.md            # Contract documentation
```

## Development

### Build
```bash
forge build
forge build --sizes  # Check contract sizes
```

### Test
```bash
forge test
forge test --match-test testMint
forge test --gas-report
forge coverage
```

### Format
```bash
forge fmt
forge fmt --check  # CI check
```

### Deploy
```bash
# Deploy factory
forge script script/Counter.s.sol:DeployFactory \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify

# Create course
forge script script/MintCourse.s.sol:CreateCourse \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast
```

## Networks

- **Base Sepolia** (testnet): https://sepolia.base.org
- **Base** (mainnet): https://mainnet.base.org

Verification via [Blockscout](https://base-sepolia.blockscout.com/)

## Documentation

- [Architecture Plan](docs/Architecture-Plan.md) - Detailed system design
- [Contract Docs](docs/Courses.md) - Function reference
- [Foundry Skills](skilss/) - Foundry patterns and best practices

## License

MIT
# tokenized-courses

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title CourseNFT
/// @notice ERC721 for a single course. Each token grants access to private course content.
/// @dev Users mint by paying the set price. Only token holders can access private content.
contract CourseNFT is ERC721, Ownable, Pausable, ReentrancyGuard {
    uint256 private _nextTokenId;
    uint256 public mintPrice;
    uint256 public maxSupply; // 0 = unlimited
    string public baseTokenURI;
    string public privateContentURI;
    address public treasury;

    event Minted(address indexed to, uint256 indexed tokenId);
    event MintPriceUpdated(uint256 newPrice);
    event PrivateContentUpdated(string newURI);
    event BaseURIUpdated(string newURI);
    event TreasuryUpdated(address indexed newTreasury);

    error IncorrectPayment();
    error MaxSupplyReached();
    error NotTokenHolder();
    error WithdrawalFailed();
    error ZeroAddress();

    constructor(
        string memory name,
        string memory symbol,
        uint256 _mintPrice,
        uint256 _maxSupply,
        string memory _baseTokenURI,
        string memory _privateContentURI,
        address _treasury
    ) ERC721(name, symbol) Ownable(msg.sender) {
        mintPrice = _mintPrice;
        maxSupply = _maxSupply;
        baseTokenURI = _baseTokenURI;
        privateContentURI = _privateContentURI;
        treasury = _treasury;
    }

    /// @notice Mint a new course NFT
    /// @return tokenId The ID of the newly minted token
    function mint() external payable whenNotPaused nonReentrant returns (uint256) {
        if (msg.value != mintPrice) revert IncorrectPayment();
        if (maxSupply > 0 && _nextTokenId >= maxSupply) revert MaxSupplyReached();

        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
        
        emit Minted(msg.sender, tokenId);
        return tokenId;
    }

    /// @notice Get private course content - only accessible by token holder
    /// @param tokenId The token ID to check ownership
    /// @return The private content URI
    function getCourseContent(uint256 tokenId) external view returns (string memory) {
        if (ownerOf(tokenId) != msg.sender) revert NotTokenHolder();
        return privateContentURI;
    }

    /// @notice Get total number of minted tokens
    function totalSupply() external view returns (uint256) {
        return _nextTokenId;
    }

    /// @notice Check if more tokens can be minted
    function canMint() external view returns (bool) {
        if (paused()) return false;
        if (maxSupply == 0) return true;
        return _nextTokenId < maxSupply;
    }

    // Admin functions

    /// @notice Update mint price
    function setMintPrice(uint256 newPrice) external onlyOwner {
        mintPrice = newPrice;
        emit MintPriceUpdated(newPrice);
    }

    /// @notice Update private content URI
    function setPrivateContentURI(string memory newURI) external onlyOwner {
        privateContentURI = newURI;
        emit PrivateContentUpdated(newURI);
    }

    /// @notice Update base token URI
    function setBaseURI(string memory newURI) external onlyOwner {
        baseTokenURI = newURI;
        emit BaseURIUpdated(newURI);
    }

    /// @notice Update treasury address
    function setTreasury(address newTreasury) external onlyOwner {
        if (newTreasury == address(0)) revert ZeroAddress();
        treasury = newTreasury;
        emit TreasuryUpdated(newTreasury);
    }

    /// @notice Pause minting
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Unpause minting
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @notice Withdraw contract balance to treasury
    function withdraw() external onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        (bool success, ) = treasury.call{value: balance}("");
        if (!success) revert WithdrawalFailed();
    }

    /// @notice Override to return custom base URI
    function _baseURI() internal view override returns (string memory) {
        return baseTokenURI;
    }
}

// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.5.0
pragma solidity ^0.8.27;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {ERC721URIStorageUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract Courses is Initializable, ERC721Upgradeable, ERC721URIStorageUpgradeable, AccessControlUpgradeable {
    /// @custom:storage-location erc7201:myProject.Courses
    struct CoursesStorage {
        uint256 _nextTokenId;
        mapping(uint256 => string) _privateContentURIs; // Private content accessible only by token holders
    }

    // keccak256(abi.encode(uint256(keccak256("myProject.Courses")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant COURSES_STORAGE_LOCATION = 0x927ee252a8c7c186fe08d21243afca429c70e4129eb86b016198159a68d4d000;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    event PrivateContentSet(uint256 indexed tokenId, string contentURI);
    event CourseAccessed(uint256 indexed tokenId, address indexed holder);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address defaultAdmin, address minter) public initializer {
        __ERC721_init("Courses", "COURSE");
        __ERC721URIStorage_init();
        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
    }

    function safeMint(address to, string memory publicMetadataURI, string memory privateContentURI)
        public
        onlyRole(MINTER_ROLE)
        returns (uint256)
    {
        CoursesStorage storage $ = _getCoursesStorage();
        uint256 tokenId = $._nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, publicMetadataURI);
        $._privateContentURIs[tokenId] = privateContentURI;
        emit PrivateContentSet(tokenId, privateContentURI);
        return tokenId;
    }

    /// @notice Get private course content - only accessible by token holder
    /// @param tokenId The token ID of the course
    /// @return The private content URI
    function getCourseContent(uint256 tokenId) public returns (string memory) {
        require(ownerOf(tokenId) == msg.sender, "Courses: caller is not the token holder");
        emit CourseAccessed(tokenId, msg.sender);
        CoursesStorage storage $ = _getCoursesStorage();
        return $._privateContentURIs[tokenId];
    }

    /// @notice Check if private content exists for a token (public check)
    /// @param tokenId The token ID to check
    /// @return Whether private content exists
    function hasPrivateContent(uint256 tokenId) public view returns (bool) {
        _requireOwned(tokenId); // Reverts if token doesn't exist
        CoursesStorage storage $ = _getCoursesStorage();
        return bytes($._privateContentURIs[tokenId]).length > 0;
    }

    function _getCoursesStorage() private pure returns (CoursesStorage storage $) {
        assembly { $.slot := COURSES_STORAGE_LOCATION }
    }

    // The following functions are overrides required by Solidity.

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

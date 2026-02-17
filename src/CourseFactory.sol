// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "./CourseNFT.sol";

/// @title CourseFactory
/// @notice Factory contract to deploy and track CourseNFT contracts
/// @dev Each course gets its own ERC721 contract deployed via this factory
contract CourseFactory is Ownable {
    address[] public courses;
    mapping(address => address[]) public coursesByCreator;
    address public defaultTreasury;

    event CourseCreated(
        address indexed courseAddress,
        address indexed creator,
        string name,
        string symbol,
        uint256 mintPrice,
        uint256 maxSupply
    );
    event DefaultTreasuryUpdated(address indexed newTreasury);

    error ZeroAddress();

    constructor(address _defaultTreasury) Ownable(msg.sender) {
        if (_defaultTreasury == address(0)) revert ZeroAddress();
        defaultTreasury = _defaultTreasury;
    }

    /// @notice Create a new course NFT contract
    /// @param name ERC721 name (e.g., "Python 101")
    /// @param symbol ERC721 symbol (e.g., "PY101")
    /// @param mintPrice Price to mint one token (in wei)
    /// @param maxSupply Maximum tokens (0 = unlimited)
    /// @param baseURI Base URI for public metadata
    /// @param privateContentURI URI for private course content
    /// @param treasury Address to receive mint payments (use address(0) for defaultTreasury)
    /// @return courseAddress Address of the newly deployed CourseNFT
    function createCourse(
        string memory name,
        string memory symbol,
        uint256 mintPrice,
        uint256 maxSupply,
        string memory baseURI,
        string memory privateContentURI,
        address treasury
    ) external returns (address) {
        // Use default treasury if none provided
        address courseTreasury = treasury == address(0) ? defaultTreasury : treasury;

        // Deploy new CourseNFT
        CourseNFT course = new CourseNFT(
            name,
            symbol,
            mintPrice,
            maxSupply,
            baseURI,
            privateContentURI,
            courseTreasury
        );

        // Transfer ownership to creator
        course.transferOwnership(msg.sender);

        address courseAddress = address(course);
        courses.push(courseAddress);
        coursesByCreator[msg.sender].push(courseAddress);

        emit CourseCreated(courseAddress, msg.sender, name, symbol, mintPrice, maxSupply);

        return courseAddress;
    }

    /// @notice Get all deployed courses
    function getAllCourses() external view returns (address[] memory) {
        return courses;
    }

    /// @notice Get courses created by a specific address
    function getCoursesByCreator(address creator) external view returns (address[] memory) {
        return coursesByCreator[creator];
    }

    /// @notice Get total number of courses
    function getCourseCount() external view returns (uint256) {
        return courses.length;
    }

    /// @notice Get course at specific index
    function getCourseAtIndex(uint256 index) external view returns (address) {
        require(index < courses.length, "CourseFactory: index out of bounds");
        return courses[index];
    }

    /// @notice Update default treasury address
    function setDefaultTreasury(address newTreasury) external onlyOwner {
        if (newTreasury == address(0)) revert ZeroAddress();
        defaultTreasury = newTreasury;
        emit DefaultTreasuryUpdated(newTreasury);
    }
}

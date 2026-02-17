// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "forge-std/Script.sol";
import "../src/CourseFactory.sol";
import "../src/CourseNFT.sol";

contract CreateCourse is Script {
    function run() external {
        uint256 creatorKey = vm.envUint("PRIVATE_KEY");
        address factoryAddress = vm.envAddress("FACTORY_ADDRESS");
        
        string memory name = vm.envString("COURSE_NAME");
        string memory symbol = vm.envString("COURSE_SYMBOL");
        uint256 mintPrice = vm.envUint("MINT_PRICE");
        uint256 maxSupply = vm.envUint("MAX_SUPPLY");
        string memory baseURI = vm.envString("BASE_URI");
        string memory privateContentURI = vm.envString("PRIVATE_CONTENT_URI");
        address treasury = vm.envOr("TREASURY_ADDRESS", address(0));

        CourseFactory factory = CourseFactory(factoryAddress);

        vm.startBroadcast(creatorKey);

        address courseAddress = factory.createCourse(
            name,
            symbol,
            mintPrice,
            maxSupply,
            baseURI,
            privateContentURI,
            treasury
        );

        vm.stopBroadcast();

        // Console output (not in broadcast)
        console.log("Course NFT created!");
        console.log("Course Address:", courseAddress);
        console.log("Name:", name);
        console.log("Symbol:", symbol);
        console.log("Mint Price:", mintPrice);
        console.log("Max Supply:", maxSupply);
    }
}

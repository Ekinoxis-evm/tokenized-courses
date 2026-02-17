// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "forge-std/Script.sol";
import "../src/CourseFactory.sol";

contract DeployFactory is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address defaultTreasury = vm.envAddress("DEFAULT_TREASURY");

        vm.startBroadcast(deployerKey);

        // Deploy CourseFactory
        CourseFactory factory = new CourseFactory(defaultTreasury);

        vm.stopBroadcast();

        // Console output (not in broadcast)
        console.log("CourseFactory deployed:", address(factory));
        console.log("Default Treasury:", defaultTreasury);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "forge-std/Test.sol";
import "../src/CourseNFT.sol";
import "../src/CourseFactory.sol";

contract CourseNFTTest is Test {
    CourseNFT public course;
    address creator = makeAddr("creator");
    address student1 = makeAddr("student1");
    address student2 = makeAddr("student2");
    address treasury = makeAddr("treasury");

    uint256 constant MINT_PRICE = 0.1 ether;
    uint256 constant MAX_SUPPLY = 100;
    string constant BASE_URI = "ipfs://QmPublicMetadata/";
    string constant PRIVATE_URI = "ipfs://QmPrivateContent";

    function setUp() public {
        vm.prank(creator);
        course = new CourseNFT(
            "Python 101",
            "PY101",
            MINT_PRICE,
            MAX_SUPPLY,
            BASE_URI,
            PRIVATE_URI,
            treasury
        );
    }

    function testInitialization() public view {
        assertEq(course.name(), "Python 101");
        assertEq(course.symbol(), "PY101");
        assertEq(course.mintPrice(), MINT_PRICE);
        assertEq(course.maxSupply(), MAX_SUPPLY);
        assertEq(course.treasury(), treasury);
        assertEq(course.owner(), creator);
    }

    function testMint() public {
        vm.deal(student1, 1 ether);
        
        vm.prank(student1);
        uint256 tokenId = course.mint{value: MINT_PRICE}();

        assertEq(tokenId, 0);
        assertEq(course.ownerOf(tokenId), student1);
        assertEq(course.totalSupply(), 1);
    }

    function testMintMultiple() public {
        vm.deal(student1, 1 ether);
        vm.deal(student2, 1 ether);
        
        vm.prank(student1);
        uint256 tokenId1 = course.mint{value: MINT_PRICE}();
        
        vm.prank(student2);
        uint256 tokenId2 = course.mint{value: MINT_PRICE}();

        assertEq(tokenId1, 0);
        assertEq(tokenId2, 1);
        assertEq(course.totalSupply(), 2);
    }

    function testRevertInsufficientPayment() public {
        vm.deal(student1, 1 ether);
        
        vm.expectRevert(CourseNFT.IncorrectPayment.selector);
        vm.prank(student1);
        course.mint{value: 0.05 ether}();
    }

    function testRevertExcessPayment() public {
        vm.deal(student1, 1 ether);
        
        vm.expectRevert(CourseNFT.IncorrectPayment.selector);
        vm.prank(student1);
        course.mint{value: 0.2 ether}();
    }

    function testMaxSupplyReached() public {
        // Create course with maxSupply = 2
        vm.prank(creator);
        CourseNFT limitedCourse = new CourseNFT(
            "Limited Course",
            "LIM",
            MINT_PRICE,
            2, // maxSupply
            BASE_URI,
            PRIVATE_URI,
            treasury
        );

        vm.deal(student1, 1 ether);
        vm.deal(student2, 1 ether);

        vm.prank(student1);
        limitedCourse.mint{value: MINT_PRICE}();
        
        vm.prank(student2);
        limitedCourse.mint{value: MINT_PRICE}();

        // Third mint should fail
        vm.expectRevert(CourseNFT.MaxSupplyReached.selector);
        vm.prank(student1);
        limitedCourse.mint{value: MINT_PRICE}();
    }

    function testGetCourseContentAsHolder() public {
        vm.deal(student1, 1 ether);
        
        vm.prank(student1);
        uint256 tokenId = course.mint{value: MINT_PRICE}();
        
        vm.prank(student1);
        string memory content = course.getCourseContent(tokenId);
        assertEq(content, PRIVATE_URI);
    }

    function testRevertGetCourseContentAsNonHolder() public {
        vm.deal(student1, 1 ether);
        
        vm.prank(student1);
        uint256 tokenId = course.mint{value: MINT_PRICE}();
        
        vm.expectRevert(CourseNFT.NotTokenHolder.selector);
        vm.prank(student2);
        course.getCourseContent(tokenId);
    }

    function testContentAccessAfterTransfer() public {
        vm.deal(student1, 1 ether);
        
        vm.prank(student1);
        uint256 tokenId = course.mint{value: MINT_PRICE}();
        
        // Transfer to student2
        vm.prank(student1);
        course.transferFrom(student1, student2, tokenId);
        
        // Student1 can no longer access
        vm.expectRevert(CourseNFT.NotTokenHolder.selector);
        vm.prank(student1);
        course.getCourseContent(tokenId);
        
        // Student2 can access
        vm.prank(student2);
        string memory content = course.getCourseContent(tokenId);
        assertEq(content, PRIVATE_URI);
    }

    function testSetMintPrice() public {
        uint256 newPrice = 0.2 ether;
        
        vm.prank(creator);
        course.setMintPrice(newPrice);
        
        assertEq(course.mintPrice(), newPrice);
    }

    function testSetPrivateContentURI() public {
        string memory newURI = "ipfs://QmNewContent";
        
        vm.prank(creator);
        course.setPrivateContentURI(newURI);
        
        // Mint and check new content
        vm.deal(student1, 1 ether);
        vm.prank(student1);
        uint256 tokenId = course.mint{value: MINT_PRICE}();
        
        vm.prank(student1);
        string memory content = course.getCourseContent(tokenId);
        assertEq(content, newURI);
    }

    function testPauseUnpause() public {
        vm.prank(creator);
        course.pause();
        
        vm.deal(student1, 1 ether);
        vm.expectRevert();
        vm.prank(student1);
        course.mint{value: MINT_PRICE}();
        
        vm.prank(creator);
        course.unpause();
        
        vm.prank(student1);
        course.mint{value: MINT_PRICE}();
    }

    function testWithdraw() public {
        // Mint some tokens
        vm.deal(student1, 1 ether);
        vm.deal(student2, 1 ether);
        
        vm.prank(student1);
        course.mint{value: MINT_PRICE}();
        
        vm.prank(student2);
        course.mint{value: MINT_PRICE}();
        
        uint256 treasuryBalanceBefore = treasury.balance;
        
        vm.prank(creator);
        course.withdraw();
        
        assertEq(treasury.balance, treasuryBalanceBefore + (2 * MINT_PRICE));
        assertEq(address(course).balance, 0);
    }

    function testCanMint() public view {
        assertTrue(course.canMint());
    }

    function testTokenURI() public {
        vm.deal(student1, 1 ether);
        
        vm.prank(student1);
        uint256 tokenId = course.mint{value: MINT_PRICE}();
        
        string memory uri = course.tokenURI(tokenId);
        assertEq(uri, string(abi.encodePacked(BASE_URI, "0")));
    }
}

contract CourseFactoryTest is Test {
    CourseFactory public factory;
    address admin = makeAddr("admin");
    address creator1 = makeAddr("creator1");
    address creator2 = makeAddr("creator2");
    address treasury = makeAddr("treasury");

    function setUp() public {
        vm.prank(admin);
        factory = new CourseFactory(treasury);
    }

    function testInitialization() public view {
        assertEq(factory.defaultTreasury(), treasury);
        assertEq(factory.owner(), admin);
        assertEq(factory.getCourseCount(), 0);
    }

    function testCreateCourse() public {
        vm.prank(creator1);
        address courseAddress = factory.createCourse(
            "Python 101",
            "PY101",
            0.1 ether,
            100,
            "ipfs://public/",
            "ipfs://private",
            address(0) // Use default treasury
        );

        assertTrue(courseAddress != address(0));
        assertEq(factory.getCourseCount(), 1);
        
        CourseNFT course = CourseNFT(courseAddress);
        assertEq(course.owner(), creator1);
        assertEq(course.treasury(), treasury);
    }

    function testCreateMultipleCourses() public {
        vm.prank(creator1);
        address course1 = factory.createCourse(
            "Python 101",
            "PY101",
            0.1 ether,
            100,
            "ipfs://public1/",
            "ipfs://private1",
            address(0)
        );

        vm.prank(creator2);
        address course2 = factory.createCourse(
            "Solidity Advanced",
            "SOL201",
            0.2 ether,
            50,
            "ipfs://public2/",
            "ipfs://private2",
            address(0)
        );

        assertEq(factory.getCourseCount(), 2);
        assertTrue(course1 != course2);
    }

    function testGetCoursesByCreator() public {
        vm.startPrank(creator1);
        address course1 = factory.createCourse(
            "Course 1",
            "C1",
            0.1 ether,
            100,
            "ipfs://1/",
            "ipfs://p1",
            address(0)
        );
        
        address course2 = factory.createCourse(
            "Course 2",
            "C2",
            0.2 ether,
            50,
            "ipfs://2/",
            "ipfs://p2",
            address(0)
        );
        vm.stopPrank();

        address[] memory creatorCourses = factory.getCoursesByCreator(creator1);
        assertEq(creatorCourses.length, 2);
        assertEq(creatorCourses[0], course1);
        assertEq(creatorCourses[1], course2);
    }

    function testGetAllCourses() public {
        vm.prank(creator1);
        address course1 = factory.createCourse(
            "Course 1",
            "C1",
            0.1 ether,
            100,
            "ipfs://1/",
            "ipfs://p1",
            address(0)
        );

        vm.prank(creator2);
        address course2 = factory.createCourse(
            "Course 2",
            "C2",
            0.2 ether,
            50,
            "ipfs://2/",
            "ipfs://p2",
            address(0)
        );

        address[] memory allCourses = factory.getAllCourses();
        assertEq(allCourses.length, 2);
        assertEq(allCourses[0], course1);
        assertEq(allCourses[1], course2);
    }

    function testGetCourseAtIndex() public {
        vm.prank(creator1);
        address course1 = factory.createCourse(
            "Course 1",
            "C1",
            0.1 ether,
            100,
            "ipfs://1/",
            "ipfs://p1",
            address(0)
        );

        assertEq(factory.getCourseAtIndex(0), course1);
    }

    function testSetDefaultTreasury() public {
        address newTreasury = makeAddr("newTreasury");
        
        vm.prank(admin);
        factory.setDefaultTreasury(newTreasury);
        
        assertEq(factory.defaultTreasury(), newTreasury);
    }

    function testCustomTreasury() public {
        address customTreasury = makeAddr("customTreasury");
        
        vm.prank(creator1);
        address courseAddress = factory.createCourse(
            "Custom Course",
            "CUS",
            0.1 ether,
            100,
            "ipfs://public/",
            "ipfs://private",
            customTreasury
        );

        CourseNFT course = CourseNFT(courseAddress);
        assertEq(course.treasury(), customTreasury);
    }
}

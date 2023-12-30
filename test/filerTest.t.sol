// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "src/TenNinetyNineDAGenerator.sol";
import "src/TenNinetyNineDAFiler.sol";
import "lib/forge-std/src/console.sol";
import "lib/forge-std/src/Test.sol";

contract filerTest is Test {
    TenNinetyNineDAGenerator public tenG;
    TenNinetyNineDAFiler public tenF;
    address player1 = address(1);
    address player2 = address(2);
    address player3 = address(3);
    address[3] public players = [player1, player2, player3];
    mapping(uint256 => address) public formIdOwnerTest;

    function setUp() public {
        tenG = new TenNinetyNineDAGenerator("test","TEST");
        tenF = new TenNinetyNineDAFiler("test", "TEST", address(tenG));
        uint256 NFTbalance = tenG.balanceOf(address(this));
        assertEq(NFTbalance, 1099);

        transferNFTs(player1, 366, 0); // 0...365
        transferNFTs(player2, 366, 366); // 366...732
        transferNFTs(player3, 367, 732); //
        uint256 p1Balance = tenG.balanceOf(address(player1));
        uint256 p2Balance = tenG.balanceOf(address(player2));
        uint256 p3Balance = tenG.balanceOf(address(player3));
        assertEq(p1Balance + p2Balance + p3Balance, 1099);
        assertEq(tenG.formId(), 0);
    }

    function testChangeButNotOwner() public {
        uint256[] memory tokenArray = buildTokenIdArray(900, 901);

        vm.expectRevert(0x30cd7471);
        vm.prank(player1);
        tenG.exchangeCurrency(tokenArray, 1);
    }

    function testFormIdsFuzz(uint256 x, uint256 y, uint256 z, uint256 r) public {
        x = bound(x, 0, 200); // Bound the number of exchanges

        for (uint256 i; i < x; i++) {
            // Randomize player selection and token ID
            uint8 playerIndex = randomPlayer(y);
            address player = players[playerIndex];
            uint256 tokenId = randomTokenIdForPlayer(player, z);

            uint256[] memory tokenIds = new uint256[](1);
            tokenIds[0] = tokenId;
            // Perform the exchange
            vm.prank(player);
            tenG.exchangeCurrency(tokenIds, randomCivilId(r));

            assertEq(tenG.formId(), i + 1, "Form ID should increment correctly");
            assertEq(tenG.formIdOwner(i), player, "Form owner should match the exchanging player");
            formIdOwnerTest[i] = player;
        }
        checkFilingsNotOwner(x);
        checkFilings(x);
        checkAuditNotification(x);
        checkWellsNotice(x);
        checkAuditNotificationNotOwner(x);
        checkWellsNoticeNotOwner(x);
    }

    function checkWellsNoticeNotOwner(uint256 x) public {
        address player;
        for (uint256 i; i < x; i++) {
            player = formIdOwnerTest[i];
            vm.prank(player);
            // Not sure how to create the data for this: error OwnableUnauthorizedAccount(address account);
            vm.expectRevert();
            tenF.wellsNotice(i, "Owner Changed Wells");
        }
    }

    function checkAuditNotificationNotOwner(uint256 x) public {
        address player;
        for (uint256 i; i < x; i++) {
            player = formIdOwnerTest[i];
            vm.prank(player);
            // Not sure how to create the data for this: error OwnableUnauthorizedAccount(address account);
            vm.expectRevert();
            tenF.auditNotification(i, "Owner Changed Audit");
        }
    }

    function checkWellsNotice(uint256 x) public {
        address player;
        for (uint256 i; i < x; i++) {
            player = formIdOwnerTest[i];
            tenF.wellsNotice(i, "Owner Changed Wells");
            assertEq(tenF.tokenURI(tenF.formIds(i)), "Owner Changed Wells");
            assertEq(tenF.ownerOf(tenF.formIds(i)), player);
            assertTrue(tenF.isMinted(i));
        }
    }

    function checkAuditNotification(uint256 x) public {
        address player;
        for (uint256 i; i < x; i++) {
            player = formIdOwnerTest[i];
            tenF.auditNotification(i, "Owner Changed Audit");
            assertEq(tenF.tokenURI(tenF.formIds(i)), "Owner Changed Audit");
            assertEq(tenF.ownerOf(tenF.formIds(i)), player);
            assertTrue(tenF.isMinted(i));
        }
    }

    function checkFilingsNotOwner(uint256 x) public {
        address player;
        address notPlayer;
        // Note that this may be more robust of we can start at a random number and iterate around.
        // I tried implementing this with b but failed.
        for (uint256 i; i < x; i++) {
            player = formIdOwnerTest[i];

            if (player == player1) {
                notPlayer = player2;
            } else if (player == player2) {
                notPlayer = player3;
            } else {
                notPlayer = player1;
            }

            vm.prank(notPlayer);
            vm.expectRevert(0x30cd7471);
            tenF.fileForm1099DA(i, "google.com");
        }
    }

    function checkFilings(uint256 x) public {
        address player;
        // Note that this may be more robust of we can start at a random number and iterate around.
        // I tried implementing this with b but failed.
        for (uint256 i; i < x; i++) {
            player = formIdOwnerTest[i];

            vm.prank(player);
            tenF.fileForm1099DA(i, "google.com");
            assertEq(tenF.tokenURI(tenF.formIds(i)), "google.com");
            assertEq(tenF.ownerOf(tenF.formIds(i)), player);
            assertTrue(tenF.isMinted(i));
        }
    }

    // Helper function to get a random token ID owned by a player
    function randomTokenIdForPlayer(address player, uint256 z) internal view returns (uint256) {
        if (player == player1) {
            z = bound(z, 0, 365);
        } else if (player == player2) {
            z = bound(z, 366, 731);
        } else {
            z = bound(z, 732, 1098);
        }
        return z;
    }

    // Simple pseudo-random number generator
    function randomPlayer(uint256 y) internal pure returns (uint8) {
        y = bound(y, 0, 2); // bound to three players
        return uint8(y);
    }

    function randomCivilId(uint256 r) internal pure returns (uint8) {
        r = bound(r, 1, 3); // bound to three players
        return uint8(r);
    }

    function transferNFTs(address recipient, uint256 quantity, uint256 startId) public {
        for (uint256 i = startId; i < startId + quantity; i++) {
            // Assuming token IDs are sequential starting from 1
            uint256 tokenId = i;

            // Transfer the NFT from this contract to the recipient
            tenG.transferFrom(address(this), recipient, tokenId);
        }
    }

    function testDeploy() public {
        checkAsserts(0, 1099, 1099);
    }

    function checkAsserts(uint256 startNumber, uint256 _quantity, uint256 totalMinted) public {
        for (uint256 i = startNumber; i < startNumber + _quantity; i++) {
            uint256 servantId = returnServantId(i);
            string memory tokenURI = returnURI(servantId);

            assertEq(tenG.getTeamOfToken(i), servantId);
            assertEq(tenG.tokenURI(i), tokenURI);
        }

        (uint256 count1, uint256 count2, uint256 count3) = returnCounts(totalMinted);
        assertEq(tenG.civilServantCounts(1), count1);
        assertEq(tenG.civilServantCounts(2), count2);
        assertEq(tenG.civilServantCounts(3), count3);
    }

    function returnServantId(uint256 _number) public pure returns (uint256) {
        return (_number % 3) + 1;
    }

    function returnURI(uint256 servantId) public pure returns (string memory) {
        if (servantId == 1) {
            return "gensler";
        } else if (servantId == 2) {
            return "yellen";
        } else if (servantId == 3) {
            return "werfel";
        } else {
            return "invalid";
        }
    }

    function returnCounts(uint256 _quantity) public pure returns (uint256, uint256, uint256) {
        uint256 baseCount = _quantity / 3;
        uint256 remainder = _quantity % 3;

        uint256 count1 = baseCount + (remainder >= 1 ? 1 : 0);
        uint256 count2 = baseCount + (remainder >= 2 ? 1 : 0);
        uint256 count3 = baseCount;

        return (count1, count2, count3);
    }

    function buildTokenIdArray(uint256 startId, uint256 endId) public pure returns (uint256[] memory) {
        uint256 range = endId - startId; // Adjust range to include endId
        uint256[] memory buildTokenIds = new uint256[](range);
        for (uint16 i = 0; i < range; i++) {
            buildTokenIds[i] = startId + i;
        }
        return buildTokenIds;
    }
}

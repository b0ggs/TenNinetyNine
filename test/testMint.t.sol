import "src/TenNineNine.sol";
import "lib/forge-std/src/console.sol";
import "lib/forge-std/src/Test.sol";

contract testMint is Test{

    TenNineNine public tennn;
    address minter;
    function setUp() public {
        minter = address(0x123);
        tennn = new TenNineNine("test","TEST");
        deal(minter, 100 * 1e18);

    }

    function testMintNone() public {

        uint256 quantity = 0;
        uint256 mintCost = tennn.MINT_COST();

        vm.expectRevert("Zero Quantity");
        vm.prank(minter);
        tennn.mintToken{value: mintCost * quantity}(quantity);

    }

    function testMintOne() public {
        uint256 quantity = 1;
        uint256 mintCost = tennn.MINT_COST();

        vm.prank(minter);
        tennn.mintToken{value: mintCost * quantity}(quantity);
        
        checkAsserts(0, quantity, quantity);

    }

    function testMintHundred() public {
        uint256 quantity = 100;
        uint256 mintCost = tennn.MINT_COST();

        vm.prank(minter);
        tennn.mintToken{value: mintCost * quantity}(quantity);
        
        checkAsserts(0, quantity, quantity);
    }

    function testMintMax() public {
        uint256 quantity = 1099;
        uint256 mintCost = tennn.MINT_COST();

        vm.prank(minter);
        tennn.mintToken{value: mintCost * quantity}(quantity);
        
        checkAsserts(0, quantity, quantity);
        
    }

    function testMintTooManyNFTs() public {
        uint256 quantity = 100;
        uint256 mintCost = tennn.MINT_COST();
        for (uint256 i = 0; i < 11; i++) {
            if(i == 10){
                vm.expectRevert("Mint exceeds max amount");
                vm.prank(minter);
                tennn.mintToken{value: mintCost * quantity}(quantity);
            } else {
                vm.prank(minter);
                tennn.mintToken{value: mintCost * quantity}(quantity);
                if (i ==0){
                    checkAsserts(0, quantity, quantity);
                } else{
                    checkAsserts(i * quantity, quantity, (i+1) * quantity);
                }
            
            }
        }

    }

    function testMintTooLowValue() public{
        uint256 quantity = 1;
        uint256 mintCost = tennn.MINT_COST();

        vm.expectRevert("Not Enough ETH");
        vm.prank(minter);
        tennn.mintToken{value: mintCost * quantity - 1}(quantity);
    }

    function testMintTooHighValue() public {
        uint256 quantity = 10;
        uint256 mintCost = tennn.MINT_COST();
        uint256 initialBalance = minter.balance;
        console.log("minter balance", initialBalance);

        vm.prank(minter);
        tennn.mintToken{value: mintCost * quantity + 1000}(quantity);

        assertEq(minter.balance, initialBalance - (mintCost * quantity));
    }


    function testFuzzMint1(uint256 x, uint256 y) public{
        x = bound(x, 1, 1000);
        y = bound(y, 1, 99);

        uint256 mintCost = tennn.MINT_COST();

        vm.prank(minter);
        tennn.mintToken{value: mintCost * x}(x);
        
        checkAsserts(0, x, x);

        vm.prank(minter);
        tennn.mintToken{value: mintCost * y}(y);
        
        checkAsserts(x, y, x+y);


    }

        function testFuzzMint2(uint256 x, uint256 y, uint256 z, uint256 aa) public{
        x = bound(x, 1, 300);
        y = bound(y, 1, 300);
        z = bound(z, 1, 300);
        aa = bound(aa, 1, 299);

        uint256 mintCost = tennn.MINT_COST();

        vm.prank(minter);
        tennn.mintToken{value: mintCost * x}(x);
        
        checkAsserts(0, x, x);

        vm.prank(minter);
        tennn.mintToken{value: mintCost * y}(y);
        
        checkAsserts(x, y, x+y);

        vm.prank(minter);
        tennn.mintToken{value: mintCost * y}(y);
        
        checkAsserts(x + y, z, x+y + z);


    }

    function checkAsserts(uint256 startNumber, uint256 _quantity, uint256 totalMinted) public {
        for (uint256 i = startNumber; i < startNumber + _quantity; i++) {
            uint256 servantId = returnServantId(i);
            string memory tokenURI = returnURI(servantId);

            assertEq(tennn.tokenToCivilServantMapping(i), servantId);
            assertEq(tennn.tokenURI(i), tokenURI);
        }

        (uint256 count1, uint256 count2, uint256 count3) = returnCounts(totalMinted);
        assertEq(tennn.civilServantCounts(1), count1);
        assertEq(tennn.civilServantCounts(2), count2);
        assertEq(tennn.civilServantCounts(3), count3);
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

}
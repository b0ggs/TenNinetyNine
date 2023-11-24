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

        uint256 quantity = 1;
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
        assertEq(tennn.tokenToCivilServantMapping(0), returnServantId(0));
        assertEq(tennn.tokenURI(0), "gensler");
        assertEq(tennn.civilServantCounts(1),1);
        assertEq(tennn.civilServantCounts(2),0);
        assertEq(tennn.civilServantCounts(3),0);

    }

    function testMintHundred() public {

    }

    function testMintMax() public {
        
    }

    function testMintTooLowValue() public{

    }

    function testMintTooHighValue() public {

    }

    function testFuzzMint() public{

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
            return "werler";
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
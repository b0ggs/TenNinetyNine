import "src/TenNinetyNineDA.sol";
import "lib/forge-std/src/console.sol";
import "lib/forge-std/src/Test.sol";

contract deployTest is Test{

    TenNinetyNineDA public tennn;
    address minter;
    function setUp() public {
        tennn = new TenNinetyNineDA("test","TEST");

    }

    function testDeploy() public {
        uint256 NFTbalance = tennn.balanceOf(address(this));
        assertEq(NFTbalance, 1099);

        checkAsserts(0, 1099, 1099);
        
    }

    function testFuzzOfAsserts(uint256 x) public {
        x = bound(x,0,1098);
        checkAsserts(x,0,1099);
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
import "src/TenNineNine.sol";
import "lib/forge-std/src/console.sol";
import "lib/forge-std/src/Test.sol";

contract testMint is Test{

    TenNineNine public tennn;
    function setUp() public {
        tennn = new TenNineNine("test","TEST");

    }

    function testMintNone() public {

    }

    function testMintOne() public {

    }

    function testMintHundred() public {

    }

    function testMintMax() public {
        
    }

    function testFuzzMint() public{

    }

}
import "src/TenNinetyNineDA.sol";
import "lib/forge-std/src/console.sol";
import "lib/forge-std/src/Test.sol";

contract changeTeamTest is Test{

    TenNinetyNineDA public tennn;
    address player1 = address(1);
    address player2 = address(2);
    address player3 = address(3);
    function setUp() public {
        tennn = new TenNinetyNineDA("test","TEST");
        uint256 NFTbalance = tennn.balanceOf(address(this));
        assertEq(NFTbalance, 1099);

        transferNFTs(player1, 366, 0); // 0...365
        transferNFTs(player2, 366, 366); // 366...732
        transferNFTs(player3, 367, 732);// 

        uint256 p1Balance = tennn.balanceOf(address(player1));
        uint256 p2Balance = tennn.balanceOf(address(player2));
        uint256 p3Balance = tennn.balanceOf(address(player3));
        assertEq(p1Balance + p2Balance + p3Balance , 1099);


    }

    function testChangeButNotOwner() public {
        uint256[] memory tokenArray = buildTokenIdArray(900, 901);

        vm.expectRevert(0x30cd7471);
        vm.prank(player1);
        tennn.changeTenNinetyNine(tokenArray, 1);
    }

    function testGameOverGensler() public {
         uint256[] memory player1Ids = buildTokenIdArray(0, 366);
         uint256[] memory player2Ids = buildTokenIdArray(366, 732);
         uint256[] memory player3Ids = buildTokenIdArray(732, 800);

         vm.prank(player1);
         tennn.changeTenNinetyNine(player1Ids, 1);

         vm.prank(player2);
         tennn.changeTenNinetyNine(player2Ids, 1);

         assert(tennn.isURIlocked());

         vm.expectRevert(0xdf469ccb);
         vm.prank(player3);
         tennn.changeTenNinetyNine(player3Ids, 1);
    }

    function testGameOverYellen() public {
         uint256[] memory player1Ids = buildTokenIdArray(0, 366);
         uint256[] memory player2Ids = buildTokenIdArray(366, 732);
         uint256[] memory player3Ids = buildTokenIdArray(732, 800);

         vm.prank(player1);
         tennn.changeTenNinetyNine(player1Ids, 2);

         vm.prank(player2);
         tennn.changeTenNinetyNine(player2Ids, 2);

         assert(tennn.isURIlocked());

         vm.expectRevert(0xdf469ccb);
         vm.prank(player3);
         tennn.changeTenNinetyNine(player3Ids, 2);
    }

    function testGameOverWerfel() public {
         uint256[] memory player1Ids = buildTokenIdArray(0, 366);
         uint256[] memory player2Ids = buildTokenIdArray(366, 732);
         uint256[] memory player3Ids = buildTokenIdArray(732, 800);

         vm.prank(player1);
         tennn.changeTenNinetyNine(player1Ids, 3);

         vm.prank(player2);
         tennn.changeTenNinetyNine(player2Ids, 3);

         assert(tennn.isURIlocked());

         vm.expectRevert(0xdf469ccb);
         vm.prank(player3);
         tennn.changeTenNinetyNine(player3Ids, 3);
    }

    function testPlayer1ChangeFuzz(uint256 x) public {
        uint256 genslerStartCount = 367;
        uint256 yellenStartCount = 366;
        uint256 werfelStartCount = 366;

        x = bound(x,0, 366);

        uint256[] memory player1Ids = buildTokenIdArray(0, x);

        vm.prank(player1);
        tennn.changeTenNinetyNine(player1Ids, 1);
        for (uint256 i = 0; i < player1Ids.length; i++) {
            assertEq(tennn.tokenToCivilServantMapping(player1Ids[i]), 1);
            assertEq(tennn.tokenURI(player1Ids[i]), "gensler");
        }

        uint256 addedIds = (x / 3 * 2);  
        console.log("gensler");      
        if(x % 3 == 2){
            assertEq(tennn.civilServantCounts(1), genslerStartCount + addedIds + 1);
            assertEq(tennn.civilServantCounts(2), yellenStartCount - (x / 3) - 1);
            assertEq(tennn.civilServantCounts(3), werfelStartCount - (x/3));
        }else{
            assertEq(tennn.civilServantCounts(1), genslerStartCount + addedIds);
            assertEq(tennn.civilServantCounts(2), yellenStartCount - (x / 3));
            assertEq(tennn.civilServantCounts(3), werfelStartCount - (x/3));
        }

        vm.prank(player1);
        tennn.changeTenNinetyNine(player1Ids, 2);
        for (uint256 i = 0; i < player1Ids.length; i++) {
            assertEq(tennn.tokenToCivilServantMapping(player1Ids[i]), 2);
            assertEq(tennn.tokenURI(player1Ids[i]), "yellen");
        }

        console.log("yellen");
        if(x % 3 > 0){
            assertEq(tennn.civilServantCounts(1), genslerStartCount - (x / 3) - 1);
            assertEq(tennn.civilServantCounts(2), yellenStartCount + addedIds + 1);
            assertEq(tennn.civilServantCounts(3), werfelStartCount - (x/3));
        }else{
            assertEq(tennn.civilServantCounts(1), genslerStartCount - (x / 3));
            assertEq(tennn.civilServantCounts(2), yellenStartCount + addedIds);
            assertEq(tennn.civilServantCounts(3), werfelStartCount - (x/3));
        }

        vm.prank(player1);
        tennn.changeTenNinetyNine(player1Ids, 3);
        for (uint256 i = 0; i < player1Ids.length; i++) {
            assertEq(tennn.tokenToCivilServantMapping(player1Ids[i]), 3);
            assertEq(tennn.tokenURI(player1Ids[i]), "werfel");
        }

        console.log("werfel");
        if(x % 3 == 2){
            assertEq(tennn.civilServantCounts(1), genslerStartCount - (x / 3) - 1);
            assertEq(tennn.civilServantCounts(2), yellenStartCount - (x / 3) - 1);
            assertEq(tennn.civilServantCounts(3), werfelStartCount + addedIds + 2);
        }else if (x % 3 == 1) {
            assertEq(tennn.civilServantCounts(1), genslerStartCount - (x / 3) - 1);
            assertEq(tennn.civilServantCounts(2), yellenStartCount - (x / 3));
            assertEq(tennn.civilServantCounts(3), werfelStartCount + addedIds + 1);
        }else{
            assertEq(tennn.civilServantCounts(1), genslerStartCount - (x / 3));
            assertEq(tennn.civilServantCounts(2), yellenStartCount - (x / 3));
            assertEq(tennn.civilServantCounts(3), werfelStartCount + addedIds);  
        }
    }

    function testPlayer2ChangeFuzz(uint256 x) public {
        uint256 genslerStartCount = 367;
        uint256 yellenStartCount = 366;
        uint256 werfelStartCount = 366;

        x = bound(x, 366, 732);
        uint256 y = x- 366;

        uint256[] memory player2Ids = buildTokenIdArray(366, x);


        vm.prank(player2);
        tennn.changeTenNinetyNine(player2Ids, 1);
        for (uint256 i = 0; i < player2Ids.length; i++) {
            assertEq(tennn.tokenToCivilServantMapping(player2Ids[i]), 1);
            assertEq(tennn.tokenURI(player2Ids[i]), "gensler");
        }

        uint256 addedIds = (y / 3 * 2);  
        console.log("gensler");      
        if(y % 3 == 2){
            assertEq(tennn.civilServantCounts(1), genslerStartCount + addedIds + 1);
            assertEq(tennn.civilServantCounts(2), yellenStartCount - (y / 3) - 1);
            assertEq(tennn.civilServantCounts(3), werfelStartCount - (y/3));
        }else{
            assertEq(tennn.civilServantCounts(1), genslerStartCount + addedIds);
            assertEq(tennn.civilServantCounts(2), yellenStartCount - (y / 3));
            assertEq(tennn.civilServantCounts(3), werfelStartCount - (y/3));
        }

        vm.prank(player2);
        tennn.changeTenNinetyNine(player2Ids, 2);
        for (uint256 i = 0; i < player2Ids.length; i++) {
            assertEq(tennn.tokenToCivilServantMapping(player2Ids[i]), 2);
            assertEq(tennn.tokenURI(player2Ids[i]), "yellen");
        }

        console.log("yellen");
        if(y % 3 > 0){
            assertEq(tennn.civilServantCounts(1), genslerStartCount - (y / 3) - 1);
            assertEq(tennn.civilServantCounts(2), yellenStartCount + addedIds + 1);
            assertEq(tennn.civilServantCounts(3), werfelStartCount - (y/3));
        }else{
            assertEq(tennn.civilServantCounts(1), genslerStartCount - (y / 3));
            assertEq(tennn.civilServantCounts(2), yellenStartCount + addedIds);
            assertEq(tennn.civilServantCounts(3), werfelStartCount - (y/3));
        }

        vm.prank(player2);
        tennn.changeTenNinetyNine(player2Ids, 3);
        for (uint256 i = 0; i < player2Ids.length; i++) {
            assertEq(tennn.tokenToCivilServantMapping(player2Ids[i]), 3);
            assertEq(tennn.tokenURI(player2Ids[i]), "werfel");
        }

        console.log("werfel");
        if(y % 3 == 2){
            assertEq(tennn.civilServantCounts(1), genslerStartCount - (y / 3) - 1);
            assertEq(tennn.civilServantCounts(2), yellenStartCount - (y / 3) - 1);
            assertEq(tennn.civilServantCounts(3), werfelStartCount + addedIds + 2);
        }else if (y % 3 == 1) {
            assertEq(tennn.civilServantCounts(1), genslerStartCount - (y / 3) - 1);
            assertEq(tennn.civilServantCounts(2), yellenStartCount - (y / 3));
            assertEq(tennn.civilServantCounts(3), werfelStartCount + addedIds + 1);
        }else{
            assertEq(tennn.civilServantCounts(1), genslerStartCount - (y / 3));
            assertEq(tennn.civilServantCounts(2), yellenStartCount - (y / 3));
            assertEq(tennn.civilServantCounts(3), werfelStartCount + addedIds);  
        }
    }

  function testPlayer3ChangeFuzz(uint256 x) public {
        uint256 genslerStartCount = 367;
        uint256 yellenStartCount = 366;
        uint256 werfelStartCount = 366;

        x = bound(x, 732, 1099);

        uint256[] memory player3Ids = buildTokenIdArray(732, x);

        uint256 y = x- 732;

        vm.prank(player3);
        tennn.changeTenNinetyNine(player3Ids, 1);
        for (uint256 i = 0; i < player3Ids.length; i++) {
            assertEq(tennn.tokenToCivilServantMapping(player3Ids[i]), 1);
            assertEq(tennn.tokenURI(player3Ids[i]), "gensler");
        }

        uint256 addedIds = (y / 3 * 2);  
        console.log("gensler");      
        if(y % 3 == 2){
            assertEq(tennn.civilServantCounts(1), genslerStartCount + addedIds + 1);
            assertEq(tennn.civilServantCounts(2), yellenStartCount - (y / 3) - 1);
            assertEq(tennn.civilServantCounts(3), werfelStartCount - (y/3));
        }else{
            assertEq(tennn.civilServantCounts(1), genslerStartCount + addedIds);
            assertEq(tennn.civilServantCounts(2), yellenStartCount - (y / 3));
            assertEq(tennn.civilServantCounts(3), werfelStartCount - (y/3));
        }

        vm.prank(player3);
        tennn.changeTenNinetyNine(player3Ids, 2);
        for (uint256 i = 0; i < player3Ids.length; i++) {
            assertEq(tennn.tokenToCivilServantMapping(player3Ids[i]), 2);
            assertEq(tennn.tokenURI(player3Ids[i]), "yellen");
        }

        console.log("yellen");
        if(y % 3 > 0){
            assertEq(tennn.civilServantCounts(1), genslerStartCount - (y / 3) - 1);
            assertEq(tennn.civilServantCounts(2), yellenStartCount + addedIds + 1);
            assertEq(tennn.civilServantCounts(3), werfelStartCount - (y/3));
        }else{
            assertEq(tennn.civilServantCounts(1), genslerStartCount - (y / 3));
            assertEq(tennn.civilServantCounts(2), yellenStartCount + addedIds);
            assertEq(tennn.civilServantCounts(3), werfelStartCount - (y/3));
        }

        vm.prank(player3);
        tennn.changeTenNinetyNine(player3Ids, 3);
        for (uint256 i = 0; i < player3Ids.length; i++) {
            assertEq(tennn.tokenToCivilServantMapping(player3Ids[i]), 3);
            assertEq(tennn.tokenURI(player3Ids[i]), "werfel");
        }

        console.log("werfel");
        if(y % 3 == 2){
            assertEq(tennn.civilServantCounts(1), genslerStartCount - (y / 3) - 1);
            assertEq(tennn.civilServantCounts(2), yellenStartCount - (y / 3) - 1);
            assertEq(tennn.civilServantCounts(3), werfelStartCount + addedIds + 2);
        }else if (y % 3 == 1) {
            assertEq(tennn.civilServantCounts(1), genslerStartCount - (y / 3) - 1);
            assertEq(tennn.civilServantCounts(2), yellenStartCount - (y / 3));
            assertEq(tennn.civilServantCounts(3), werfelStartCount + addedIds + 1);
        }else{
            assertEq(tennn.civilServantCounts(1), genslerStartCount - (y / 3));
            assertEq(tennn.civilServantCounts(2), yellenStartCount - (y / 3));
            assertEq(tennn.civilServantCounts(3), werfelStartCount + addedIds);  
        }
    }


    function testGameOverGenslerFuzz(uint256 x, uint256 y) public {
        x = bound(x, 366, 732);
        y = bound(y, 732, 1099);

        uint256[] memory player1Ids = buildTokenIdArray(0, 366);
        uint256[] memory player2Ids = buildTokenIdArray(366, x);
        uint256[] memory player3Ids = buildTokenIdArray(732, y);
        

        vm.prank(player1);
        tennn.changeTenNinetyNine(player1Ids, 1);
        console.log("gensler count 1", tennn.civilServantCounts(1));

        uint256 newGenslers;
        if((x-366)% 3 == 2){
            newGenslers = ((x-366) / 3) * 2 + 1;
        } else {
            newGenslers = ((x-366) / 3) * 2;
        }

        vm.prank(player2);
        tennn.changeTenNinetyNine(player2Ids, 1);
        console.log("gensler count 2", tennn.civilServantCounts(1));

        uint256 newGenslers2;
        if((y-732) % 3 == 2){
            newGenslers2 = ((y-732) / 3) * 2 + 1;
        } else {
            newGenslers2 = ((y-732) / 3) * 2;
        }
        console.log("newGenslers", newGenslers);
        console.log("newGenslers2", newGenslers2);

        if(611 + newGenslers >= tennn.WIN_TOKEN_AMOUNT()){
                console.log("assertion1");
                assert(tennn.isURIlocked());

                vm.expectRevert(0xdf469ccb);
                vm.prank(player3);
                tennn.changeTenNinetyNine(player3Ids, 1);
                console.log("gensler count 3", tennn.civilServantCounts(1));
        }else{
            
                vm.prank(player3);
                tennn.changeTenNinetyNine(player3Ids, 1);
                console.log("gensler count 3", tennn.civilServantCounts(1));

                if(611 + newGenslers + newGenslers2 >= tennn.WIN_TOKEN_AMOUNT()){
                    console.log("assertion 2");
                    assert(tennn.isURIlocked());
                }
        }

    
        
    }

  function testGameOverYellenFuzz(uint256 x, uint256 y) public {
        x = bound(x, 366, 732);
        y = bound(y, 732, 1099);

        uint256[] memory player1Ids = buildTokenIdArray(0, 366);
        uint256[] memory player2Ids = buildTokenIdArray(366, x);
        uint256[] memory player3Ids = buildTokenIdArray(732, y);
        

        vm.prank(player1);
        tennn.changeTenNinetyNine(player1Ids, 2);
        console.log("yellen count 1", tennn.civilServantCounts(2));

        uint256 newYellens;
        if((x-366)% 3 > 0){
            newYellens = ((x-366) / 3) * 2 + 1;
        } else {
            newYellens = ((x-366) / 3) * 2;
        }

        vm.prank(player2);
        tennn.changeTenNinetyNine(player2Ids, 2);
        console.log("yellen count 2", tennn.civilServantCounts(2));

        uint256 newYellens2;
        if((y-732) % 3 > 0){
            newYellens2 = ((y-732) / 3) * 2 + 1;
        } else {
            newYellens2 = ((y-732) / 3) * 2;
        }
        console.log("newYellens", newYellens);
        console.log("newYellens2", newYellens2);

        if(610 + newYellens >= tennn.WIN_TOKEN_AMOUNT()){
                console.log("assertion1");
                assert(tennn.isURIlocked());

                vm.expectRevert(0xdf469ccb);
                vm.prank(player3);
                tennn.changeTenNinetyNine(player3Ids, 2);
                console.log("yellen count 3", tennn.civilServantCounts(2));
        }else{
            
                vm.prank(player3);
                tennn.changeTenNinetyNine(player3Ids, 2);
                console.log("yellen count 3", tennn.civilServantCounts(2));

                if(610 + newYellens + newYellens2 >= tennn.WIN_TOKEN_AMOUNT()){
                    console.log("assertion 2");
                    assert(tennn.isURIlocked());
                }
        }

    
        
    }

  function testGameOverWerfelFuzz(uint256 x, uint256 y) public {
        x = bound(x, 366, 732);
        y = bound(y, 732, 1099);

        uint256[] memory player1Ids = buildTokenIdArray(0, 366);
        uint256[] memory player2Ids = buildTokenIdArray(366, x);
        uint256[] memory player3Ids = buildTokenIdArray(732, y);
        

        vm.prank(player1);
        tennn.changeTenNinetyNine(player1Ids, 3);
        console.log("werfel count 1", tennn.civilServantCounts(3));

        uint256 newWerfels;
        if((x-366)% 3 > 0){
            newWerfels = ((x-366) / 3) * 2 + 1;
        } else {
            newWerfels = ((x-366) / 3) * 2;
        }

        vm.prank(player2);
        tennn.changeTenNinetyNine(player2Ids, 3);
        console.log("yellen count 2", tennn.civilServantCounts(3));

        uint256 newWerfels2;
        if((y-732) % 3 > 0){
            newWerfels2 = ((y-732) / 3) * 2 + 1;
        } else {
            newWerfels2 = ((y-732) / 3) * 2;
        }
        console.log("newWerfels", newWerfels);
        console.log("newWerfels2", newWerfels2);

        if(610 + newWerfels >= tennn.WIN_TOKEN_AMOUNT()){
                console.log("assertion1");
                assert(tennn.isURIlocked());

                vm.expectRevert(0xdf469ccb);
                vm.prank(player3);
                tennn.changeTenNinetyNine(player3Ids, 3);
                console.log("werfel count 3", tennn.civilServantCounts(3));
        }else{
            
                vm.prank(player3);
                tennn.changeTenNinetyNine(player3Ids, 3);
                console.log("werfel count 3", tennn.civilServantCounts(3));

                if(610 + newWerfels + newWerfels2 >= tennn.WIN_TOKEN_AMOUNT()){
                    console.log("assertion 2");
                    assert(tennn.isURIlocked());
                }
        }

    
        
    }


    function transferNFTs(address recipient, uint256 quantity, uint256 startId) public {

        for (uint256 i = startId; i < startId + quantity; i++) {
            // Assuming token IDs are sequential starting from 1
            uint256 tokenId = i;

            // Transfer the NFT from this contract to the recipient
            tennn.transferFrom(address(this), recipient, tokenId);
        }
    }

    function testDeploy() public {
        checkAsserts(0, 1099, 1099);
        
    }

    function testFuzzOfAsserts(uint256 x) public {
        x = bound(x,0,1099);
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

    function buildTokenIdArray(uint256 startId, uint256 endId) public pure returns(uint256[] memory) {
        uint256 range = endId - startId;  // Adjust range to include endId
        uint256[] memory buildTokenIds = new uint256[](range);
        for (uint16 i = 0; i < range; i++) {
            buildTokenIds[i] = startId + i;
        }
        return buildTokenIds;
    }

}
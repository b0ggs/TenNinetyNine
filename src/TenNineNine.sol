// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ReentrancyGuard} from "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {ERC721A} from "lib/ERC721A/contracts/ERC721A.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";



// NOTES
// Should we use ownable from oppenzeppelin?
// is reentrancy guard needed?
// Can we mint for OP?
// can we add ways to withdraw other tokens?

contract TenNineNine is ERC721A, Ownable, ReentrancyGuard {

    // Errors
    error notOwner();
    error incorrectPayment();
    error notValidId();
    error nonExistentToken();
    
    // Constants
    uint256 public constant MINT_COST = 0.01 ether;
    uint16 public constant MAX_TOKENS = 1099; 
    uint16 public constant WIN_TOKEN_AMOUNT = 733; // two thirds


    // State variables 
   // address public owner;
    string public genslerURI = "gensler";
    string public yellenURI = "yellen";
    string public werfelURI = "werfel";
    string public lockedURI;
    bool public lockURI = false;
    

    // Data Structures

    mapping(uint256 => uint8) public tokenToCivilServantMapping;
    mapping(uint8 => uint256) public civilServantCounts;

    uint8[3] public civilServants = [
        1, // gensler
        2, // yellen
        3 // werfel
    ];

    // Events
    event BalanceWithdrawn(address owner, uint256 amount);


    constructor(string memory name, string memory symbol)ERC721A(name, symbol)Ownable(msg.sender) {
    }

    receive() external payable {}

    fallback() external payable {}

    //onlyOwner Functions

    /// @notice Withdraws the entire Ether balance to the owner's address.
    /// @dev Can only be called by the contract owner.
    // function withdrawBalance() external onlyOwner {
    //     uint256 amount = address(this).balance;
    //     require(amount > 0, "No Ether funds to withdraw");
    //     payable(owner).transfer(amount);
    // }

    function withdrawBalance() external onlyOwner nonReentrant {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    /// @notice Withdraws the entire balance of a specified ERC-20 token to the owner's address.
    /// @param tokenAddress The address of the ERC-20 token contract.
    function withdrawToken(address tokenAddress) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 tokenBalance = token.balanceOf(address(this));
        require(tokenBalance > 0, "No token funds to withdraw");
        token.transfer(msg.sender, tokenBalance);
    }

    /// @notice Mints a specified quantity of tokens and allocates funds to the designer balance and game pot.
    /// @dev Requires the game to not have started and for there to be enough tokens left to mint.
    /// @param quantity The number of tokens to mint.
    function mintToken(uint16 quantity) external payable {
        require(totalSupply() + quantity <= MAX_TOKENS, "Mint exceeds max amount");
        uint256 currentSupply = totalSupply();
        for (uint16 i = 0; i < quantity; i++) {
            uint256 newTokenId = currentSupply + i;
            uint8 civilServantIndex = uint8(newTokenId % civilServants.length); // Calculate the team index
            uint8 civilServant = civilServants[civilServantIndex]; // Get the team number

            _mint(msg.sender, newTokenId);

            tokenToCivilServantMapping[newTokenId] = civilServant; // Assign the team to the token
            civilServantCounts[civilServant]++; // Increment the team count
        }
        refundIfOver(MINT_COST * quantity);
    }

    function changeTenNinetyNine(uint256[] calldata tokenIds, uint8 newId) external {
        if(newId != 0 && newId != 1 && newId != 2) revert notValidId();

        uint256 newIncrement;
        uint256 genslerDecrement;
        uint256 yellenDecrement;
        uint256 werfelDecrement;

        for (uint256 i; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            if(ownerOf(tokenId) != msg.sender) revert notOwner();
            uint8 currentId = tokenToCivilServantMapping[tokenId];
            if (currentId != newId){
                newIncrement++; // Increment only if there was a change
                    if (currentId == 0) {
                        genslerDecrement++;
                    } else if (currentId == 1) {
                        yellenDecrement++;
                    } else if (currentId == 2) {
                        werfelDecrement++;
                    }

                    tokenToCivilServantMapping[tokenIds[i]] = newId; // Update team of the token
            }
           
            _bulkUpdatecivilServantCountsState(newId, newIncrement, genslerDecrement, yellenDecrement, werfelDecrement);
            _checkGameOver();

        }
    }

    /// @notice Provides the metadata URI for a given token.
    /// @dev Overrides ERC721A's tokenURI function to provide game-specific metadata.
    /// @dev When game ends tokenURI reverts to baseURI and uses {id} metadata-schema.
    /// @param tokenId The token ID to retrieve the URI for.
    /// @return The metadata URI for the token. */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if(!_exists(tokenId)) revert nonExistentToken();
        

        if (!lockURI) {
            uint8 tokenCivilId = tokenToCivilServantMapping[tokenId];
            if(tokenCivilId == 0){
                return genslerURI;
            } else if(tokenCivilId == 1){
                return yellenURI;
            }else if(tokenCivilId == 2){
                return werfelURI;
            } else{
                revert nonExistentToken();
            }

        } else {
            return lockedURI;
        }
    }

    //PRIVATE FUNCTIONS
  function refundIfOver(uint256 price) private {
    require(msg.value >= price, "Need to send more ETH.");
    if (msg.value > price) {
      payable(msg.sender).transfer(msg.value - price);
    }
  }

    //INTERNAL FUNCTIONS

    function _bulkUpdatecivilServantCountsState(uint8 newTeam, uint256 newIncrement, uint256 genslerDecrement, uint256 yellenDecrement, uint256 werfelDecrement) internal {
        if (newTeam == 0) {
            civilServantCounts[0] += newIncrement;
            civilServantCounts[1] -= yellenDecrement;
            civilServantCounts[2] -= werfelDecrement;
        } else if (newTeam == 1) {
            civilServantCounts[1] += newIncrement;
            civilServantCounts[0] -= genslerDecrement;
            civilServantCounts[2] -= werfelDecrement;
        } else if (newTeam == 2) {
            civilServantCounts[2] += newIncrement;
            civilServantCounts[0] -= genslerDecrement;
            civilServantCounts[1] -= yellenDecrement;
        }
    }

    function _checkGameOver() internal {
        uint256 winTokenAmount = WIN_TOKEN_AMOUNT;
        
        if (civilServantCounts[0] >= winTokenAmount) {
            lockedURI = genslerURI;
        } else if (civilServantCounts[1] >= winTokenAmount) {
            lockedURI = yellenURI;
        } else if (civilServantCounts[2] >= winTokenAmount) {
            lockedURI = werfelURI;
        }

        if (keccak256(abi.encodePacked(lockedURI)) != keccak256(abi.encodePacked(""))) { // If lockedURI has been set
            lockURI = true;
          //  emit lockURI(lockedURI);
        }
    }


}
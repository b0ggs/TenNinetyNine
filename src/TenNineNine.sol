// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "lib/ERC721A/contracts/ERC721A.sol";


// NOTES
// Should we use ownable from oppenzeppelin?
// is reentrancy guard needed?
// Can we mint for OP?
// can we add ways to withdraw other tokens?

contract TenNineNine is ERC721A {

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
    address public owner;
    string public genslerURI = "https://ipfs.io/ipfs/CID/{id}.png";
    string public yellenURI = "https://ipfs.io/ipfs/CID/{id}.png";
    string public werferURI = "https://ipfs.io/ipfs/CID/{id}.png";
    string public lockedURI;
    bool public lockURI = false;
    

    // Data Structures

    mapping(uint256 => uint8) public tokenCivilServants;
    mapping(uint8 => uint256) public civilServantCounts;

    uint8[3] public civilServants = [
        1, // gensler
        2, // yellen
        3 // werfer
    ];

    // Events
    event BalanceWithdrawn(address owner, uint256 amount);
 

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(string memory name, string memory symbol) {
        owner = msg.sender;
    }

    receive() external payable {}

    fallback() external payable {}

    //onlyOwner Functions

    /// @notice Withdraws the entire Ether balance to the owner's address.
    /// @dev Can only be called by the contract owner.
    function withdrawBalance() external onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "No Ether funds to withdraw");
        payable(owner()).transfer(amount);
    }

    /// @notice Withdraws the entire balance of a specified ERC-20 token to the owner's address.
    /// @param tokenAddress The address of the ERC-20 token contract.
    function withdrawToken(address tokenAddress) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 tokenBalance = token.balanceOf(address(this));
        require(tokenBalance > 0, "No token funds to withdraw");
        token.transfer(owner(), tokenBalance);
    }

    /// @notice Mints a specified quantity of tokens and allocates funds to the designer balance and game pot.
    /// @dev Requires the game to not have started and for there to be enough tokens left to mint.
    /// @param quantity The number of tokens to mint.
    function mintToken(uint16 quantity) external payable {
        require(totalSupply() + quantity <= MAX_TOKENS, "Mint exceeds max amount");
        require(msg.value == MINT_COST * quantity, "Incorrect Ether sent");

        uint256 currentSupply = totalSupply();
        for (uint16 i = 0; i < quantity; i++) {
            uint256 newTokenId = currentSupply + i;
            uint8 teamIndex = uint8(newTokenId % teams.length); // Calculate the team index
            uint8 team = teams[teamIndex]; // Get the team number

            _mint(msg.sender, newTokenId);

            tokenCivilServants[newTokenId] = team; // Assign the team to the token
            civilServantCounts[team]++; // Increment the team count
        }
    }

    function changeTenNinetyNine(uint256[] calldata tokenIds, uint8 newId) external stateThree {
        if(newId != 0 && newId != 1 && newId != 2) revert notValidId();

        uint256 newIncrement;
        uint256 genslerDecrement;
        uint256 yellenDecrement;
        uint256 werferDecrement;

        for (uint256 i; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            if(!ownerOf(tokenId)) revert notOwner();
            uint8 currentId = tokenCivilServants[tokenId];
            if (currentId != newId){
                newIncrement++; // Increment only if there was a change
                    if (currentTeam == 0) {
                        genslerDecrement++;
                    } else if (currentTeam == 1) {
                        yellenDecrement++;
                    } else if (currentTeam == 2) {
                        werferDecrement++;
                    }

                    tokenCivilServants[tokenIds[i]] = newId; // Update team of the token
            }
           
            _bulkUpdatecivilServantCountsState(newTeam, newIncrement, genslerDecrement, yellenDecrement, werferDecrement);
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
            uint8 tokenCivilId = tokenCivilServants[tokenId];
            if(tokenCivilId == 0){
                return genslerURI;
            } else if(tokenCivilId == 1){
                return yellenURI;
            }else if(tokenCivilId == 2){
                return werferURI;
            }

        } else {
            return lockedURI;
        }
    }

    //INTERNAL FUNCTIONS

    function _bulkUpdatecivilServantCountsState(bytes32 newTeam, uint256 newIncrement, uint256 genslerDecrement, uint256 yellenDecrement, uint256 werferDecrement) internal {
        if (newTeam == 0) {
            civilServantCounts[0] += newIncrement;
            civilServantCounts[1] -= yellenDecrement;
            civilServantCounts[2] -= werferDecrement;
        } else if (newTeam == 1) {
            civilServantCounts[1] += newIncrement;
            civilServantCounts[0] -= genslerDecrement;
            civilServantCounts[2] -= werferDecrement;
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
            lockedURI = werferURI;
        }

        if (lockedURI != "") { // If lockedURI has been set
            lockURI = true;
            emit lockURI(lockedURI);
        }
    }


}


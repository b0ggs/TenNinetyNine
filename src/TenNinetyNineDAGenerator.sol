// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC721A} from "lib/ERC721A/contracts/ERC721A.sol";

/// @title TenNineNineDAGenerator
/// @notice "1099-DA" is an AI-generated art project using NFTs to
///         comment on blockchain regulations.
/// @dev Inherits ERC721A for batch minting and NFT management.
///      Implements game mechanics for dynamic metadata alteration based
///      on user interactions. Tracks distribution of appointees across NFTs.
///      Uses internal functions for updating civil servant counts and
///      checking game-ending conditions. Includes metadata URI setting
///      and locking functionality.
contract TenNinetyNineDAGenerator is ERC721A {
    // Constants
    uint16 public constant MAX_TOKENS = 1099;
    uint16 public constant WIN_TOKEN_AMOUNT = 733; // Two thirds

    // State Variables
    uint256 public formId;
    string public genslerURI = "gensler";
    string public yellenURI = "yellen";
    string public werfelURI = "werfel";
    string public lockedURI;
    bool public isURIlocked = false;

    // Mappings
    mapping(uint256 => uint8) public tokenToCivilServantMapping;
    mapping(uint8 => uint256) public civilServantCounts;
    mapping(uint256 => address) public formIdOwner;

    // Array of civil servants
    uint8[3] public civilServants = [
        1, // Gensler
        2, // Yellen
        3 // Werfel
    ];

    // Events
    event MetadataUpdate(uint256 _tokenId);
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);

    // Errors
    error NotOwner();
    error IncorrectPayment();
    error NotValidId();
    error GameOver();
    error NonExistentToken();

    // Constructor

    /// @notice Creates a new TenNinetyNineDAGenerator contract.
    /// @param name The name of the NFT collection.
    /// @param symbol The symbol of the NFT collection.
    /// @dev Initializes the contract by minting the maximum number of tokens to the contract deployer and
    ///      setting the initial distribution of civil servant counts. The `civilServantCounts` are distributed
    ///      across different IDs representing various civil servants, essential for the game's mechanics.
    constructor(string memory name, string memory symbol) ERC721A(name, symbol) {
        _mintERC2309(msg.sender, MAX_TOKENS);
        civilServantCounts[1] = 367; // Initial count for civil servant 1
        civilServantCounts[2] = 366; // Initial count for civil servant 2
        civilServantCounts[3] = 366; // Initial count for civil servant 3
    }

    /// @notice Deletes a batch of tokens from `i` to `x`
    /// @dev NOTE This function should be removed before deploying the contract
    /// @param i The starting index of tokens to delete
    /// @param x The ending index of tokens to delete
    function deleteBatch(uint16 i, uint16 x) public {
        for (i; i < x; i++) {
            _burn(i);
        }
    }

    /// @notice Changes the Civil Servant for specified token/s
    /// @dev Can only be called by the token owner
    /// @param tokenIds Array of token IDs to change
    /// @param newId The new ID to be assigned
    /// Character Ids:
    /// 1 = Gensler
    /// 2 = Yellen
    /// 3 = Werfer
    function exchangeCurrency(uint256[] calldata tokenIds, uint8 newId) external {
        if (newId != 1 && newId != 2 && newId != 3) revert NotValidId();
        if (isURIlocked) revert GameOver();

        uint256 newIncrement;
        uint256 genslerDecrement;
        uint256 yellenDecrement;
        uint256 werfelDecrement;

        for (uint256 i; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            if (ownerOf(tokenId) != msg.sender) revert NotOwner();
            uint8 currentId = getTeamOfToken(tokenId);
            if (currentId != newId) {
                newIncrement++;
                if (currentId == 1) {
                    genslerDecrement++;
                } else if (currentId == 2) {
                    yellenDecrement++;
                } else if (currentId == 3) {
                    werfelDecrement++;
                }

                tokenToCivilServantMapping[tokenId] = newId;
                emit MetadataUpdate(tokenId);
            }
        }
        _bulkUpdateCivilServantCountsState(newId, newIncrement, genslerDecrement, yellenDecrement, werfelDecrement);
        formIdOwner[formId] = msg.sender;
        formId++;
        _checkGameOver();
    }

    // Public View Functions
    /// @notice Provides the metadata URI for a given token
    /// @dev Overrides ERC721A's tokenURI function to provide game-specific metadata
    /// @param tokenId The token ID to retrieve the URI for
    /// @return The metadata URI for the token
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (!_exists(tokenId)) revert NonExistentToken();

        if (!isURIlocked) {
            uint8 tokenCivilId = getTeamOfToken(tokenId);
            if (tokenCivilId == 1) {
                return genslerURI;
            } else if (tokenCivilId == 2) {
                return yellenURI;
            } else if (tokenCivilId == 3) {
                return werfelURI;
            } else {
                revert NonExistentToken();
            }
        } else {
            return lockedURI;
        }
    }

    /// @notice Retrieves the team ID of a specific token
    /// @param tokenId The ID of the token to query
    /// @return The team ID associated with the given token
    function getTeamOfToken(uint256 tokenId) public view returns (uint8) {
        if (tokenToCivilServantMapping[tokenId] != 0) {
            return tokenToCivilServantMapping[tokenId];
        } else {
            uint256 index = tokenId % 3; // civil servants are 1,2,3
            return civilServants[index];
        }
    }

    /// @dev Updates the counts of civil servants based on the latest changes
    /// @param newTeam The team that tokens are changing to
    /// @param newIncrement The number of tokens added to the new team
    /// @param genslerDecrement The number of tokens to decrement from the Gensler team
    /// @param yellenDecrement The number of tokens to decrement from the Yellen team
    /// @param werfelDecrement The number of tokens to decrement from the Werfel team
    function _bulkUpdateCivilServantCountsState(
        uint8 newTeam,
        uint256 newIncrement,
        uint256 genslerDecrement,
        uint256 yellenDecrement,
        uint256 werfelDecrement
    ) internal {
        if (newTeam == 1) {
            civilServantCounts[1] += newIncrement;
            civilServantCounts[2] -= yellenDecrement;
            civilServantCounts[3] -= werfelDecrement;
        } else if (newTeam == 2) {
            civilServantCounts[2] += newIncrement;
            civilServantCounts[1] -= genslerDecrement;
            civilServantCounts[3] -= werfelDecrement;
        } else if (newTeam == 3) {
            civilServantCounts[3] += newIncrement;
            civilServantCounts[1] -= genslerDecrement;
            civilServantCounts[2] -= yellenDecrement;
        }
    }

    /// @dev Checks if the game conditions have been met and locks the URI if so
    /// A team wins and ends the game by accumulating at least `WIN_TOKEN_AMOUNT` tokens

    function _checkGameOver() internal {
        if (civilServantCounts[1] >= WIN_TOKEN_AMOUNT) {
            lockedURI = genslerURI;
            isURIlocked = true;
            emit BatchMetadataUpdate(0, type(uint256).max);
        } else if (civilServantCounts[2] >= WIN_TOKEN_AMOUNT) {
            lockedURI = yellenURI;
            isURIlocked = true;
            emit BatchMetadataUpdate(0, type(uint256).max);
        } else if (civilServantCounts[3] >= WIN_TOKEN_AMOUNT) {
            lockedURI = werfelURI;
            isURIlocked = true;
            emit BatchMetadataUpdate(0, type(uint256).max);
        }
    }
}

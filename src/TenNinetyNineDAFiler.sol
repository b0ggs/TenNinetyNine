// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {TenNinetyNineDAGenerator} from "./TenNinetyNineDAGenerator.sol";
import { ERC721A } from "lib/ERC721A/contracts/ERC721A.sol";
import { Ownable } from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";


/// @title TenNinetyNineDAFiler
/// @notice This contract is part of the 1099-DA project, allowing users to mint unique NFTs 
///         representing satirical 1099-DA forms. These forms are generated when users interact 
///         with the 'exchangeCurrency' function of the Generator.sol contract on the 1099-DA.ai site.
/// @dev Extends ERC721A and Ownable, providing NFT minting and ownership functionality.
///      Includes methods to mint and manage satirical forms and documents as NFTs. 
///      Interacts with the TenNinetyNineDAGenerator contract to verify user interactions.

contract TenNinetyNineDAFiler is ERC721A, Ownable {

    // State Variables
    TenNinetyNineDAGenerator public immutable tenNineNine;

    // Mappings
    mapping(uint256 => string) public uris;
    mapping(uint256 => bool) public isMinted;
    mapping(uint256 => uint256) public formIds; //NOTE only for testing?

    // Events
    event MetadataUpdate(uint256 _tokenId);

    // Errors
    error UriAlreadySet();
    error NotOwner();
    error AlreadyExists();
    error NonExistentToken();

    /// @notice Creates a new instance of the TenNinetyNineDAFiler contract.
    /// @dev Mints 3 NFTs which are used to store the LLM prompts on-chain.
    /// @param name The name of the NFT collection.
    /// @param symbol The symbol of the NFT collection.
    /// @param _generator The address of the TenNinetyNineDAGenerator contract.
    constructor(string memory name, string memory symbol, address _generator)
        ERC721A(name, symbol)
        Ownable(msg.sender)
    {
        tenNineNine = TenNinetyNineDAGenerator(_generator);
        _mint(msg.sender, 3);
    }

    function getNextTokenId() public view returns (uint256){
        return _nextTokenId();
    }
    // External Functions

    /// @notice Mints a new 1099-DA form NFT with a unique URI.
    /// @dev Mints a single NFT and assigns a URI to it.
    /// @param formId The unique identifier for the form to be minted.
    /// @param formURI The URI that points to the metadata of the minted form.
    function fileForm1099DA(uint256 formId, string calldata formURI) external {
        uint256 tokenId = _nextTokenId();
        if (tenNineNine.formIdOwner(formId) != msg.sender) revert NotOwner();
        if (isMinted[formId]) revert AlreadyExists();
        _mint(msg.sender, 1);
        _setTokenUri(tokenId, formURI);
        isMinted[formId] = true;
        formIds[tokenId] = formId; //NOTE only for testing?
    }

    /// @notice Updates the URI of a specified token to represent an audit notification.
    /// @dev Can only be called by the owner of the contract.
    /// @param tokenId The ID of the token to update.
    /// @param newURI The new URI representing the audit notification.

    function auditNotification(uint256 tokenId, string memory newURI) external onlyOwner {
        if (!_exists(tokenId)) revert NonExistentToken();
        uris[tokenId] = newURI;
        emit MetadataUpdate(tokenId);
    }

    /// @notice Updates the URI of a specified token to represent a Wells Notice.
    /// @dev Can only be called by the owner of the contract.
    /// @param tokenId The ID of the token to update.
    /// @param newURI The new URI representing the Wells Notice.

    function wellsNotice(uint256 tokenId, string memory newURI) external onlyOwner {
        if (!_exists(tokenId)) revert NonExistentToken();
        uris[tokenId] = newURI;
        emit MetadataUpdate(tokenId);
    }

    /// @notice Updates the URI of a specified token to store LLM prompts.
    /// @dev Can only be called by the owner of the contract.
    /// @param tokenId The ID of the token to update.
    /// @param newURI The new URI representing the Wells Notice.
    function setPromptURI(uint256 tokenId, string memory newURI) external onlyOwner {
        if (!_exists(tokenId)) revert NonExistentToken();
        uris[tokenId] = newURI;
        emit MetadataUpdate(tokenId);
    }
    
    // Public Functions

    /// @notice Provides the metadata URI for a given token
    /// @dev Overrides ERC721A's tokenURI function to provide game-specific metadata
    /// @param tokenId The token ID to retrieve the URI for
    /// @return The metadata URI for the token
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (!_exists(tokenId)) revert NonExistentToken();

        return (uris[tokenId]);
    }

    //Internal Functions

    /// @dev Sets the URI for a given token ID. 
    /// @param tokenId The ID of the token to update.
    /// @param _newURI The URI to set for the token.
    function _setTokenUri(uint256 tokenId, string memory _newURI) internal {
        if (bytes(uris[tokenId]).length != 0) revert UriAlreadySet();
        uris[tokenId] = _newURI;
    }

}
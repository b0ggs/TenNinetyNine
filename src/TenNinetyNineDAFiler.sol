// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {TenNinetyNineDAGenerator} from "./TenNinetyNineDAGenerator.sol";
import { ERC721A } from "lib/ERC721A/contracts/ERC721A.sol";
import { Ownable } from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";


contract fileFormTen is ERC721A, Ownable {

    error UriAlreadySet();
    error NotOwner();
    error AlreadyExists();
    error NonExistentToken();


    // ========================
    // ==== State Variables ===
    // ========================

    tenNinetyNineDAGenerator public game;
    address public manager;

    mapping(uint256 => string) public uris;
    mapping(uint256 => bool) public isMinted;
    mapping(uint256 => uint256) public formIds;


    constructor(string memory name, string memory symbol)
        ERC721A(name, symbol)
        Ownable(msg.sender)
    {

    }

    /// @notice Mints a single page.
    function fileForm1099DA(uint256 formId, string calldata formURI) external {
        if (tenNinetyNineDAGenerator.formIdOwner(formId) != msg.sender) revert NotOwner();
        if (!isMinted[formId]) revert AlreadyExists();
        _setTokenUri(_nextTokenId(), formURI);
        isMinted[formId] = true;
        formIds[_nextTokenId()] = formId;
        _mint(msg.sender, 1);
    }

    function auditNotification(uint256 tokenId, string memory newURI) external onlyOwner {
        if (!_exists(tokenId)) revert NonExistentToken();
        uris[tokenId] = newURI;
    }

    function wellsNotice(uint256 tokenId, string memory newURI) external onlyOwner {
        if (!_exists(tokenId)) revert NonExistentToken();
        uris[tokenId] = newURI;
    }


    /// @notice Provides the metadata URI for a given token
    /// @dev Overrides ERC721A's tokenURI function to provide game-specific metadata
    /// @param tokenId The token ID to retrieve the URI for
    /// @return The metadata URI for the token
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (!_exists(tokenId)) revert NonExistentToken();

        return (uris[tokenId]);
    }
    /// @notice Sets the URI for a given token ID.
    /// @param tokenId The ID of the token.
    /// @param _newURI The URI to set for the token.
    function _setTokenUri(uint256 tokenId, string memory _newURI) internal {
        if (bytes(uris[tokenId]).length != 0) revert UriAlreadySet();
        uris[tokenId] = _newURI;
    }


}
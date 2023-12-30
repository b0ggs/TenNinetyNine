// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {TenNinetyNineDAGenerator} from "./TenNinetyNineDAGenerator.sol";
import {ERC721A} from "lib/ERC721A/contracts/ERC721A.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract TenNinetyNineDAFiler is ERC721A, Ownable {
    // ========================
    // ==== State Variables ===
    // ========================

    TenNinetyNineDAGenerator public tenNineNine;

    mapping(uint256 => string) public uris;
    mapping(uint256 => bool) public isMinted;
    mapping(uint256 => uint256) public formIds; //only for testing?

    // Events
    event MetadataUpdate(uint256 _tokenId);

    // Errors
    error UriAlreadySet();
    error NotOwner();
    error AlreadyExists();
    error NonExistentToken();

    constructor(string memory name, string memory symbol, address _generator)
        ERC721A(name, symbol)
        Ownable(msg.sender)
    {
        tenNineNine = TenNinetyNineDAGenerator(_generator);
    }

    /// @notice Mints a single page.
    function fileForm1099DA(uint256 formId, string calldata formURI) external {
        uint256 tokenId = _nextTokenId();
        if (tenNineNine.formIdOwner(formId) != msg.sender) revert NotOwner();
        if (isMinted[formId]) revert AlreadyExists();
        _mint(msg.sender, 1);
        _setTokenUri(tokenId, formURI);
        isMinted[formId] = true;
        formIds[tokenId] = formId; //only for testing?
    }

    function auditNotification(uint256 tokenId, string memory newURI) external onlyOwner {
        if (!_exists(tokenId)) revert NonExistentToken();
        uris[tokenId] = newURI;
        emit MetadataUpdate(tokenId);
    }

    function wellsNotice(uint256 tokenId, string memory newURI) external onlyOwner {
        if (!_exists(tokenId)) revert NonExistentToken();
        uris[tokenId] = newURI;
        emit MetadataUpdate(tokenId);
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

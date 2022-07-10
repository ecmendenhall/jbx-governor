//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { IJBProjects } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBProjects.sol";
import { IJBTokenUriResolver } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBTokenUriResolver.sol";
import { JBProjectMetadata } from "@jbx-protocol/contracts-v2/contracts/structs/JBProjectMetadata.sol";

contract MockJBProjects is IJBProjects, ERC721 {
  constructor() ERC721("MockJBProjects", "NFT") {}

  function count() external view override returns (uint256) {}

  function createFor(address _owner, JBProjectMetadata calldata _metadata) external override returns (uint256 projectId) {}

  function metadataContentOf(uint256 _projectId, uint256 _domain) external view override returns (string memory) {}

  function setMetadataOf(uint256 _projectId, JBProjectMetadata calldata _metadata) external override {}

  function setTokenUriResolver(IJBTokenUriResolver _newResolver) external override {}

  function tokenUriResolver() external view override returns (IJBTokenUriResolver) {}

  function mint(address account, uint256 id) public {
    _mint(account, id);
  }
}

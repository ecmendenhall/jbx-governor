//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { TimelockController } from "@openzeppelin/contracts/governance/TimelockController.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { ERC721Holder } from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import { IJBController } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBController.sol";
import { IJBProjects } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBProjects.sol";
import { IJBTokenStore } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBTokenStore.sol";
import { IJBToken } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBToken.sol";
import { JBGovernor, JBGovernorParams } from "./JBGovernor.sol";
import { JBVotesToken } from "./JBVotesToken.sol";

error NO_TOKEN();

contract JBGovernorFactory is ERC721Holder {
  IJBController internal controller;
  IJBProjects internal projects;
  IJBTokenStore internal tokenStore;

  constructor(
    IJBController _controller,
    IJBProjects _projects,
    IJBTokenStore _tokenStore
  ) {
    controller = _controller;
    projects = _projects;
    tokenStore = _tokenStore;
  }

  function deploy(uint256 projectId, JBGovernorParams memory params)
    external
    returns (
      address,
      address,
      address
    )
  {
    // Transfer project token to contract
    projects.safeTransferFrom(msg.sender, address(this), projectId);

    JBVotesToken token;
    string memory symbol;
    // New scope for token deployment
    {
      // Read metadata from current token
      IJBToken currentToken = tokenStore.tokenOf(projectId);
      if (address(currentToken) == address(0)) revert NO_TOKEN();
      string memory currentName = IERC20Metadata(address(currentToken)).name();
      string memory currentSymbol = IERC20Metadata(address(currentToken)).symbol();

      // Construct new name and symbol
      string memory name = string(abi.encodePacked(currentName, " Governance"));
      symbol = string(abi.encodePacked("v", currentSymbol));

      // Deploy JBXVotes token
      token = new JBVotesToken(name, symbol);

      // Change project token
      controller.changeTokenOf(projectId, token, address(tokenStore));
    }

    TimelockController timelock;
    // New scope for timelock deployment
    {
      // Deploy Timelock
      uint256 minDelay = 0;
      address[] memory proposers = new address[](0);
      address[] memory executors = new address[](0);
      timelock = new TimelockController(minDelay, proposers, executors);

      // Renounce ownership of timelock
      timelock.renounceRole(timelock.TIMELOCK_ADMIN_ROLE(), address(this));
    }

    // Construct Governor name
    string memory governorName = string(abi.encodePacked(symbol, " Governor"));

    // Deploy Governor
    JBGovernor governor = new JBGovernor(token, timelock, governorName, params);

    // Transfer project token to timelock
    projects.safeTransferFrom(address(this), address(timelock), projectId);

    return (address(token), address(governor), address(timelock));
  }
}

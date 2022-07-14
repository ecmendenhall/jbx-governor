//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { TimelockController } from "@openzeppelin/contracts/governance/TimelockController.sol";
import { ERC721Holder } from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import { IJBController } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBController.sol";
import { IJBProjects } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBProjects.sol";
import { IJBTokenStore } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBTokenStore.sol";
import { JBGovernor, JBGovernorParams } from "./JBGovernor.sol";
import { JBVotesToken } from "./JBVotesToken.sol";

import { DeployToken } from "./libraries/DeployToken.sol";
import { DeployTimelock } from "./libraries/DeployTimelock.sol";
import { DeployGovernor } from "./libraries/DeployGovernor.sol";

contract JBGovernorFactory is ERC721Holder {
  IJBController internal controller;
  IJBProjects internal projects;
  IJBTokenStore internal tokenStore;

  event Deployed(address token, address governor, address timelock);

  constructor(
    IJBController _controller,
    IJBProjects _projects,
    IJBTokenStore _tokenStore
  ) {
    controller = _controller;
    projects = _projects;
    tokenStore = _tokenStore;
  }

  function deploy(
    uint256 projectId,
    uint256 initialVotingDelay,
    uint256 initialVotingPeriod,
    uint256 initialProposalThreshold,
    uint256 quorumNumeratorValue
  )
    external
    returns (
      address,
      address,
      address
    )
  {
    // Transfer project token to contract
    projects.safeTransferFrom(msg.sender, address(this), projectId);

    (JBVotesToken token, string memory symbol) = DeployToken.deploy(projectId, tokenStore, controller);
    TimelockController timelock = DeployTimelock.deploy();
    JBGovernor governor;
    {
      JBGovernorParams memory params = JBGovernorParams(initialVotingDelay, initialVotingPeriod, initialProposalThreshold, quorumNumeratorValue);
      governor = DeployGovernor.deploy(symbol, token, timelock, params);
    }

    // Transfer project token to timelock
    projects.safeTransferFrom(address(this), address(timelock), projectId);

    // Transfer gov tokens to caller
    token.transfer(msg.sender, token.balanceOf(address(this)));

    emit Deployed(address(token), address(governor), address(timelock));
    return (address(token), address(governor), address(timelock));
  }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC721Holder } from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import { IJBController } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBController.sol";
import { IJBProjects } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBProjects.sol";
import { IJBTokenStore } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBTokenStore.sol";
import { IJBToken } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBToken.sol";
import { JBProjectMetadata } from "@jbx-protocol/contracts-v2/contracts/structs/JBProjectMetadata.sol";
import { JBFundingCycleData } from "@jbx-protocol/contracts-v2/contracts/structs/JBFundingCycleData.sol";
import { JBFundingCycleMetadata } from "@jbx-protocol/contracts-v2/contracts/structs/JBFundingCycleMetadata.sol";
import { JBGlobalFundingCycleMetadata } from "@jbx-protocol/contracts-v2/contracts/structs/JBFundingCycleMetadata.sol";
import { JBGroupedSplits } from "@jbx-protocol/contracts-v2/contracts/structs/JBGroupedSplits.sol";
import { JBFundAccessConstraints } from "@jbx-protocol/contracts-v2/contracts/structs/JBFundAccessConstraints.sol";
import { IJBPaymentTerminal } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBPaymentTerminal.sol";
import { IJBFundingCycleBallot } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBFundingCycleBallot.sol";

contract JBTestProjectFactory is ERC721Holder {
  IJBController internal controller;
  IJBProjects internal projects;
  IJBTokenStore internal tokenStore;

  event Deployed(uint256 projectId, address token);

  constructor(
    IJBController _controller,
    IJBProjects _projects,
    IJBTokenStore _tokenStore
  ) {
    controller = _controller;
    projects = _projects;
    tokenStore = _tokenStore;
  }

  function deployTestProject(string memory _name, string memory _symbol) external returns (uint256 projectId, IJBToken token) {
    JBProjectMetadata memory projectMetadata = JBProjectMetadata("content", 1);
    JBFundingCycleData memory fundingCycleData = JBFundingCycleData(0, 0, 0, IJBFundingCycleBallot(address(0)));
    JBGlobalFundingCycleMetadata memory globalFundingCycleMetadata = JBGlobalFundingCycleMetadata(false, false);
    JBFundingCycleMetadata memory fundingCycleMetadata = JBFundingCycleMetadata(
      globalFundingCycleMetadata,
      0,
      0,
      0,
      false,
      false,
      false,
      false,
      true,
      true,
      true,
      true,
      false,
      true,
      false,
      false,
      address(0)
    );
    JBGroupedSplits[] memory groupedSplits = new JBGroupedSplits[](0);
    JBFundAccessConstraints[] memory fundAccessConstraints = new JBFundAccessConstraints[](0);
    IJBPaymentTerminal[] memory terminals = new IJBPaymentTerminal[](0);

    projectId = controller.launchProjectFor(
      address(this),
      projectMetadata,
      fundingCycleData,
      fundingCycleMetadata,
      block.timestamp,
      groupedSplits,
      fundAccessConstraints,
      terminals,
      "memo"
    );
    IJBToken token = controller.issueTokenFor(projectId, _name, _symbol);
    projects.safeTransferFrom(address(this), msg.sender, projectId);
    emit Deployed(projectId, address(token));
  }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "../../lib/forge-std/src/Test.sol";
import { ERC721Holder } from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import { IGovernor } from "@openzeppelin/contracts/governance/IGovernor.sol";
import { TimelockController } from "@openzeppelin/contracts/governance/TimelockController.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { JBToken } from "@jbx-protocol/contracts-v2/contracts/JBToken.sol";
import { IJBToken } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBToken.sol";
import { IJBController } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBController.sol";
import { IJBProjects } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBProjects.sol";
import { IJBTokenStore } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBTokenStore.sol";
import { JBProjectMetadata } from "@jbx-protocol/contracts-v2/contracts/structs/JBProjectMetadata.sol";
import { JBFundingCycleData } from "@jbx-protocol/contracts-v2/contracts/structs/JBFundingCycleData.sol";
import { JBFundingCycleMetadata } from "@jbx-protocol/contracts-v2/contracts/structs/JBFundingCycleMetadata.sol";
import { JBGlobalFundingCycleMetadata } from "@jbx-protocol/contracts-v2/contracts/structs/JBFundingCycleMetadata.sol";
import { JBGroupedSplits } from "@jbx-protocol/contracts-v2/contracts/structs/JBGroupedSplits.sol";
import { JBFundAccessConstraints } from "@jbx-protocol/contracts-v2/contracts/structs/JBFundAccessConstraints.sol";
import { IJBPaymentTerminal } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBPaymentTerminal.sol";
import { IJBFundingCycleBallot } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBFundingCycleBallot.sol";
import { JBGovernor } from "../../contracts/JBGovernor.sol";
import { JBGovernorFactory } from "../../contracts/JBGovernorFactory.sol";
import { JBGovernorParams } from "../../contracts/JBGovernor.sol";

contract JBGovernorFactoryForkTest is Test, ERC721Holder {
  JBGovernorFactory factory;
  IJBController controller;
  IJBProjects projects;
  IJBTokenStore tokenStore;
  IJBToken projectToken;
  uint256 projectId;

  function setUp() public {
    projects = IJBProjects(0xD8B4359143eda5B2d763E127Ed27c77addBc47d3);
    tokenStore = IJBTokenStore(0xCBB8e16d998161AdB20465830107ca298995f371);
    controller = IJBController(0x4e3ef8AFCC2B52E4e704f4c8d9B7E7948F651351);
    factory = new JBGovernorFactory(controller, projects, tokenStore);

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
    projectToken = controller.issueTokenFor(projectId, "Test Project", "TEST");
  }

  function testCreatesProject() public {
    assertEq(projects.balanceOf(address(this)), 1);
    assertEq(projects.ownerOf(projectId), address(this));
  }

  function testDeployGovernor() public {
    projects.approve(address(factory), projectId);
    JBGovernorParams memory params = JBGovernorParams(1, 42069, 0, 4);
    (address newToken, address governorAddr, address timelockAddr) = factory.deploy(projectId, params);

    IERC20Metadata token = IERC20Metadata(newToken);
    JBGovernor governor = JBGovernor(payable(governorAddr));
    TimelockController timelock = TimelockController(payable(timelockAddr));

    assertEq(token.name(), "Test Project Governance");
    assertEq(token.symbol(), "vTEST");

    assertEq(governor.votingDelay(), 1);
    assertEq(governor.votingPeriod(), 42069);
    assertEq(governor.proposalThreshold(), 0);
    assertEq(governor.quorumNumerator(), 4);
    assertEq(address(governor.token()), newToken);

    assertEq(projects.ownerOf(projectId), address(timelock));
  }
}

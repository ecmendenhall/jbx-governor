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
import { JBTestProjectFactory } from "../../contracts/JBTestProjectFactory.sol";

contract JBGovernorFactoryForkTest is Test, ERC721Holder {
  JBTestProjectFactory testFactory;
  JBGovernorFactory factory;
  IJBController controller;
  IJBProjects projects;
  IJBTokenStore tokenStore;
  IJBToken projectToken;
  uint256 projectId;

  function setUp() public {
    projects = IJBProjects(0x2d8e361f8F1B5daF33fDb2C99971b33503E60EEE);
    tokenStore = IJBTokenStore(0x220468762c6cE4C05E8fda5cc68Ffaf0CC0B2A85);
    controller = IJBController(0xd96ecf0E07eB197587Ad4A897933f78A00B21c9a);
    testFactory = new JBTestProjectFactory(controller, projects, tokenStore);
    factory = new JBGovernorFactory(controller, projects, tokenStore);
  }

  function testDeployGovernor() public {
    (projectId, projectToken) = testFactory.deployTestProject("Test Project", "TEST");

    projects.approve(address(factory), projectId);
    (address newToken, address governorAddr, address timelockAddr) = factory.deploy(projectId, 1, 42069, 0, 4);
    vm.stopPrank();

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

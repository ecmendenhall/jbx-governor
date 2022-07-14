//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "../lib/forge-std/src/Test.sol";
import { JBToken } from "@jbx-protocol/contracts-v2/contracts/JBToken.sol";
import { JBVotesToken } from "../contracts/JBVotesToken.sol";
import { JBGovernor } from "../contracts/JBGovernor.sol";
import { JBGovernorFactory } from "../contracts/JBGovernorFactory.sol";
import { JBGovernorParams } from "../contracts/JBGovernor.sol";
import { MockJBController, ChangeTokenOfCallArgs } from "./mocks/MockJBController.sol";
import { MockJBProjects } from "./mocks/MockJBProjects.sol";
import { MockJBTokenStore } from "./mocks/MockJBTokenStore.sol";

contract JBGovernorFactoryTest is Test {
  JBToken projectERC20;
  JBGovernorFactory factory;
  MockJBController controller;
  MockJBProjects projects;
  MockJBTokenStore tokenStore;

  function setUp() public {
    projectERC20 = new JBToken("Project Token", "PROJ");
    projects = new MockJBProjects();
    tokenStore = new MockJBTokenStore();
    controller = new MockJBController();
    tokenStore.setTokenOf(1, projectERC20);
    factory = new JBGovernorFactory(controller, projects, tokenStore);
    projects.mint(address(this), 1);
  }

  function testDeploysToken() public {
    projects.approve(address(factory), 1);
    (address token, , ) = factory.deploy(1, 1, 42069, 0, 4);

    assertFalse(token == address(0));
  }

  function testDeploysGovernor() public {
    projects.approve(address(factory), 1);
    (, address governor, ) = factory.deploy(1, 1, 42069, 0, 4);

    assertFalse(governor == address(0));
  }

  function testDeploysTimelock() public {
    projects.approve(address(factory), 1);
    (, , address timelock) = factory.deploy(1, 1, 42069, 0, 4);

    assertFalse(timelock == address(0));
  }

  function testTransfersProjectToTimelock() public {
    assertEq(projects.ownerOf(1), address(this));

    projects.approve(address(factory), 1);
    (, , address timelock) = factory.deploy(1, 1, 42069, 0, 4);

    assertEq(projects.ownerOf(1), timelock);
  }

  function testSetsName() public {
    projects.approve(address(factory), 1);
    (, address governorAddr, ) = factory.deploy(1, 1, 42069, 0, 4);
    JBGovernor governor = JBGovernor(payable(governorAddr));

    assertEq(governor.name(), "vPROJ Governor");
  }

  function testSetsVotingDelay() public {
    projects.approve(address(factory), 1);
    (, address governorAddr, ) = factory.deploy(1, 69, 42069, 0, 4);
    JBGovernor governor = JBGovernor(payable(governorAddr));

    assertEq(governor.votingDelay(), 69);
  }

  function testSetsVotingPeriod() public {
    projects.approve(address(factory), 1);
    (, address governorAddr, ) = factory.deploy(1, 1, 69420, 0, 4);
    JBGovernor governor = JBGovernor(payable(governorAddr));

    assertEq(governor.votingPeriod(), 69420);
  }

  function testSetsProposalThreshold() public {
    projects.approve(address(factory), 1);
    (, address governorAddr, ) = factory.deploy(1, 1, 42069, 10, 4);
    JBGovernor governor = JBGovernor(payable(governorAddr));

    assertEq(governor.proposalThreshold(), 10);
  }

  function testSetsQuorum() public {
    projects.approve(address(factory), 1);
    (, address governorAddr, ) = factory.deploy(1, 1, 42069, 0, 42);
    JBGovernor governor = JBGovernor(payable(governorAddr));

    assertEq(governor.quorumNumerator(), 42);
  }

  function testSetsToken() public {
    projects.approve(address(factory), 1);
    (address token, address governorAddr, ) = factory.deploy(1, 1, 42069, 0, 4);
    JBGovernor governor = JBGovernor(payable(governorAddr));

    assertEq(address(governor.token()), token);
  }

  function testSetsTimelock() public {
    projects.approve(address(factory), 1);
    (, address governorAddr, address timelock) = factory.deploy(1, 1, 42069, 0, 4);
    JBGovernor governor = JBGovernor(payable(governorAddr));

    assertEq(address(governor.timelock()), timelock);
  }

  function testSetsTokenName() public {
    projects.approve(address(factory), 1);
    (address tokenAddr, , ) = factory.deploy(1, 1, 42069, 0, 4);
    JBVotesToken token = JBVotesToken(tokenAddr);

    assertEq(token.name(), "Project Token Governance");
  }

  function testSetsTokenSymbol() public {
    projects.approve(address(factory), 1);
    (address tokenAddr, , ) = factory.deploy(1, 1, 42069, 0, 4);
    JBVotesToken token = JBVotesToken(tokenAddr);

    assertEq(token.symbol(), "vPROJ");
  }

  function testCallsChangeTokenOfOnController() public {
    projects.approve(address(factory), 1);
    (address token, , ) = factory.deploy(1, 1, 42069, 0, 4);

    ChangeTokenOfCallArgs memory callArgs = controller.getChangeTokenOfCalledWith();

    assertTrue(controller.changeTokenOfCalled());
    assertEq(callArgs.projectId, 1);
    assertEq(address(callArgs.token), token);
    assertEq(callArgs.newOwner, address(tokenStore));
  }
}

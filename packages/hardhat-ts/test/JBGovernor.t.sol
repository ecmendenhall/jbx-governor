//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { TimelockController } from "@openzeppelin/contracts/governance/TimelockController.sol";
import { Test } from "../lib/forge-std/src/Test.sol";
import { JBVotesToken } from "../contracts/JBVotesToken.sol";
import { JBGovernor, JBGovernorParams } from "../contracts/JBGovernor.sol";

contract JBGovernorTest is Test {
  JBVotesToken internal token;
  TimelockController internal timelock;
  JBGovernor internal governor;

  function setUp() public {
    token = new JBVotesToken("Test Token", "TEST");
    address[] memory proposers = new address[](0);
    address[] memory executors = new address[](0);
    timelock = new TimelockController(0, proposers, executors);
    JBGovernorParams memory params = JBGovernorParams(1, 42069, 0, 4);
    governor = new JBGovernor(token, timelock, "Test Governor", params);
  }

  function testSetsName() public {
    assertEq(governor.name(), "Test Governor");
  }

  function testSetsVotingDelay() public {
    assertEq(governor.votingDelay(), 1);
  }

  function testSetsVotingPeriod() public {
    assertEq(governor.votingPeriod(), 42069);
  }

  function testSetsProposalThreshold() public {
    assertEq(governor.proposalThreshold(), 0);
  }

  function testSetsQuorum() public {
    assertEq(governor.quorumNumerator(), 4);
  }

  function testSetsToken() public {
    assertEq(address(governor.token()), address(token));
  }

  function testSetsTimelock() public {
    assertEq(address(governor.timelock()), address(timelock));
  }
}

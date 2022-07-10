//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { TimelockController } from "@openzeppelin/contracts/governance/TimelockController.sol";
import { Test } from "../lib/forge-std/src/Test.sol";
import { JBVotesToken } from "../contracts/JBVotesToken.sol";
import { JBGovernor, JBGovernorParams } from "../contracts/JBGovernor.sol";

contract JBGovernorTest is Test {
  JBVotesToken internal token;

  function setUp() public {
    token = new JBVotesToken("Test Token", "TEST");
  }

  function testSetsName() public {
    assertEq(token.name(), "Test Token");
  }

  function testSetsSymbol() public {
    assertEq(token.symbol(), "TEST");
  }

  function testHas18Decimals() public {
    assertEq(token.decimals(), 18);
  }

  function testHasOwner() public {
    assertEq(token.owner(), address(this));
  }
}

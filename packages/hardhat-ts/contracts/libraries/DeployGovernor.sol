//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { TimelockController } from "@openzeppelin/contracts/governance/TimelockController.sol";
import { JBGovernor, JBGovernorParams } from "../JBGovernor.sol";
import { JBVotesToken } from "../JBVotesToken.sol";

library DeployGovernor {
  function deploy(
    string memory symbol,
    JBVotesToken token,
    TimelockController timelock,
    JBGovernorParams memory params
  ) external returns (JBGovernor governor) {
    // Construct Governor name
    string memory governorName = string(abi.encodePacked(symbol, " Governor"));

    // Deploy Governor
    governor = new JBGovernor(token, timelock, governorName, params);
  }
}

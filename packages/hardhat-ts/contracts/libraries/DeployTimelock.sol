//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { TimelockController } from "@openzeppelin/contracts/governance/TimelockController.sol";

library DeployTimelock {
  function deploy() external returns (TimelockController timelock) {
    uint256 minDelay = 0;
    address[] memory proposers = new address[](0);
    address[] memory executors = new address[](0);
    timelock = new TimelockController(minDelay, proposers, executors);

    // Renounce ownership of timelock
    timelock.renounceRole(timelock.TIMELOCK_ADMIN_ROLE(), address(this));
  }
}

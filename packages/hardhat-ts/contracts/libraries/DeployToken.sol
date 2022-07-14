//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { IJBController } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBController.sol";
import { IJBTokenStore } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBTokenStore.sol";
import { IJBToken } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBToken.sol";
import { JBVotesToken } from "../JBVotesToken.sol";

error NO_TOKEN();

library DeployToken {
  function deploy(
    uint256 projectId,
    IJBTokenStore tokenStore,
    IJBController controller
  ) external returns (JBVotesToken token, string memory symbol) {
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

    // Mint 100 test tokens to caller
    token.mint(projectId, msg.sender, 100e18);

    // Change project token
    controller.changeTokenOf(projectId, token, address(tokenStore));
  }
}

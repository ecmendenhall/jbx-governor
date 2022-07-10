//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IJBController } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBController.sol";
import { IJBToken } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBToken.sol";
import { IJBProjects } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBProjects.sol";
import { IJBFundingCycleStore } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBFundingCycleStore.sol";
import { IJBTokenStore } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBTokenStore.sol";
import { IJBSplitsStore } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBSplitsStore.sol";
import { IJBDirectory } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBDirectory.sol";
import { IJBPaymentTerminal } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBPaymentTerminal.sol";
import { IJBMigratable } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBMigratable.sol";
import { JBFundingCycle } from "@jbx-protocol/contracts-v2/contracts/structs/JBFundingCycle.sol";
import { JBFundingCycleData } from "@jbx-protocol/contracts-v2/contracts/structs/JBFundingCycleData.sol";
import { JBFundingCycleMetadata } from "@jbx-protocol/contracts-v2/contracts/structs/JBFundingCycleMetadata.sol";
import { JBProjectMetadata } from "@jbx-protocol/contracts-v2/contracts/structs/JBProjectMetadata.sol";
import { JBGroupedSplits } from "@jbx-protocol/contracts-v2/contracts/structs/JBGroupedSplits.sol";
import { JBFundAccessConstraints } from "@jbx-protocol/contracts-v2/contracts/structs/JBFundAccessConstraints.sol";
import { JBBallotState } from "@jbx-protocol/contracts-v2/contracts/enums/JBBallotState.sol";

struct ChangeTokenOfCallArgs {
  uint256 projectId;
  IJBToken token;
  address newOwner;
}

contract MockJBController is IJBController {
  bool public changeTokenOfCalled;
  ChangeTokenOfCallArgs public changeTokenOfCalledWith;

  function getChangeTokenOfCalledWith() public view returns (ChangeTokenOfCallArgs memory) {
    return changeTokenOfCalledWith;
  }

  function projects() external view override returns (IJBProjects) {}

  function fundingCycleStore() external view override returns (IJBFundingCycleStore) {}

  function tokenStore() external view override returns (IJBTokenStore) {}

  function splitsStore() external view override returns (IJBSplitsStore) {}

  function directory() external view override returns (IJBDirectory) {}

  function reservedTokenBalanceOf(uint256 _projectId, uint256 _reservedRate) external view override returns (uint256) {}

  function distributionLimitOf(
    uint256 _projectId,
    uint256 _configuration,
    IJBPaymentTerminal _terminal,
    address _token
  ) external view override returns (uint256 distributionLimit, uint256 distributionLimitCurrency) {}

  function overflowAllowanceOf(
    uint256 _projectId,
    uint256 _configuration,
    IJBPaymentTerminal _terminal,
    address _token
  ) external view override returns (uint256 overflowAllowance, uint256 overflowAllowanceCurrency) {}

  function totalOutstandingTokensOf(uint256 _projectId, uint256 _reservedRate) external view override returns (uint256) {}

  function getFundingCycleOf(uint256 _projectId, uint256 _configuration)
    external
    view
    override
    returns (JBFundingCycle memory fundingCycle, JBFundingCycleMetadata memory metadata)
  {}

  function latestConfiguredFundingCycleOf(uint256 _projectId)
    external
    view
    override
    returns (
      JBFundingCycle memory,
      JBFundingCycleMetadata memory metadata,
      JBBallotState
    )
  {}

  function currentFundingCycleOf(uint256 _projectId)
    external
    view
    override
    returns (JBFundingCycle memory fundingCycle, JBFundingCycleMetadata memory metadata)
  {}

  function queuedFundingCycleOf(uint256 _projectId)
    external
    view
    override
    returns (JBFundingCycle memory fundingCycle, JBFundingCycleMetadata memory metadata)
  {}

  function launchProjectFor(
    address _owner,
    JBProjectMetadata calldata _projectMetadata,
    JBFundingCycleData calldata _data,
    JBFundingCycleMetadata calldata _metadata,
    uint256 _mustStartAtOrAfter,
    JBGroupedSplits[] memory _groupedSplits,
    JBFundAccessConstraints[] memory _fundAccessConstraints,
    IJBPaymentTerminal[] memory _terminals,
    string calldata _memo
  ) external override returns (uint256 projectId) {}

  function launchFundingCyclesFor(
    uint256 _projectId,
    JBFundingCycleData calldata _data,
    JBFundingCycleMetadata calldata _metadata,
    uint256 _mustStartAtOrAfter,
    JBGroupedSplits[] memory _groupedSplits,
    JBFundAccessConstraints[] memory _fundAccessConstraints,
    IJBPaymentTerminal[] memory _terminals,
    string calldata _memo
  ) external override returns (uint256 configuration) {}

  function reconfigureFundingCyclesOf(
    uint256 _projectId,
    JBFundingCycleData calldata _data,
    JBFundingCycleMetadata calldata _metadata,
    uint256 _mustStartAtOrAfter,
    JBGroupedSplits[] memory _groupedSplits,
    JBFundAccessConstraints[] memory _fundAccessConstraints,
    string calldata _memo
  ) external override returns (uint256) {}

  function issueTokenFor(
    uint256 _projectId,
    string calldata _name,
    string calldata _symbol
  ) external override returns (IJBToken token) {}

  function changeTokenOf(
    uint256 _projectId,
    IJBToken _token,
    address _newOwner
  ) external override {
    changeTokenOfCalled = true;
    changeTokenOfCalledWith = ChangeTokenOfCallArgs(_projectId, _token, _newOwner);
  }

  function mintTokensOf(
    uint256 _projectId,
    uint256 _tokenCount,
    address _beneficiary,
    string calldata _memo,
    bool _preferClaimedTokens,
    bool _useReservedRate
  ) external override returns (uint256 beneficiaryTokenCount) {}

  function burnTokensOf(
    address _holder,
    uint256 _projectId,
    uint256 _tokenCount,
    string calldata _memo,
    bool _preferClaimedTokens
  ) external override {}

  function distributeReservedTokensOf(uint256 _projectId, string memory _memo) external override returns (uint256) {}

  function migrate(uint256 _projectId, IJBMigratable _to) external override {}

  function supportsInterface(bytes4 interfaceId) external view override returns (bool) {}
}

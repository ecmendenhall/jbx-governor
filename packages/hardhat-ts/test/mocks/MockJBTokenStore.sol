//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IJBToken } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBToken.sol";
import { IJBProjects } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBProjects.sol";
import { IJBTokenStore } from "@jbx-protocol/contracts-v2/contracts/interfaces/IJBTokenStore.sol";

struct ChangeForCallArgs {
  uint256 projectId;
  IJBToken token;
  address newOwner;
}

contract MockJBTokenStore is IJBTokenStore {
  mapping(uint256 => IJBToken) public _tokenOf;

  bool public changeForCalled;
  ChangeForCallArgs public changeForCalledWith;

  function tokenOf(uint256 _projectId) external view override returns (IJBToken) {
    return _tokenOf[_projectId];
  }

  function setTokenOf(uint256 _projectId, IJBToken _token) external {
    _tokenOf[_projectId] = _token;
  }

  function projectOf(IJBToken _token) external view override returns (uint256) {}

  function projects() external view override returns (IJBProjects) {}

  function unclaimedBalanceOf(address _holder, uint256 _projectId) external view override returns (uint256) {}

  function unclaimedTotalSupplyOf(uint256 _projectId) external view override returns (uint256) {}

  function totalSupplyOf(uint256 _projectId) external view override returns (uint256) {}

  function balanceOf(address _holder, uint256 _projectId) external view override returns (uint256 _result) {}

  function requireClaimFor(uint256 _projectId) external view override returns (bool) {}

  function issueFor(
    uint256 _projectId,
    string calldata _name,
    string calldata _symbol
  ) external override returns (IJBToken token) {}

  function changeFor(
    uint256 _projectId,
    IJBToken _token,
    address _newOwner
  ) external override returns (IJBToken oldToken) {
    oldToken = _tokenOf[_projectId];
    changeForCalled = true;
    changeForCalledWith = ChangeForCallArgs(_projectId, _token, _newOwner);
  }

  function burnFrom(
    address _holder,
    uint256 _projectId,
    uint256 _amount,
    bool _preferClaimedTokens
  ) external override {}

  function mintFor(
    address _holder,
    uint256 _projectId,
    uint256 _amount,
    bool _preferClaimedTokens
  ) external override {}

  function shouldRequireClaimingFor(uint256 _projectId, bool _flag) external override {}

  function claimFor(
    address _holder,
    uint256 _projectId,
    uint256 _amount
  ) external override {}

  function transferFrom(
    address _holder,
    uint256 _projectId,
    address _recipient,
    uint256 _amount
  ) external override {}
}

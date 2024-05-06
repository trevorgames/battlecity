// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Admin } from "../codegen/index.sol";

function isAdmin(bytes32 key) view returns (bool) {
  return Admin.get(key);
}

function min(int32 a, int32 b) pure returns (int32) {
  return a < b ? a : b;
}

function max(int32 a, int32 b) pure returns (int32) {
  return a > b ? a : b;
}

function addressToEntity(address a) pure returns (bytes32) {
  return bytes32(uint256(uint160((a))));
}

function entityToAddress(bytes32 value) pure returns (address) {
  return address(uint160(uint256(value)));
}

function entityToKeyTuple(bytes32 matchEntity, bytes32 entity) pure returns (bytes32[] memory keyTuple) {
  keyTuple = new bytes32[](2);
  keyTuple[0] = matchEntity;
  keyTuple[1] = entity;
}

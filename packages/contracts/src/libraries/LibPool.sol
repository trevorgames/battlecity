// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Config } from "../codegen/index.sol";
import { hasToken } from "./hasToken.sol";

uint256 constant DENOMINATOR = 100;

function keyHolderOnly(address sender) {
  require(hasToken(Config.getStrategoKeyToken(), sender), "caller does not have the stratego key");
}

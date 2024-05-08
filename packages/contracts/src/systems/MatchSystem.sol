// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Config } from "../codegen/index.sol";

contract MatchSystem is System {
    modifier worldUnlocked() {
        require(!Config.getLocked(), "world is locked");
        _;
    }
}

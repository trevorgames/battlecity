// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { StandardDelegationsModule } from "@latticexyz/world-modules/src/modules/std-delegations/StandardDelegationsModule.sol";
import { PuppetModule } from "@latticexyz/world-modules/src/modules/puppet/PuppetModule.sol";
import { registerERC20 } from "@latticexyz/world-modules/src/modules/erc20-puppet/registerERC20.sol";
import { registerERC721 } from "@latticexyz/world-modules/src/modules/erc721-puppet/registerERC721.sol";
import { IERC20Mintable } from "@latticexyz/world-modules/src/modules/erc20-puppet/IERC20Mintable.sol";
import { IERC721Mintable } from "@latticexyz/world-modules/src/modules/erc721-puppet/IERC721Mintable.sol";
import { ERC20MetadataData } from "@latticexyz/world-modules/src/modules/erc20-puppet/tables/ERC20Metadata.sol";
import { ERC721MetadataData } from "@latticexyz/world-modules/src/modules/erc721-puppet/tables/ERC721Metadata.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { Admin, Config } from "../src/codegen/index.sol";
import { addressToEntity } from "../src/libraries/LibUtils.sol";
import { SWORD_NAMESPACE, SEASON_PASS_NAMESPACE, SEASON_PASS_SYMBOL, SEASON_PASS_NAME, SEASON_PASS_BASE_URI, STRATEGO_KEY_NAMESPACE, STRATEGO_KEY_SYMBOL, STRATEGO_KEY_NAME, STRATEGO_KEY_BASE_URI, STRATEGO_KEY_TOKEN_ID, POOL_SUPPLY } from "../src/libraries/constants.sol";

contract PostDeploy is Script {
  function run(address worldAddress) external {
    // Specify a store so that you can use tables directly in PostDeploy
    StoreSwitch.setStoreAddress(worldAddress);

    IWorld world = IWorld(worldAddress);

    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    address admin = vm.addr(deployerPrivateKey);
    bytes32 adminEntity = addressToEntity(admin);

    Admin.set(adminEntity, true);

    world.installRootModule(new StandardDelegationsModule(), new bytes(0));

    world.installModule(new PuppetModule(), new bytes(0));

    {
      // Initialise tokens
      IERC20Mintable swordToken = registerERC20(
        world,
        SWORD_NAMESPACE,
        ERC20MetadataData({ decimals: 18, name: "Sword", symbol: unicode"⚔️" })
      );
      IERC721Mintable seasonPass = registerERC721(
        world,
        SEASON_PASS_NAMESPACE,
        ERC721MetadataData({ name: SEASON_PASS_NAME, symbol: SEASON_PASS_SYMBOL, baseURI: SEASON_PASS_BASE_URI })
      );
      IERC721Mintable skyKey = registerERC721(
        world,
        STRATEGO_KEY_NAMESPACE,
        ERC721MetadataData({ name: STRATEGO_KEY_NAME, symbol: STRATEGO_KEY_SYMBOL, baseURI: STRATEGO_KEY_BASE_URI })
      );

      Config.set(false, address(swordToken), address(seasonPass), address(skyKey));

      swordToken.mint(worldAddress, POOL_SUPPLY);
      skyKey.mint(admin, STRATEGO_KEY_TOKEN_ID);
    }

    vm.stopBroadcast();
  }
}

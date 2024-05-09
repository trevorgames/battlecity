// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

uint256 constant ARRANGEMENT_SIZE = 100;
uint256 constant ARRANGEMENT_SIDE_SIZE = 10;
uint256 constant PLAYER_ARRANGEMENT_SIZE = 40;

bytes14 constant SWORD_NAMESPACE = "Sword";

bytes14 constant SEASON_PASS_NAMESPACE = "Season1";
string constant SEASON_PASS_SYMBOL = unicode"🎫-1";
string constant SEASON_PASS_NAME = "Season Pass (Season 1)";
string constant SEASON_PASS_BASE_URI = "https://zkstratego.xyz/metadata/seasonpass-1/";

bytes14 constant STRATEGO_KEY_NAMESPACE = "StrategoKey";
string constant STRATEGO_KEY_SYMBOL = unicode"🔑";
string constant STRATEGO_KEY_NAME = "Stratego Key";
string constant STRATEGO_KEY_BASE_URI = "https://zkstratego.xyz/metadata/strategokey/";

uint256 constant STRATEGO_KEY_TOKEN_ID = 0;

uint256 constant POOL_SUPPLY = 100_000_000 ether; // tokens in pool

uint256 constant SEASON_PASS_STARTING_PRICE = 0.03 ether;
uint256 constant SEASON_PASS_MIN_PRICE = 0.03 ether;
uint256 constant SEASON_PASS_PRICE_DECREASE_PER_SECOND = 0;
uint256 constant SEASON_PASS_PRICE_DECREASE_DENOMINATOR = 10_000_000_000;
uint256 constant SEASON_PASS_PURCHASE_MULTIPLIER_PERCENT = 100;
uint256 constant SEASON_START_TIME = 1717243200; // 2024-06-01T12:00:00.000Z
uint256 constant SEASON_PASS_MINT_DURATION = 3 days;
uint256 constant SEASON_DURATION = 30 days;

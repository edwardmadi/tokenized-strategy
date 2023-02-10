// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.14;

import "forge-std/console.sol";
import {ExtendedTest} from "./ExtendedTest.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {MockErc20} from "../Mocks/MockErc20.sol";
import {Generic4626} from "../Mocks/Generic4626.sol";
import {MockStrategy} from "../Mocks/MockStrategy.sol";

import {SelectorHelper} from "../../SelectorHelper.sol";
import {BaseLibrary} from "../../libraries/BaseLibrary.sol";

contract Setup is ExtendedTest {

    MockErc20 public token;
    Generic4626 public strategy;
    
    SelectorHelper public selectorHelper;

    address public user = address(10);

    uint256 public minFuzzAmount = 1;
    uint256 public maxFuzzAmount = 1e50;

    function setUp() public virtual {

        token = new MockErc20("Test Token", "tTKN");
        // we save the mock base strategy as a Generic4626 to give it the needed interface
        strategy = Generic4626(address(new MockStrategy(token)));

        // deploy the selector helper
        bytes4[] memory selectors = new bytes4[](1);
        selectorHelper = new SelectorHelper(selectors);

        // set the slots for the baseLibrary and the selector helper to the correct addresses
        // store the libraries address at slot 0
        vm.store(address(strategy), bytes32(0), bytes32(uint256(uint160(address(BaseLibrary)))));
        // store the helper at slot 1
        vm.store(address(strategy), bytes32(uint256(1)), bytes32(uint256(uint160(address(selectorHelper)))));
        // make sure our storage is set correctly
        assertEq(MockStrategy(payable(address(strategy))).baseLibrary(), address(BaseLibrary), "lib slot");
        assertEq(MockStrategy(payable(address(strategy))).selectorHelper(), address(selectorHelper), "helper slot");

        // label all the used addresses for traces
        vm.label(address(token), "token");
        vm.label(address(strategy), "strategy");
        vm.label(address(BaseLibrary), "library");
        vm.label(address(selectorHelper), "selector heleper");
    }
}
// SPDX-License-Identifier: GPL-3-0-or-later
pragma solidity >=0.8.19;

import { ISablierV2LockupLinear } from "lib/v2-core/src/interfaces/ISablierV2LockupLinear.sol";

import { Test } from "forge-std/Test.sol";

import { Vesting } from "../src/Vesting.sol";

contract VestingTest is Test {
    // Get the latest deployment address from the docs: https://docs.sablier.com/contracts/v2/deployments
    address internal constant SABLIER_ADDRESS = address(0xB10daee1FCF62243aE27776D7a92D39dC8740f95);

    // Test contracts
    Vesting internal vesting;
    ISablierV2LockupLinear internal lockupLinear;
    address internal user;

    function setUp() public {
        // Fork Ethereum Mainnet
        vm.createSelectFork({ urlOrAlias: "https://rpc.ankr.com/eth" });

        // Load the Sablier contract from Ethereum Mainnet
        lockupLinear = ISablierV2LockupLinear(SABLIER_ADDRESS);

        // Deploy the stream creator
        vesting = new Vesting(lockupLinear);

        // Create a test user
        user = payable(makeAddr("User"));
        vm.deal({ account: user, newBalance: 1 ether });

        // Mint some DAI tokens to the test user, which will be pulled by the creator contract
        deal({ token: address(vesting.DAI()), to: user, give: 1337e18 });

        // Make the test user the `msg.sender` in all following calls
        vm.startPrank({ msgSender: user });

        // Approve the creator contract to pull DAI tokens from the test user
        vesting.DAI().approve({ spender: address(vesting), amount: 1337e18 });
    }

    // Tests that creating streams works by checking the stream ids
    function test_CreateLockupLinearStream() public {
        uint256 expectedStreamId = lockupLinear.nextStreamId();
        uint256 actualStreamId = vesting.createLockupLinearStream({ totalAmount: 1337e18 });
        assertEq(actualStreamId, expectedStreamId);
    }
}

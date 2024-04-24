// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title PlatformToken
 * @dev Implements a custom token for the freelancing platform with ERC20 standard. The token is used for payments, rewards, and possibly governance.
 */
contract PlatformToken is ERC20, Ownable {
    /**
     * @dev Sets the token name and symbol upon contract deployment.
     */
    constructor() ERC20("PlatformToken", "PTK") {
        // Initial mint can go here if required
    }

    /**
     * @notice Mints tokens to a recipient address.
     * @dev Can only be called by the contract owner. Useful for rewards and initial token distribution.
     * @param to The recipient of the tokens.
     * @param amount The amount of tokens to mint.
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    /**
     * @notice Burns tokens from a holder.
     * @dev Can only be called by the token holder.
     * @param amount The amount of tokens to burn.
     */
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    // Additional functionalities like staking, rewards distribution, and governance can be implemented here

    /**
     * @notice Implements a simple reward mechanism for platform participation.
     * @dev This function is a placeholder for actual logic that might involve external calls to other contracts.
     * @param participant The participant to be rewarded.
     * @param amount The amount of tokens to reward.
     */
    function rewardParticipant(address participant, uint256 amount) external onlyOwner {
        // Ensure valid logic is in place to check for conditions or participation validity
        _mint(participant, amount);
    }
}

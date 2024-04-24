// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title Portfolio Management Contract for Decentralized Freelancing Platform
 * @dev Manages the storage and display of freelancers' portfolios, leveraging IPFS for decentralized file storage.
 */
contract PortfolioContract is AccessControl {
    struct PortfolioItem {
        string ipfsHash; // IPFS hash pointing to the portfolio item
        string description; // Description of the portfolio item
    }

    // Mapping from freelancer's address to their portfolio items
    mapping(address => PortfolioItem[]) public portfolios;

    // Define roles
    bytes32 public constant FREELANCER_ROLE = keccak256("FREELANCER_ROLE");

    // Events
    event PortfolioItemAdded(address indexed freelancer, string ipfsHash);
    event PortfolioItemRemoved(address indexed freelancer, uint256 index);

    /**
     * @dev Sets up the default admin role and the freelancer role.
     */
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @notice Adds a portfolio item to a freelancer's portfolio.
     * @param ipfsHash The IPFS hash of the portfolio item.
     * @param description Description of the portfolio item.
     */
    function addPortfolioItem(string memory ipfsHash, string memory description) public onlyRole(FREELANCER_ROLE) {
        portfolios[msg.sender].push(PortfolioItem(ipfsHash, description));
        emit PortfolioItemAdded(msg.sender, ipfsHash);
    }

    /**
     * @notice Removes a portfolio item from a freelancer's portfolio.
     * @param index The index of the portfolio item to remove.
     */
    function removePortfolioItem(uint256 index) public onlyRole(FREELANCER_ROLE) {
        require(index < portfolios[msg.sender].length, "Index out of bounds");

        // To delete an element from the array without leaving a gap, we swap the last element into the place to delete and then pop the last element.
        if (index < portfolios[msg.sender].length - 1) {
            portfolios[msg.sender][index] = portfolios[msg.sender][portfolios[msg.sender].length - 1];
        }

        portfolios[msg.sender].pop();
        emit PortfolioItemRemoved(msg.sender, index);
    }

    /**
     * @notice Retrieves the portfolio items of a freelancer.
     * @param freelancer The address of the freelancer.
     * @return An array of portfolio items.
     */
    function getPortfolioItems(address freelancer) public view returns (PortfolioItem[] memory) {
        return portfolios[freelancer];
    }

    // Additional functions for managing portfolio items and freelancer profiles can be added here.
}

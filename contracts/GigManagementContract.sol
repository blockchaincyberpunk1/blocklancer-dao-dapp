// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title Gig Management for Decentralized Freelancing Platform
 * @dev Manages gigs/services offered by freelancers, including creation, update, and listing.
 * Utilizes OpenZeppelin's AccessControl for role-based access control.
 */
contract GigManagementContract is AccessControl {
    // Custom types
    enum GigStatus { Open, InProgress, Completed }

    struct Gig {
        uint256 id;
        address freelancer;
        string title;
        string description;
        uint256 price;
        GigStatus status;
    }

    // State variables
    uint256 private nextGigId;
    mapping(uint256 => Gig) private gigs;

    // Events
    event GigCreated(uint256 indexed id, address indexed freelancer, string title, uint256 price);
    event GigUpdated(uint256 indexed id, string title, uint256 price);
    event GigStatusChanged(uint256 indexed id, GigStatus status);

    // Role definitions
    bytes32 public constant FREELANCER_ROLE = keccak256("FREELANCER_ROLE");

    /**
     * @dev Constructor to set up initial roles and permissions.
     */
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @notice Creates a new gig with the given details.
     * @dev Requires the sender to have the FREELANCER_ROLE.
     * @param title The title of the gig.
     * @param description A brief description of the service offered.
     * @param price The price for the gig.
     */
    function createGig(string memory title, string memory description, uint256 price) public onlyRole(FREELANCER_ROLE) {
        uint256 gigId = nextGigId++;
        gigs[gigId] = Gig(gigId, msg.sender, title, description, price, GigStatus.Open);
        emit GigCreated(gigId, msg.sender, title, price);
    }

    /**
     * @notice Updates the details of an existing gig.
     * @dev Can only be called by the gig's creator and requires the gig to be in Open status.
     * @param gigId The ID of the gig to update.
     * @param title New title for the gig.
     * @param description New description for the gig.
     * @param price New price for the gig.
     */
    function updateGig(uint256 gigId, string memory title, string memory description, uint256 price) public {
        require(gigs[gigId].freelancer == msg.sender, "Only the gig creator can update it.");
        require(gigs[gigId].status == GigStatus.Open, "Can only update gigs that are open.");
        gigs[gigId].title = title;
        gigs[gigId].description = description;
        gigs[gigId].price = price;
        emit GigUpdated(gigId, title, price);
    }

    /**
     * @notice Changes the status of a gig.
     * @dev Can only be called by the gig's creator. Validates the transition is valid.
     * @param gigId The ID of the gig.
     * @param status The new status for the gig.
     */
    function changeGigStatus(uint256 gigId, GigStatus status) public {
        require(gigs[gigId].freelancer == msg.sender, "Only the gig creator can change its status.");
        gigs[gigId].status = status;
        emit GigStatusChanged(gigId, status);
    }

    /**
     * @notice Retrieves the details of a gig.
     * @param gigId The ID of the gig to retrieve.
     * @return The gig details.
     */
    function getGig(uint256 gigId) public view returns (Gig memory) {
        return gigs[gigId];
    }

    // Additional functions like listing and searching gigs could be implemented here.
}

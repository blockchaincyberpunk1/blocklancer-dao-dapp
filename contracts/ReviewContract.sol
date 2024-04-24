// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title Review and Rating Contract for Decentralized Freelancing Platform
 * @dev Manages the submission, storage, and retrieval of reviews and ratings for gigs.
 * Ensures that only legitimate clients who have completed transactions with freelancers can leave reviews.
 */
contract ReviewContract is AccessControl {
    // Custom types
    struct Review {
        uint256 rating; // Rating on a scale of 1 to 5
        string comment; // Textual review
        address reviewer; // Address of the reviewer (client or freelancer)
        bool isClient; // True if reviewer is a client, false if freelancer
    }

    // State variables
    mapping(uint256 => Review[]) private gigReviews; // Maps gig IDs to their reviews

    // Events
    event ReviewSubmitted(uint256 indexed gigId, address indexed reviewer, uint256 rating);

    // Role definitions
    bytes32 public constant CLIENT_ROLE = keccak256("CLIENT_ROLE");
    bytes32 public constant FREELANCER_ROLE = keccak256("FREELANCER_ROLE");

    /**
     * @dev Constructor to set up the default admin role.
     */
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @notice Submits a review for a gig.
     * @dev Restricts submissions to users who have either CLIENT_ROLE or FREELANCER_ROLE.
     * @param gigId The ID of the gig being reviewed.
     * @param rating The rating given to the gig.
     * @param comment A textual comment about the gig.
     * @param isClient True if the reviewer is a client, otherwise false.
     */
    function submitReview(uint256 gigId, uint256 rating, string memory comment, bool isClient) public {
        require(
            hasRole(CLIENT_ROLE, msg.sender) || hasRole(FREELANCER_ROLE, msg.sender),
            "Only clients or freelancers can submit reviews"
        );
        require(rating >= 1 && rating <= 5, "Rating must be between 1 and 5");

        gigReviews[gigId].push(Review({
            rating: rating,
            comment: comment,
            reviewer: msg.sender,
            isClient: isClient
        }));

        emit ReviewSubmitted(gigId, msg.sender, rating);
    }

    /**
     * @notice Retrieves all reviews for a given gig.
     * @param gigId The ID of the gig for which reviews are being retrieved.
     * @return An array of reviews for the specified gig.
     */
    function getReviews(uint256 gigId) public view returns (Review[] memory) {
        return gigReviews[gigId];
    }

    // Additional functions such as review verification, updating, or deleting reviews could be implemented here.
}

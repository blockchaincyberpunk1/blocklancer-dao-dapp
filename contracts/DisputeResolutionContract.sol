// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title Dispute Resolution Contract for Decentralized Freelancing Platform
 * @dev Manages disputes between clients and freelancers with a voting mechanism for resolution.
 */
contract DisputeResolutionContract is AccessControl, ReentrancyGuard {
    // Custom types
    enum DisputeStatus { Open, Resolved, Refunded }

    struct Dispute {
        uint256 gigId;
        address client;
        address freelancer;
        string reason;
        DisputeStatus status;
    }

    // State variables
    uint256 private nextDisputeId;
    mapping(uint256 => Dispute) public disputes;

    // Role definitions
    bytes32 public constant ARBITRATOR_ROLE = keccak256("ARBITRATOR_ROLE");

    // Events
    event DisputeRaised(uint256 indexed disputeId, uint256 indexed gigId, string reason);
    event DisputeResolved(uint256 indexed disputeId);
    event FundsRefunded(uint256 indexed disputeId);

    // Modifier to check if caller is an arbitrator
    modifier onlyArbitrator() {
        require(hasRole(ARBITRATOR_ROLE, msg.sender), "Caller is not an arbitrator");
        _;
    }

    /**
     * @dev Constructor to setup the default admin role.
     */
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @notice Raises a dispute for a specific gig.
     * @param gigId The ID of the gig associated with the dispute.
     * @param client The address of the client who initiated the dispute.
     * @param freelancer The address of the freelancer against whom the dispute is raised.
     * @param reason A brief description of the reason for the dispute.
     */
    function raiseDispute(uint256 gigId, address client, address freelancer, string memory reason) external {
        uint256 disputeId = nextDisputeId++;
        disputes[disputeId] = Dispute(gigId, client, freelancer, reason, DisputeStatus.Open);
        emit DisputeRaised(disputeId, gigId, reason);
    }

    /**
     * @notice Resolves a dispute in favor of the freelancer, releasing the funds.
     * @dev Can only be called by an arbitrator.
     * @param disputeId The ID of the dispute to resolve.
     */
    function resolveDispute(uint256 disputeId) external onlyArbitrator nonReentrant {
        Dispute storage dispute = disputes[disputeId];
        require(dispute.status == DisputeStatus.Open, "Dispute is not open");

        dispute.status = DisputeStatus.Resolved;
        // Logic to release funds to freelancer goes here
        emit DisputeResolved(disputeId);
    }

    /**
     * @notice Refunds the client involved in a dispute, pulling funds from escrow.
     * @dev Can only be called by an arbitrator.
     * @param disputeId The ID of the dispute to refund.
     */
    function refundClient(uint256 disputeId) external onlyArbitrator nonReentrant {
        Dispute storage dispute = disputes[disputeId];
        require(dispute.status == DisputeStatus.Open, "Dispute is not open");

        dispute.status = DisputeStatus.Refunded;
        // Logic to refund client from escrow goes here
        emit FundsRefunded(disputeId);
    }

    // Additional utility functions can be implemented as needed
}

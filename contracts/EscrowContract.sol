// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Escrow Contract for Decentralized Freelancing Platform
 * @dev Manages escrow for payments between clients and freelancers, ensuring funds are securely held until service delivery is confirmed.
 */
contract EscrowContract is Ownable, ReentrancyGuard {
    // Struct to store escrow details
    struct Escrow {
        address payable freelancer;
        address payable client;
        uint256 amount;
        bool isFunded;
        bool isCompleted;
    }

    // Mapping to store escrows with gig IDs as keys
    mapping(uint256 => Escrow) public escrows;

    // Event declarations
    event EscrowCreated(uint256 indexed gigId, address indexed client, address indexed freelancer, uint256 amount);
    event FundsDeposited(uint256 indexed gigId, uint256 amount);
    event EscrowCompleted(uint256 indexed gigId);
    event FundsReleased(uint256 indexed gigId, uint256 amount);
    event RefundIssued(uint256 indexed gigId, uint256 amount);

    /**
     * @notice Creates an escrow for a gig.
     * @param gigId The ID of the gig for which the escrow is created.
     * @param freelancer The address of the freelancer offering the gig.
     * @param client The address of the client hiring the service.
     * @param amount The amount to be held in escrow.
     */
    function createEscrow(uint256 gigId, address payable freelancer, address payable client, uint256 amount) external onlyOwner {
        require(escrows[gigId].amount == 0, "Escrow already exists for this gig");
        escrows[gigId] = Escrow({
            freelancer: freelancer,
            client: client,
            amount: amount,
            isFunded: false,
            isCompleted: false
        });
        emit EscrowCreated(gigId, client, freelancer, amount);
    }

    /**
     * @notice Allows the client to deposit funds into the escrow.
     * @dev Requires that the escrow is not already funded.
     * @param gigId The ID of the gig for which funds are being deposited.
     */
    function depositFunds(uint256 gigId) external payable nonReentrant {
        Escrow storage escrow = escrows[gigId];
        require(msg.sender == escrow.client, "Only the client can deposit funds");
        require(msg.value == escrow.amount, "Deposit must match the escrow amount");
        require(!escrow.isFunded, "Escrow is already funded");

        escrow.isFunded = true;
        emit FundsDeposited(gigId, msg.value);
    }

    /**
     * @notice Completes the escrow, allowing for fund release to the freelancer.
     * @dev Can only be called by the owner (platform administrator) to ensure proper dispute handling.
     * @param gigId The ID of the gig for which the escrow is being completed.
     */
    function completeEscrow(uint256 gigId) external onlyOwner {
        Escrow storage escrow = escrows[gigId];
        require(escrow.isFunded, "Escrow must be funded");
        require(!escrow.isCompleted, "Escrow is already completed");

        escrow.isCompleted = true;
        emit EscrowCompleted(gigId);
    }

    /**
     * @notice Releases the escrowed funds to the freelancer upon job completion.
     * @param gigId The ID of the gig for which funds are being released.
     */
    function releaseFunds(uint256 gigId) external nonReentrant {
        Escrow storage escrow = escrows[gigId];
        require(escrow.isCompleted, "Escrow is not completed");
        uint256 paymentAmount = escrow.amount;
        escrow.amount = 0; // Prevent re-entrancy
        escrow.freelancer.transfer(paymentAmount);
        emit FundsReleased(gigId, paymentAmount);
    }

    /**
     * @notice Issues a refund to the client in case of a dispute or unsatisfactory work.
     * @dev Can only be called by the owner (platform administrator) as part of dispute resolution.
     * @param gigId The ID of the gig for which a refund is being issued.
     */
    function issueRefund(uint256 gigId) external onlyOwner nonReentrant {
        Escrow storage escrow = escrows[gigId];
        require(escrow.isFunded && !escrow.isCompleted, "Invalid state for refund");
        uint256 refundAmount = escrow.amount;
        escrow.amount = 0; // Prevent re-entrancy
        escrow.client.transfer(refundAmount);
        emit RefundIssued(gigId, refundAmount);
    }

    // Additional utility functions can be added here, such as getter functions for escrow details.
}

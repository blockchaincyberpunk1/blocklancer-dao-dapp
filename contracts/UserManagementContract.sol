// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title UserManagement for Decentralized Freelancing Platform
 * @dev Manages user registration, profiles, and roles within the platform.
 * Utilizes OpenZeppelin's Ownable and AccessControl for role management and ownership.
 */
contract UserManagementContract is Ownable, AccessControl {
    // Define roles with unique identifiers
    bytes32 public constant FREELANCER_ROLE = keccak256("FREELANCER_ROLE");
    bytes32 public constant CLIENT_ROLE = keccak256("CLIENT_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // Struct to hold user profile information
    struct UserProfile {
        string username;
        string contactInfo; // Could be an email or ENS domain
        string bio;
    }

    // Mapping from user address to their profile and role
    mapping(address => UserProfile) private profiles;

    /**
     * @dev Initializes the contract by setting deployer as the default admin role.
     */
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @notice Registers a new user with the specified role.
     * @dev Grants a specific role to the user address. Reverts if the role is not recognized.
     * @param user Address of the user to register.
     * @param role Role identifier to be granted to the user.
     * @param username Username for the user's profile.
     * @param contactInfo Contact information for the user's profile.
     * @param bio A short biography or description of the user.
     */
    function registerUser(address user, bytes32 role, string memory username, string memory contactInfo, string memory bio) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(user != address(0), "UserManagementContract: invalid user address");
        require(!hasRole(FREELANCER_ROLE, user) && !hasRole(CLIENT_ROLE, user) && !hasRole(ADMIN_ROLE, user), "UserManagementContract: user already registered");

        // Assign role to the user
        grantRole(role, user);

        // Create and store the user profile
        profiles[user] = UserProfile(username, contactInfo, bio);

        // Emit an event for user registration
        emit UserRegistered(user, role);
    }

    /**
     * @notice Grants a role to a specific user.
     * @dev Overrides the grantRole function to restrict role assignment to the contract owner or admins.
     * @param role The role to be granted.
     * @param account The user account to which the role is granted.
     */
    function grantRole(bytes32 role, address account) public override onlyOwner {
        require(account != address(0), "UserManagementContract: account is the zero address");
        require(role == FREELANCER_ROLE || role == CLIENT_ROLE || role == ADMIN_ROLE, "UserManagementContract: invalid role specified");

        super.grantRole(role, account);
    }

    /**
     * @notice Retrieves the profile of a given user.
     * @param user The address of the user whose profile is being queried.
     * @return The profile information of the user.
     */
    function getUserProfile(address user) public view returns (UserProfile memory) {
        require(user != address(0), "UserManagementContract: invalid user address");
        return profiles[user];
    }

    // Define more functions as needed...

    // Event declarations
    event UserRegistered(address indexed user, bytes32 role);
}

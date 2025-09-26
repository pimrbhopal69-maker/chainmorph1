// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title ChainMorph
 * @dev A smart contract that allows users to morph and evolve digital assets
 * @author ChainMorph Team
 */
contract Project {
    
    // State variables
    mapping(address => uint256) public userAssets;
    mapping(address => uint256) public morphLevel;
    mapping(address => uint256) public lastMorphTime;
    
    uint256 public constant MORPH_COOLDOWN = 24 hours;
    uint256 public constant BASE_MORPH_COST = 100;
    uint256 public totalAssets;
    
    // Events
    event AssetCreated(address indexed user, uint256 amount, uint256 timestamp);
    event AssetMorphed(address indexed user, uint256 newLevel, uint256 cost, uint256 timestamp);
    event AssetsTransferred(address indexed from, address indexed to, uint256 amount, uint256 timestamp);
    
    // Modifiers
    modifier canMorph() {
        require(userAssets[msg.sender] > 0, "No assets to morph");
        require(block.timestamp >= lastMorphTime[msg.sender] + MORPH_COOLDOWN, "Morph cooldown active");
        _;
    }
    
    modifier hasAssets(uint256 amount) {
        require(userAssets[msg.sender] >= amount, "Insufficient assets");
        _;
    }
    
    /**
     * @dev Core Function 1: Create initial digital assets for a user
     * @param amount The amount of assets to create
     */
    function createAsset(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(userAssets[msg.sender] == 0, "Assets already exist for this user");
        
        userAssets[msg.sender] = amount;
        morphLevel[msg.sender] = 1;
        totalAssets += amount;
        
        emit AssetCreated(msg.sender, amount, block.timestamp);
    }
    
    /**
     * @dev Core Function 2: Morph assets to next level with enhanced properties
     * Users can evolve their assets but must pay a cost and wait for cooldown
     */
    function morphAsset() external canMorph {
        uint256 currentLevel = morphLevel[msg.sender];
        uint256 morphCost = BASE_MORPH_COST * currentLevel;
        
        require(userAssets[msg.sender] >= morphCost, "Insufficient assets for morphing");
        
        // Deduct morph cost
        userAssets[msg.sender] -= morphCost;
        totalAssets -= morphCost;
        
        // Increase morph level
        morphLevel[msg.sender]++;
        
        // Add bonus assets based on new level
        uint256 bonus = (currentLevel * 50);
        userAssets[msg.sender] += bonus;
        totalAssets += bonus;
        
        // Update last morph time
        lastMorphTime[msg.sender] = block.timestamp;
        
        emit AssetMorphed(msg.sender, morphLevel[msg.sender], morphCost, block.timestamp);
    }
    
    /**
     * @dev Core Function 3: Transfer assets between users
     * @param to The recipient address
     * @param amount The amount to transfer
     */
    function transferAssets(address to, uint256 amount) external hasAssets(amount) {
        require(to != address(0), "Cannot transfer to zero address");
        require(to != msg.sender, "Cannot transfer to yourself");
        require(amount > 0, "Transfer amount must be greater than 0");
        
        // If recipient has no assets, initialize their morph level
        if (userAssets[to] == 0) {
            morphLevel[to] = 1;
        }
        
        userAssets[msg.sender] -= amount;
        userAssets[to] += amount;
        
        emit AssetsTransferred(msg.sender, to, amount, block.timestamp);
    }
    
    /**
     * @dev Get user's complete asset information
     * @param user The user address to query
     * @return assets The user's current asset balance
     * @return level The user's current morph level
     * @return nextMorphTime When the user can morph again
     */
    function getUserInfo(address user) external view returns (
        uint256 assets, 
        uint256 level, 
        uint256 nextMorphTime
    ) {
        assets = userAssets[user];
        level = morphLevel[user];
        nextMorphTime = lastMorphTime[user] + MORPH_COOLDOWN;
    }
    
    /**
     * @dev Calculate the cost for next morph
     * @param user The user address
     * @return cost The cost required for next morph
     */
    function getMorphCost(address user) external view returns (uint256 cost) {
        if (morphLevel[user] == 0) return 0;
        cost = BASE_MORPH_COST * morphLevel[user];
    }
    
    /**
     * @dev Check if user can morph (cooldown and asset requirements)
     * @param user The user address
     * @return canMorphNow Boolean indicating if user can morph
     */
    function canMorphAsset(address user) external view returns (bool canMorphNow) {
        if (userAssets[user] == 0) return false;
        if (block.timestamp < lastMorphTime[user] + MORPH_COOLDOWN) return false;
        
        uint256 cost = BASE_MORPH_COST * morphLevel[user];
        return userAssets[user] >= cost;
    }
}

# Smart Contract Lottery - My Implementation

A decentralized lottery built with Solidity and Foundry, using Chainlink VRF v2 for provably fair randomness.

*This project was built following the Cyfrin Foundry Solidity Course.*

## ✅ Current Status
- All 16 tests passing
- VRF v2 integration working  
- Mock contracts for local testing
- Ready for testnet deployment
- Chainlink Automation compatible

## Testing

✅ **All Tests Passing: 16/16**

forge test # Local testing
forge test --fork-url $SEPOLIA_RPC_URL # Fork testing


**Test Coverage:**
- Unit tests: ✅ 14 tests
- Staging tests: ✅ 2 tests
- VRF integration: ✅ Working
- Mock contracts: ✅ Working

## Deployment Notes

This project uses **VRF v2** (not v2.5) for broader compatibility with chainlink-brownie-contracts.

**Key Differences from Course:**
- Uses `uint64` subscription IDs (VRF v2)
- Updated remappings for chainlink-brownie-contracts
- Fixed constructor parameters for VRFCoordinatorV2Mock


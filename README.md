# 🧩 Solver Protocol Project

A decentralized problem-solving platform where users can submit challenges, provide solutions, and earn rewards through a reputation-based system built on the Stacks blockchain.

## 🌟 Features

- **🎯 Problem Submission**: Post challenges with STX rewards and deadlines
- **💡 Solution Marketplace**: Submit innovative solutions to earn rewards
- **🗳️ Community Voting**: Vote on solution quality and effectiveness
- **🏆 Reputation System**: Build credibility through successful problem-solving
- **💰 STX Rewards**: Earn cryptocurrency for accepted solutions
- **⏰ Deadline Management**: Time-bound problem solving with automatic closure
- **📊 Analytics Dashboard**: Track performance metrics and platform statistics
- **🏷️ Category System**: Organize problems by domain expertise

## 🔧 Smart Contract Overview

The `solver-protocol.clar` contract enables:

### Core Functions

#### 🎯 Problem Creation
```clarity
(create-problem title description deadline-blocks category)
```
Create a new problem with STX reward stake and specified deadline.

#### 💡 Solution Submission
```clarity
(submit-solution problem-id description)
```
Submit detailed solutions to active problems.

#### 🗳️ Solution Voting
```clarity
(vote-solution solution-id weight)
```
Vote on solution quality with weighted scoring.

#### ✅ Solution Acceptance
```clarity
(accept-solution problem-id solution-id)
```
Problem creators can accept the best solution.

#### 💰 Reward Claims
```clarity
(claim-reward solution-id)
```
Successful solvers claim their STX rewards.

### 📊 Read-Only Functions

- `get-problem` - Retrieve problem details and status
- `get-solution` - View solution information and votes
- `get-solver-profile` - Check user reputation and statistics
- `get-platform-stats` - Platform-wide metrics
- `get-category-info` - Category statistics and activity

### 🔐 Admin Functions

- `update-platform-settings` - Modify fees, rewards, and reputation settings
- `close-problem` - Handle expired or solved problems

## 🎯 Platform Mechanics

### Problem Lifecycle
```
🎯 Problem Created → 💡 Solutions Submitted → 🗳️ Community Voting → 
  ↓
✅ Solution Accepted → 💰 Reward Claimed
  OR
⏰ Deadline Reached → 🔒 Problem Closed → 💸 Refund Creator
```

### 🏆 Reputation System
- **🎯 Problem Creation**: Base reputation for platform participation
- **💡 Solution Submission**: +10 reputation points
- **✅ Accepted Solution**: +50 reputation bonus (configurable)
- **🗳️ Community Voting**: Contributes to solution scoring

### 💳 Economics
- **Platform Fee**: 2% (200/10000) of problem rewards
- **Minimum Reward**: 100,000 microSTX (configurable)
- **Fee Distribution**: Platform fees go to contract owner
- **Reward Security**: Funds held in contract until solution accepted

## 🛠️ Installation & Setup

### Prerequisites
- Node.js (v16+)
- Clarinet CLI
- Stacks Wallet

### Quick Start

1. **Clone the repository**
```bash
git clone https://github.com/your-username/Solver-Protocol-Project.git
cd Solver-Protocol-Project
```

2. **Install dependencies**
```bash
npm install
```

3. **Check contract syntax**
```bash
clarinet check
```

4. **Run tests**
```bash
npm test
```

5. **Deploy to devnet**
```bash
clarinet integrate
```

## 📈 Usage Examples

### Creating a Problem
```typescript
// Example: Create a smart contract optimization challenge
const title = "Optimize Gas Usage in DeFi Contract";
const description = "Need to reduce transaction costs by 30% while maintaining functionality";
const deadlineBlocks = 50000; // ~35 days
const category = "blockchain";

await contractCall({
  contractAddress: "ST1234...",
  contractName: "solver-protocol",
  functionName: "create-problem",
  functionArgs: [title, description, deadlineBlocks, category],
  postConditionMode: PostConditionMode.Allow,
  postConditions: []
});
```

### Submitting a Solution
```typescript
// Submit solution to problem #0
const solutionDescription = "Implemented batch processing and storage optimization. Results: 35% gas reduction, maintained all functionality, added unit tests.";

await contractCall({
  contractAddress: "ST1234...",
  contractName: "solver-protocol",
  functionName: "submit-solution",
  functionArgs: [0, solutionDescription] // problem-id: 0
});
```

### Voting on Solutions
```typescript
// Vote on solution quality (weight 1-10)
await contractCall({
  contractAddress: "ST1234...",
  contractName: "solver-protocol",
  functionName: "vote-solution",
  functionArgs: [0, 8] // solution-id: 0, weight: 8
});
```

### Accepting Solutions
```typescript
// Problem creator accepts best solution
await contractCall({
  contractAddress: "ST1234...",
  contractName: "solver-protocol",
  functionName: "accept-solution",
  functionArgs: [0, 0] // problem-id: 0, solution-id: 0
});
```

## 🎨 Problem Categories

The platform supports various problem domains:
- 🔬 **Research & Science**
- 💻 **Software Development**
- 🔗 **Blockchain & Web3**
- 🎨 **Design & UX**
- 📊 **Data Analysis**
- 🏗️ **Engineering**
- 💡 **Innovation & Ideation**
- 🧮 **Mathematics**

## 📊 Platform Statistics

Track ecosystem health:
- Total problems created
- Active solution submissions
- Community voting participation
- Solver reputation distribution
- Category-wise problem breakdown
- Average reward amounts
- Solution acceptance rates

## 🔒 Security Features

- **Escrow System**: Rewards held securely until solution acceptance
- **Deadline Enforcement**: Automatic problem closure and refunds
- **Access Control**: Creator-only solution acceptance
- **Vote Integrity**: One vote per user per solution
- **Reputation Tracking**: Persistent solver credibility scores
- **Fee Protection**: Platform sustainability through minimal fees

## 🚀 Advanced Features

### Multi-Stage Problems
Complex challenges can be broken into phases with incremental rewards.

### Collaborative Solutions
Multiple solvers can contribute to comprehensive solutions.

### Expert Validation
High-reputation solvers can provide additional solution verification.

### Bounty Multipliers
Urgent problems can offer bonus rewards for faster resolution.

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines

- Follow Clarity best practices
- Add comprehensive tests for new features
- Update documentation for API changes
- Maintain backwards compatibility when possible

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support & Resources

- 📖 [Clarity Documentation](https://docs.stacks.co/clarity)
- 🛠️ [Clarinet Documentation](https://docs.hiro.so/clarinet)
- 💬 [Stacks Discord](https://discord.gg/stacks)
- 🐦 [Twitter Updates](https://twitter.com/stacks)
- 📧 [Email Support](mailto:support@solver-protocol.com)

## 🔮 Roadmap

- **Q1 2024**: Enhanced voting mechanisms
- **Q2 2024**: Mobile app integration
- **Q3 2024**: Cross-chain problem solving
- **Q4 2024**: AI-assisted solution matching

## 🎉 Acknowledgments

- Stacks Foundation for blockchain infrastructure
- Clarity language development team
- Open source community contributors
- Beta testers and early adopters
- Problem solvers making the world better

---

**Solve problems, earn rewards, build reputation** 🧩💪

**Powered by Stacks blockchain** 🔗⚡

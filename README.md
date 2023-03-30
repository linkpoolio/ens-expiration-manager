# ENS Expiration Manager (Chainlink Automation)

## I. About

The ENS Expiration Manager is a smart contract that allows users to manage the expiration of their ENS domains.

## II. Pre-requisites

### 1. Clone repo

```bash
$ git clone git@github.com:linkpoolio/ens-expiration-manager.git
```

### 2. Create etherscan API key

- [Create Account](https://docs.etherscan.io/getting-started/creating-an-account)
- [Create API Key](https://docs.etherscan.io/getting-started/viewing-api-usage-statistics)

### 3. Setup contracts environment variables

```bash

# Network RPCs
export RPC_URL=

# Mainnet RPC
export MAINNET_RPC_URL=

# Private key for contract deployment
export PRIVATE_KEY=

# Explorer API key used to verify contracts
export EXPLORER_KEY=

# From anvil
export LOCAL_RPC_URL="http://localhost:8545"
export ANVIL_PRIVATE_KEY="" # Get from anvil after running for the first time, see below

# UI
export UI_ENS_EXPIRATION_MANAGER_CONTRACT_ADDRESS=
export UI_ENS_BASE_REGISTRAR_CONTRACT_ADDRESS=
```

### 4. Setup Wallet

Install any wallet to your browser (currently supports Metamask)

## III. Local Setup

## Option 1: Docker

### 1. Start docker

```bash
# <root>
$ docker compose up
```

### 2. View UI

- Open browser at [localhost:3005](localhost:3005)

## Option 2: Manual Setup

### 1. Setup Foundry

[Installation instructions](https://book.getfoundry.sh/getting-started/installation)

```bash
# Download foundry
$ curl -L https://foundry.paradigm.xyz | bash

# Install foundry
$ foundryup

# (Mac only) Install anvil (prereq: Homebrew)
$ brew install libusb
```

### 2. Install contract dependencies if changes have been made to contracts

```bash
# <root>/contracts
$ make install
```

### 3. Run anvil

```bash
# <root>/contracts (run in new terminal window)
$ anvil
```

### 4. Deploy contract

Note: each time anvil is restarted, the contract will need to be re-deployed but will have the same contract address assuming no contract changes

```bash
# <root>/contracts

# If deploying locally
$ make deploy-local

# Or if deploying to public network, set RPC_URL to desired network:
$ make deploy
```

### 5. Install UI dependencies

```bash
# <root>/client
$ nvm use
$ yarn
```

### 6. Run UI

```bash
# <root>/client/packages/ui
$ yarn start
```

### 7. View UI

- Open browser at [localhost:3005](localhost:3005)

## IV. Testing

### 1. Test Contracts

```bash
# <root>/contracts
make test-contracts-all
```

### 2. Test UI

```bash
# <root>/client/packages/ui
$ yarn test
$ yarn tsc
$ yarn lint
$ yarn prettier
```

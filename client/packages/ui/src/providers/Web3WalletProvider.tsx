import React from 'react'
import { WagmiConfig, createClient, configureChains } from 'wagmi'
import { InjectedConnector } from 'wagmi/connectors/injected'
import { jsonRpcProvider } from 'wagmi/providers/jsonRpc'
import { mainnet, localhost, hardhat, goerli, sepolia } from 'wagmi/chains'

const DEFAULT_CHAIN_ID = goerli.id

export const CHAINS = [
  {
    ...mainnet,
    rpcUrls: {
      public: {
        http: ['https://cloudflare-eth.com']
      },
      default: {
        http: ['https://cloudflare-eth.com']
      }
    }
  },
  {
    ...localhost,
    rpcUrls: {
      public: {
        http: ['https://staking-metrics-monitor-alpha.staging.linkpool.io/dev']
      },
      default: {
        http: ['https://staking-metrics-monitor-alpha.staging.linkpool.io/dev']
      }
    }
  },
  {
    ...sepolia,
    rpcUrls: {
      public: {
        http: ['https://ethereum-sepolia-rpc.allthatnode.com']
      },
      default: {
        http: ['https://ethereum-sepolia-rpc.allthatnode.com']
      }
    }
  },
  {
    ...goerli,
    rpcUrls: {
      public: {
        http: ['https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161']
      },
      default: {
        http: ['https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161']
      }
    }
  },
  hardhat
]

const { chains, provider } = configureChains(
  CHAINS.sort((chain) => {
    return chain.id === DEFAULT_CHAIN_ID ? -1 : 1
  }),
  [
    jsonRpcProvider({
      priority: 1,
      rpc: (chain) => {
        return {
          http: chain.rpcUrls.default.http[0],
          webSocket: chain.rpcUrls.default.webSocket?.[0]
        }
      }
    }),
    jsonRpcProvider({
      rpc: (chain) => {
        if (chain.id !== 1) return null
        return { http: 'https://rpc.flashbots.net/' }
      }
    }),
    jsonRpcProvider({
      rpc: (chain) => {
        if (chain.id !== 1) return null
        return {
          http: 'https://api.mycryptoapi.com/eth'
        }
      }
    })
  ],
  { targetQuorum: 1 }
)

const connectors = () => {
  const list = [
    new InjectedConnector({
      chains
    })
  ]
  return list
}

export const client = createClient({
  autoConnect: true,
  connectors,
  provider
})

export const Web3WalletProvider = ({ children }) => (
  <WagmiConfig client={client}>{children}</WagmiConfig>
)

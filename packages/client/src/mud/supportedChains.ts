import { MUDChain, latticeTestnet, mudFoundry } from "@latticexyz/common/chains"

export const redstoneGarnet = {
  id: 17069,
  name: "Redstone Garnet Testnet",
  nativeCurrency: {
    decimals: 18,
    name: "Holesky Ether",
    symbol: "ETH",
  },
  rpcUrls: {
    default: {
      http: ["https://rpc.garnet.qry.live"],
      webSocket: ["https://rpc.garnet.qry.live"],
    },
    public: {
      http: ["https://rpc.garnet.qry.live"],
      webSocket: ["https://rpc.garnet.qry.live"],
    },
  },
  blockExplorers: {
    default: {
      name: "Blockscout",
      url: "https://explorer.garnet.qry.live",
    },
  },
} as const satisfies MUDChain

/*
 * See https://mud.dev/tutorials/minimal/deploy#run-the-user-interface
 * for instructions on how to add networks.
 *
 * - mudFoundry, the chain running on anvil that pnpm dev
 *   starts by default. It is similar to the viem anvil chain
 *   (see https://viem.sh/docs/clients/test.html), but with the
 *   base fee set to zero to avoid transaction fees.
 */
export const supportedChains: MUDChain[] = [mudFoundry, redstoneGarnet, latticeTestnet]

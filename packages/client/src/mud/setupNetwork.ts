/*
 * The MUD client code is built on top of viem
 * (https://viem.sh/docs/getting-started.html).
 * This line imports the functions we need from it.
 */
import { Subject, share } from "rxjs"
import {
  ClientConfig,
  Hex,
  createPublicClient,
  createWalletClient,
  fallback,
  getContract,
  http,
  parseEther,
  webSocket,
} from "viem"

import { ContractWrite, createBurnerAccount, transportObserver } from "@latticexyz/common"
import { transactionQueue, writeObserver } from "@latticexyz/common/actions"
import { createFaucetService } from "@latticexyz/services/faucet"
import { encodeEntity, syncToRecs } from "@latticexyz/store-sync/recs"

/*
 * Import our MUD config, which includes strong types for
 * our tables and other config options. We use this to generate
 * things like RECS components and get back strong types for them.
 *
 * See https://mud.dev/templates/typescript/contracts#mudconfigts
 * for the source of this information.
 */
import mudConfig from "contracts/mud.config"
import IWorldAbi from "contracts/out/IWorld.sol/IWorld.abi.json"

import { createClock } from "./createClock"
import { getNetworkConfig } from "./getNetworkConfig"
import { createWaitForTransaction } from "./waitForTransaction"
import { world } from "./world"

export type SetupNetworkResult = Awaited<ReturnType<typeof setupNetwork>>

export async function setupNetwork() {
  const networkConfig = await getNetworkConfig()

  /*
   * Create a viem public (read only) client
   * (https://viem.sh/docs/clients/public.html)
   */
  const clientOptions = {
    chain: networkConfig.chain,
    transport: transportObserver(fallback([webSocket(), http()], { retryCount: 0 })),
    pollingInterval: 250,
  } as const satisfies ClientConfig

  const publicClient = createPublicClient(clientOptions)

  /*
   * Create an observable for contract writes that we can
   * pass into MUD dev tools for transaction observability.
   */
  const write$ = new Subject<ContractWrite>()

  /*
   * Create a temporary wallet and a viem client for it
   * (see https://viem.sh/docs/clients/wallet.html).
   */
  const burnerAccount = createBurnerAccount(networkConfig.privateKey as Hex)
  const burnerWalletClient = createWalletClient({
    ...clientOptions,
    account: burnerAccount,
  })
    // Add simulation, nonce management and transaction queueing for sendTransaction and writeContract actions
    .extend(transactionQueue())
    // Add an observer to capture writeContract action
    .extend(writeObserver({ onWrite: (write) => write$.next(write) }))

  /*
   * Create an object for communicating with the deployed World.
   */
  const worldContract = getContract({
    address: networkConfig.worldAddress as Hex,
    abi: IWorldAbi,
    client: { public: publicClient, wallet: burnerWalletClient },
  })

  /*
   * Sync on-chain state into RECS and keeps our client in sync.
   * Uses the MUD indexer if available, otherwise falls back
   * to the viem publicClient to make RPC calls to fetch MUD
   * events from the chain.
   */
  const { components, latestBlock$, storedBlockLogs$ } = await syncToRecs({
    world,
    config: mudConfig,
    address: networkConfig.worldAddress as Hex,
    publicClient,
    startBlock: BigInt(networkConfig.initialBlockNumber),
  })

  const clock = createClock(networkConfig.clock)
  world.registerDisposer(() => clock.dispose())

  const txReceiptClient = createPublicClient({
    ...clientOptions,
    transport: http(),
    pollingInterval: 250,
  })

  const waitForTransaction = createWaitForTransaction({
    storedBlockLogs$,
    client: txReceiptClient,
  })

  /*
   * If there is a faucet, request (test) ETH if you have
   * less than 1 ETH. Repeat every 20 seconds to ensure you don't
   * run out.
   */
  if (networkConfig.faucetServiceUrl) {
    const address = burnerAccount.address
    console.info("[Dev Faucet]: Player address -> ", address)

    const faucet = createFaucetService(networkConfig.faucetServiceUrl)

    const requestDrip = async () => {
      const balance = await publicClient.getBalance({ address })
      console.info(`[Dev Faucet]: Player balance -> ${balance}`)
      const lowBalance = balance < parseEther("1")
      if (lowBalance) {
        console.info("[Dev Faucet]: Balance is low, dripping funds to player")
        // Double drip
        await faucet.dripDev({ address })
        await faucet.dripDev({ address })
      }
    }

    requestDrip()
    // Request a drip every 20 seconds
    setInterval(requestDrip, 20000)
  }

  return {
    world,
    components,
    playerEntity: encodeEntity({ address: "address" }, { address: burnerWalletClient.account.address }),
    publicClient,
    walletClient: burnerWalletClient,
    latestBlock$,
    storedBlockLogs$,
    waitForTransaction,
    worldContract,
    write$: write$.asObservable().pipe(share()),
  }
}

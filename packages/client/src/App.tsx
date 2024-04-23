import { RainbowKitProvider, getDefaultConfig } from "@rainbow-me/rainbowkit"
import { QueryClient, QueryClientProvider } from "@tanstack/react-query"
import { useMemo } from "react"
import { RouterProvider } from "react-router-dom"
import { WagmiProvider, http } from "wagmi"

import { getNetworkConfig } from "./mud/getNetworkConfig"
import { router } from "./router"

export const queryClient = new QueryClient()

export const App = () => {
  const networkConfig = useMemo(() => getNetworkConfig(), [])

  const wagmiConfig = useMemo(
    () =>
      getDefaultConfig({
        appName: "Stratego",
        projectId: "", // TODO: from WalletConnect Cloud
        chains: [networkConfig.chain],
        transports: {
          [networkConfig.chain.id]: http(),
        },
      }),
    [networkConfig],
  )

  return (
    <WagmiProvider config={wagmiConfig}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider>
          <RouterProvider router={router} />
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  )
}

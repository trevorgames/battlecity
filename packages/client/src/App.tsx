import { useComponentValue } from "@latticexyz/react"
import { singletonEntity } from "@latticexyz/store-sync/recs"

import { useMUD } from "./MUDContext"

export const App = () => {
  const {
    components: { Counter },
    systemCalls: { increment },
  } = useMUD()

  const counter = useComponentValue(Counter, singletonEntity)

  return (
    <>
      <div>
        Counter: <span>{counter?.value ?? "??"}</span>
      </div>
      <button
        type="button"
        onClick={async (event) => {
          event.preventDefault()
          console.log("new counter value:", await increment())
        }}
      >
        Increment
      </button>
    </>
  )
}

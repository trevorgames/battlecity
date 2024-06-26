import { Observable, ReplaySubject } from "rxjs"

export interface ClockConfig {
  period: number
  initialTime: number
  syncInterval: number
}

export type Clock = {
  time$: Observable<number>
  currentTime: number
  lastUpdateTime: number
  update: (time: number, maintainStale?: boolean) => void
  dispose: () => void
}

/**
 * Create a clock optimistically keeping track of the current chain time.
 * The optimistic chain time should be synced to the actual chain time in regular intervals using the `update` function.
 *
 * @param config
 * @returns Clock
 */
export function createClock(config: ClockConfig): Clock {
  const { initialTime, period } = config

  const clock = {
    currentTime: initialTime,
    lastUpdateTime: initialTime,
    time$: new ReplaySubject<number>(1),
    dispose: () => clearInterval(intervalId),
    update,
  }

  let intervalId = createTickInterval()
  emit()

  function emit() {
    clock.time$.next(clock.currentTime)
  }

  function createTickInterval() {
    return setInterval(() => {
      clock.currentTime += period
      emit()
    }, period)
  }

  function update(time: number) {
    clearInterval(intervalId)
    clock.currentTime = time
    clock.lastUpdateTime = time
    emit()
    intervalId = createTickInterval()
  }

  return clock
}

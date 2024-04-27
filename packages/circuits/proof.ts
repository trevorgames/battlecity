// @ts-ignore
import * as snarkjs from "snarkjs"
import JSZip from "jszip"

export declare type FullProof = {
  proof: Record<string, any>;
  publicSignals: string[];
};

export type Circuit = "Setup" | "Move" | "Attack" | "Defense"

export class ProofGenerator {
  wasm: Partial<Record<Circuit, Uint8Array>> = {}
  zkey: Partial<Record<Circuit, Uint8Array>> = {}

  async load(circuit: Circuit, wasmData: string, zkeyData: string) {
    if (this.wasm[circuit] && this.zkey[circuit]) {
      return
    }

    let zip = new JSZip()
    this.wasm[circuit] = await (await zip.loadAsync(wasmData)).file(circuit + ".wasm")!.async("uint8array")

    zip = new JSZip()
    this.zkey[circuit] = await (await zip.loadAsync(zkeyData)).file(circuit + ".zkey")!.async("uint8array")
  }

  async generateSetupProof(
    arrangement: bigint[]
  ) {
    return <FullProof>await snarkjs.groth16.fullProve({ arrangement }, {
      type: "mem",
      data: this.wasm["Setup"]
    }, { type: "mem", data: this.zkey["Setup"] })
  }

  async generateMoveProof(
    lastArrangement: bigint[],
    lastArrangementHash: bigint,
    lastX: bigint,
    lastY: bigint,
    x: bigint,
    y: bigint
  ) {
    return <FullProof>await snarkjs.groth16.fullProve({
      lastArrangement,
      lastArrangementHash,
      lastX,
      lastY,
      x,
      y
    }, { type: "mem", data: this.wasm["Move"] }, { type: "mem", data: this.zkey["Move"] })
  }

  async generateAttackProof(
    lastArrangement: bigint[],
    lastArrangementHash: bigint,
    lastX: bigint,
    lastY: bigint,
    x: bigint,
    y: bigint
  ) {
    return <FullProof>await snarkjs.groth16.fullProve({
      lastArrangement,
      lastArrangementHash,
      lastX,
      lastY,
      x,
      y
    }, { type: "mem", data: this.wasm["Attack"] }, { type: "mem", data: this.zkey["Attack"] })
  }

  async generateDefenseProof(
    lastArrangement: bigint[],
    lastArrangementHash: bigint,
    x: bigint,
    y: bigint,
    attackerPieceCode: bigint
  ) {
    return <FullProof>await snarkjs.groth16.fullProve({
      lastArrangement,
      lastArrangementHash,
      x,
      y,
      attackerPieceCode
    }, { type: "mem", data: this.wasm["Defense"] }, { type: "mem", data: this.zkey["Defense"] })
  }
}

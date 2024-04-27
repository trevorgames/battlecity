import { execSync } from "child_process"
import { exit } from "process"
// @ts-ignore
import * as snarkjs from "snarkjs"
// @ts-ignore
import * as ffjavascript from "ffjavascript"
import fs from "fs"
import path from "path"
import JSZip from "jszip"

export function titleCase(s: string) {
  return !s ? "" : s[0].toUpperCase() + s.slice(1)
}

export async function compile_circom(filename: string, options: any) {
  let flags = "--wasm "
  if (options.sym) flags += "--sym "
  if (options.r1cs) flags += "--r1cs "
  if (options.json) flags += "--json "
  if (options.output) flags += "--output " + options.output + " "
  if (options.O === 0) flags += "--O0 "		// No simplification is applied
  if (options.O === 1) flags += "--O1 "		// Only applies signal to signal and signal to constant simplification
  if (options.O === 2) flags += "--O2 "		// Full constraint simplification
  try {
    execSync("circom " + flags + filename)
    console.log(`Compiled ${filename}`)
  } catch (error) {
    console.error(error)
    exit(-1)
  }
}

export type Curve = any;
export type Key = { type: string, data: Uint8Array };

export async function generate_zkey_final_key(
  curve: Curve,
  ptau_final: Key,
  r1cs_file: string,
  final_zkey_file: string
) {
  const zkey_0 = { type: "mem" }
  const zkey_1 = { type: "mem" }
  const zkey_2 = { type: "mem" }
  const bellman_1 = { type: "mem" }
  const bellman_2 = { type: "mem" }
  const zkey_final: any = { type: "mem", data: undefined }

  console.log(new Date().toUTCString() + " zkey start...")

  await snarkjs.zKey.newZKey(r1cs_file, ptau_final, zkey_0, console)
  await snarkjs.zKey.contribute(zkey_0, zkey_1, "p2_C1", "pa_Entropy1")
  await snarkjs.zKey.exportBellman(zkey_1, bellman_1)
  await snarkjs.zKey.bellmanContribute(curve, bellman_1, bellman_2, "pa_Entropy2")
  await snarkjs.zKey.importBellman(zkey_1, bellman_2, zkey_2, "C2")
  await snarkjs.zKey.beacon(zkey_2, zkey_final, "B3", "0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20", 10)
  await snarkjs.zKey.verifyFromR1cs(r1cs_file, ptau_final, zkey_final)
  await snarkjs.zKey.verifyFromInit(zkey_0, ptau_final, zkey_final)

  await fs.promises.writeFile(final_zkey_file, Buffer.from(zkey_final.data))

  console.log(new Date().toUTCString() + " zkey generated")
}

const packageDir = path.dirname(__dirname)
const circuitsDir = path.join(packageDir, "circuits")
const srcDir = path.join(packageDir, "src")
const buildDir = path.join(packageDir, "build")
const outDir = path.join(packageDir, "out")

const ptauURL = "https://pse-trusted-setup-ppot.s3.eu-central-1.amazonaws.com/pot28_0080/ppot_0080_14.ptau"
const ptauFilename = ptauURL.split("/").pop() as string
const ptauFilepath = path.join(buildDir, ptauFilename)

export async function download_ptau() {
  if (!fs.existsSync(ptauFilepath)) {
    console.log(`Downloading ${ptauFilename} ...`)
    try {
      execSync(`curl -o ${ptauFilepath} ${ptauURL}`)
      console.log(`Downloaded ${ptauFilename}`)
    } catch (error) {
      console.error(error)
      exit(-1)
    }
  }
}

async function fileExists(file: string) {
  return fs.promises.access(file, fs.constants.F_OK)
    .then(() => true)
    .catch(() => false)
}

export async function build_circuit(circuit_name: string) {
  const templates: any = {}

  const templatesDir = path.join(packageDir, "node_modules/snarkjs/templates")
  if (await fileExists(templatesDir)) {
    templates.groth16 = await fs.promises.readFile(path.join(templatesDir, "verifier_groth16.sol.ejs"), "utf8")
    templates.plonk = await fs.promises.readFile(path.join(templatesDir, "verifier_plonk.sol.ejs"), "utf8")
    templates.fflonk = await fs.promises.readFile(path.join(templatesDir, "verifier_fflonk.sol.ejs"), "utf8")
  }

  await fs.promises.mkdir(buildDir, { recursive: true })

  await compile_circom(path.join(circuitsDir, circuit_name + ".circom"), {
    sym: true,
    r1cs: true,
    json: true,
    O: 2,
    output: buildDir
  })
  const r1cs_file = path.join(buildDir, circuit_name + ".r1cs")

  await download_ptau()

  const final_zkey_file = path.join(buildDir, circuit_name + ".zkey")
  const curve = await ffjavascript.getCurveFromName("bn128")
  const ptau_final = { type: "mem", data: new Uint8Array(await fs.promises.readFile(ptauFilepath)) }

  await generate_zkey_final_key(curve, ptau_final, r1cs_file, final_zkey_file)

  let verifierCode: string = await snarkjs.zKey.exportSolidityVerifier(
    new Uint8Array(await fs.promises.readFile(final_zkey_file)),
    templates
  )
  verifierCode = verifierCode.replace("Verifier", titleCase(circuit_name) + "Verifier")
  verifierCode = verifierCode.replace(new RegExp("Pairing", "g"), titleCase(circuit_name) + "Pairing")

  await fs.promises.writeFile(path.join(srcDir, circuit_name + "Verifier.sol"), verifierCode, "utf-8")

  await fs.promises.mkdir(outDir, { recursive: true })

  let zip = new JSZip()
  zip.file(circuit_name + ".wasm", await fs.promises.readFile(path.join(buildDir, circuit_name + "_js", circuit_name + ".wasm")))
  await fs.promises.writeFile(path.join(outDir, circuit_name + ".wasm" + ".zip"), await zip.generateAsync({
    type: "uint8array",
    compression: "DEFLATE",
    compressionOptions: {
      level: 9
    }
  }))

  zip = new JSZip()
  zip.file(circuit_name + ".zkey", await fs.promises.readFile(final_zkey_file))
  await fs.promises.writeFile(path.join(outDir, circuit_name + ".zkey" + ".zip"), await zip.generateAsync({
    type: "uint8array",
    compression: "DEFLATE",
    compressionOptions: {
      level: 9
    }
  }))
}

async function main() {
  const circuits = ["Setup", "Move", "Attack", "Defense"]
  for (const circuit of circuits) {
    await build_circuit(circuit)
  }
}

main().then(() => {
  exit()
})

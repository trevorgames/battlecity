// SPDX-License-Identifier: GPL-3.0
/*
    Copyright 2021 0KIMS association.

    This file is generated with [snarkJS](https://github.com/iden3/snarkjs).

    snarkJS is a free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    snarkJS is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
    License for more details.

    You should have received a copy of the GNU General Public License
    along with snarkJS. If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity >=0.7.0 <0.9.0;

contract Groth16SetupVerifier {
    // Scalar field size
    uint256 constant r    = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    // Base field size
    uint256 constant q   = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Verification Key data
    uint256 constant alphax  = 16428432848801857252194528405604668803277877773566238944394625302971855135431;
    uint256 constant alphay  = 16846502678714586896801519656441059708016666274385668027902869494772365009666;
    uint256 constant betax1  = 3182164110458002340215786955198810119980427837186618912744689678939861918171;
    uint256 constant betax2  = 16348171800823588416173124589066524623406261996681292662100840445103873053252;
    uint256 constant betay1  = 4920802715848186258981584729175884379674325733638798907835771393452862684714;
    uint256 constant betay2  = 19687132236965066906216944365591810874384658708175106803089633851114028275753;
    uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 constant deltax1 = 12137276952162648206077216410797971585171040323637023630447710665685089501382;
    uint256 constant deltax2 = 5247315244512923764609473365443846113060295945586171777272942442578016299205;
    uint256 constant deltay1 = 12462450183686616922408475491233331415184239202124943412298755324616487964116;
    uint256 constant deltay2 = 3229062147350380438019679138722162781593816232064128256795883779548211229714;

    
    uint256 constant IC0x = 3096719090628625503980449242626548256237498016497460656144673269172627589095;
    uint256 constant IC0y = 14961251623914137140243068177295868001630160188605734605368940270478191169595;
    
    uint256 constant IC1x = 20288816403800970973967646077144376784470970820576288780191607127530168715913;
    uint256 constant IC1y = 10870302926368248032267548282265209695216386014845818713001858531811611848702;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pSetupPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[1] calldata _pubSignals) public view returns (bool) {
        assembly {
            function checkField(v) {
                if iszero(lt(v, r)) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }
            
            // G1 function to multiply a G1 value(x,y) to value in an address
            function g1_mulAccC(pR, x, y, s) {
                let success
                let mIn := mload(0x40)
                mstore(mIn, x)
                mstore(add(mIn, 32), y)
                mstore(add(mIn, 64), s)

                success := staticcall(sub(gas(), 2000), 7, mIn, 96, mIn, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }

                mstore(add(mIn, 64), mload(pR))
                mstore(add(mIn, 96), mload(add(pR, 32)))

                success := staticcall(sub(gas(), 2000), 6, mIn, 128, pR, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            function checkSetupPairing(pA, pB, pC, pubSignals, pMem) -> isOk {
                let _pSetupPairing := add(pMem, pSetupPairing)
                let _pVk := add(pMem, pVk)

                mstore(_pVk, IC0x)
                mstore(add(_pVk, 32), IC0y)

                // Compute the linear combination vk_x
                
                g1_mulAccC(_pVk, IC1x, IC1y, calldataload(add(pubSignals, 0)))
                

                // -A
                mstore(_pSetupPairing, calldataload(pA))
                mstore(add(_pSetupPairing, 32), mod(sub(q, calldataload(add(pA, 32))), q))

                // B
                mstore(add(_pSetupPairing, 64), calldataload(pB))
                mstore(add(_pSetupPairing, 96), calldataload(add(pB, 32)))
                mstore(add(_pSetupPairing, 128), calldataload(add(pB, 64)))
                mstore(add(_pSetupPairing, 160), calldataload(add(pB, 96)))

                // alpha1
                mstore(add(_pSetupPairing, 192), alphax)
                mstore(add(_pSetupPairing, 224), alphay)

                // beta2
                mstore(add(_pSetupPairing, 256), betax1)
                mstore(add(_pSetupPairing, 288), betax2)
                mstore(add(_pSetupPairing, 320), betay1)
                mstore(add(_pSetupPairing, 352), betay2)

                // vk_x
                mstore(add(_pSetupPairing, 384), mload(add(pMem, pVk)))
                mstore(add(_pSetupPairing, 416), mload(add(pMem, add(pVk, 32))))


                // gamma2
                mstore(add(_pSetupPairing, 448), gammax1)
                mstore(add(_pSetupPairing, 480), gammax2)
                mstore(add(_pSetupPairing, 512), gammay1)
                mstore(add(_pSetupPairing, 544), gammay2)

                // C
                mstore(add(_pSetupPairing, 576), calldataload(pC))
                mstore(add(_pSetupPairing, 608), calldataload(add(pC, 32)))

                // delta2
                mstore(add(_pSetupPairing, 640), deltax1)
                mstore(add(_pSetupPairing, 672), deltax2)
                mstore(add(_pSetupPairing, 704), deltay1)
                mstore(add(_pSetupPairing, 736), deltay2)


                let success := staticcall(sub(gas(), 2000), 8, _pSetupPairing, 768, _pSetupPairing, 0x20)

                isOk := and(success, mload(_pSetupPairing))
            }

            let pMem := mload(0x40)
            mstore(0x40, add(pMem, pLastMem))

            // Validate that all evaluations ∈ F
            
            checkField(calldataload(add(_pubSignals, 0)))
            
            checkField(calldataload(add(_pubSignals, 32)))
            

            // Validate all evaluations
            let isValid := checkSetupPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }

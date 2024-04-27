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

contract Groth16DefenseVerifier {
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
    uint256 constant deltax1 = 5776865294457692252455322602246473409201768562705407460077119280191907402367;
    uint256 constant deltax2 = 12971042357123908331305212752322952674515166497574330662607517351966541186804;
    uint256 constant deltay1 = 20725773067867416355574180352166509705926778544794943536087030181590325803321;
    uint256 constant deltay2 = 21215047375901232727481304290500136102236609516338916781491231026803642256046;

    
    uint256 constant IC0x = 11206988695881208461831924332091133676066923599360840206800208086096174510312;
    uint256 constant IC0y = 10698895493306595339651397714580346155417176153048189834928477953325314513798;
    
    uint256 constant IC1x = 3773796327209362068735811770309508636140911510070019192611008080045418443590;
    uint256 constant IC1y = 10063209096258903303910710046710787962839599958455876876407715406224996905160;
    
    uint256 constant IC2x = 21110360945103503237306213718749255945409778017816890164015474444838498869888;
    uint256 constant IC2y = 15670111126935640821302022389842070210058505270101047400028485262496799988487;
    
    uint256 constant IC3x = 8418905938597869884091341904285099643263394496160342818450637481540063703706;
    uint256 constant IC3y = 10885478201479408845763822846922836788127862535623058036300354544043600434763;
    
    uint256 constant IC4x = 13060226511240608711782571379949840208596470151153399297059020352890080151690;
    uint256 constant IC4y = 5381724269910543835785581222666896143997692283471904341074863537894208964773;
    
    uint256 constant IC5x = 7831646551866108718607727777597564480639559088969964791177887275085632235194;
    uint256 constant IC5y = 9422442420530996345309194798178469751092400970299805685848241012956491859890;
    
    uint256 constant IC6x = 5591625386963345598087601353226216320407048890864246384642386270685388456117;
    uint256 constant IC6y = 12843853171149034840866676001323044458664059632834500062922579856934649111697;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pDefensePairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[6] calldata _pubSignals) public view returns (bool) {
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

            function checkDefensePairing(pA, pB, pC, pubSignals, pMem) -> isOk {
                let _pDefensePairing := add(pMem, pDefensePairing)
                let _pVk := add(pMem, pVk)

                mstore(_pVk, IC0x)
                mstore(add(_pVk, 32), IC0y)

                // Compute the linear combination vk_x
                
                g1_mulAccC(_pVk, IC1x, IC1y, calldataload(add(pubSignals, 0)))
                
                g1_mulAccC(_pVk, IC2x, IC2y, calldataload(add(pubSignals, 32)))
                
                g1_mulAccC(_pVk, IC3x, IC3y, calldataload(add(pubSignals, 64)))
                
                g1_mulAccC(_pVk, IC4x, IC4y, calldataload(add(pubSignals, 96)))
                
                g1_mulAccC(_pVk, IC5x, IC5y, calldataload(add(pubSignals, 128)))
                
                g1_mulAccC(_pVk, IC6x, IC6y, calldataload(add(pubSignals, 160)))
                

                // -A
                mstore(_pDefensePairing, calldataload(pA))
                mstore(add(_pDefensePairing, 32), mod(sub(q, calldataload(add(pA, 32))), q))

                // B
                mstore(add(_pDefensePairing, 64), calldataload(pB))
                mstore(add(_pDefensePairing, 96), calldataload(add(pB, 32)))
                mstore(add(_pDefensePairing, 128), calldataload(add(pB, 64)))
                mstore(add(_pDefensePairing, 160), calldataload(add(pB, 96)))

                // alpha1
                mstore(add(_pDefensePairing, 192), alphax)
                mstore(add(_pDefensePairing, 224), alphay)

                // beta2
                mstore(add(_pDefensePairing, 256), betax1)
                mstore(add(_pDefensePairing, 288), betax2)
                mstore(add(_pDefensePairing, 320), betay1)
                mstore(add(_pDefensePairing, 352), betay2)

                // vk_x
                mstore(add(_pDefensePairing, 384), mload(add(pMem, pVk)))
                mstore(add(_pDefensePairing, 416), mload(add(pMem, add(pVk, 32))))


                // gamma2
                mstore(add(_pDefensePairing, 448), gammax1)
                mstore(add(_pDefensePairing, 480), gammax2)
                mstore(add(_pDefensePairing, 512), gammay1)
                mstore(add(_pDefensePairing, 544), gammay2)

                // C
                mstore(add(_pDefensePairing, 576), calldataload(pC))
                mstore(add(_pDefensePairing, 608), calldataload(add(pC, 32)))

                // delta2
                mstore(add(_pDefensePairing, 640), deltax1)
                mstore(add(_pDefensePairing, 672), deltax2)
                mstore(add(_pDefensePairing, 704), deltay1)
                mstore(add(_pDefensePairing, 736), deltay2)


                let success := staticcall(sub(gas(), 2000), 8, _pDefensePairing, 768, _pDefensePairing, 0x20)

                isOk := and(success, mload(_pDefensePairing))
            }

            let pMem := mload(0x40)
            mstore(0x40, add(pMem, pLastMem))

            // Validate that all evaluations ∈ F
            
            checkField(calldataload(add(_pubSignals, 0)))
            
            checkField(calldataload(add(_pubSignals, 32)))
            
            checkField(calldataload(add(_pubSignals, 64)))
            
            checkField(calldataload(add(_pubSignals, 96)))
            
            checkField(calldataload(add(_pubSignals, 128)))
            
            checkField(calldataload(add(_pubSignals, 160)))
            
            checkField(calldataload(add(_pubSignals, 192)))
            

            // Validate all evaluations
            let isValid := checkDefensePairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }

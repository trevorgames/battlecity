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

contract Groth16MoveVerifier {
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
    uint256 constant deltax1 = 1779810772440246806146155686264807854451779378826040333238604539274717664314;
    uint256 constant deltax2 = 17404204704227579761946664618657122302127660890677437210617165892322771218221;
    uint256 constant deltay1 = 15566142571471247545815090098038396995598233657876040343766437817856095058744;
    uint256 constant deltay2 = 17763119656733668190756360853897881504106715533774646698899417805409990218950;

    
    uint256 constant IC0x = 6040348526041304708071472219686015710888546983558560907916025656382926529376;
    uint256 constant IC0y = 4304518604626964053490877057151366206822425274919692334817549627628452772442;
    
    uint256 constant IC1x = 14892566347229834054455121567852636446452089336227604574476965280897849676794;
    uint256 constant IC1y = 18853262080561822474468587346103699470638583508498848859665502438735298970617;
    
    uint256 constant IC2x = 14317084480123786549280805789235473013551433065871991699451188484205893763692;
    uint256 constant IC2y = 20711917237248932347387255935580071561500271485474097657639392774356341615594;
    
    uint256 constant IC3x = 327166247294107650426573123648479510198779885302539959975881671981999009313;
    uint256 constant IC3y = 14821844021314357909025064449027914942653344209889723593895681778304696807805;
    
    uint256 constant IC4x = 17731912547226748074188627421464214332561111586868147992392371867451876811912;
    uint256 constant IC4y = 18997210577140927586555905462460635353362955300298114791312546894832294414673;
    
    uint256 constant IC5x = 2518880676218389960773737178803164744651104981570597301813856151292120133737;
    uint256 constant IC5y = 1316874283018887267840570848957408383479697738673030065925712054896237404477;
    
    uint256 constant IC6x = 8133701691093470716572490069864258678295458337054499814471274416183665592225;
    uint256 constant IC6y = 21520521064096435409528797354410556317451298139642129196451785256471883704829;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pMovePairing = 128;

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

            function checkMovePairing(pA, pB, pC, pubSignals, pMem) -> isOk {
                let _pMovePairing := add(pMem, pMovePairing)
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
                mstore(_pMovePairing, calldataload(pA))
                mstore(add(_pMovePairing, 32), mod(sub(q, calldataload(add(pA, 32))), q))

                // B
                mstore(add(_pMovePairing, 64), calldataload(pB))
                mstore(add(_pMovePairing, 96), calldataload(add(pB, 32)))
                mstore(add(_pMovePairing, 128), calldataload(add(pB, 64)))
                mstore(add(_pMovePairing, 160), calldataload(add(pB, 96)))

                // alpha1
                mstore(add(_pMovePairing, 192), alphax)
                mstore(add(_pMovePairing, 224), alphay)

                // beta2
                mstore(add(_pMovePairing, 256), betax1)
                mstore(add(_pMovePairing, 288), betax2)
                mstore(add(_pMovePairing, 320), betay1)
                mstore(add(_pMovePairing, 352), betay2)

                // vk_x
                mstore(add(_pMovePairing, 384), mload(add(pMem, pVk)))
                mstore(add(_pMovePairing, 416), mload(add(pMem, add(pVk, 32))))


                // gamma2
                mstore(add(_pMovePairing, 448), gammax1)
                mstore(add(_pMovePairing, 480), gammax2)
                mstore(add(_pMovePairing, 512), gammay1)
                mstore(add(_pMovePairing, 544), gammay2)

                // C
                mstore(add(_pMovePairing, 576), calldataload(pC))
                mstore(add(_pMovePairing, 608), calldataload(add(pC, 32)))

                // delta2
                mstore(add(_pMovePairing, 640), deltax1)
                mstore(add(_pMovePairing, 672), deltax2)
                mstore(add(_pMovePairing, 704), deltay1)
                mstore(add(_pMovePairing, 736), deltay2)


                let success := staticcall(sub(gas(), 2000), 8, _pMovePairing, 768, _pMovePairing, 0x20)

                isOk := and(success, mload(_pMovePairing))
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
            let isValid := checkMovePairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }

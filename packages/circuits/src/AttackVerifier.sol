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

contract Groth16AttackVerifier {
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
    uint256 constant deltax1 = 21683781847705437449376649766379520420268697078534048053991805459258913057752;
    uint256 constant deltax2 = 20922291665877303729962701367623738458439569492702098123894725393932303262298;
    uint256 constant deltay1 = 9052330194826486376966800555175406531741258756386697871600242315868539380054;
    uint256 constant deltay2 = 15842716507202713737768774232267648247322766333828629379912005233923813484988;

    
    uint256 constant IC0x = 5204640043681492249243199615801169604277543551762493443940410094628855820834;
    uint256 constant IC0y = 19110447504231634480290575415658288512082681161810553386610455629418312066048;
    
    uint256 constant IC1x = 15038550725433897127941951778559848670732095020394372118214705964136426520237;
    uint256 constant IC1y = 16531068980258815459879488622489639699778195275988182014280178183050734867923;
    
    uint256 constant IC2x = 778831499939088404100970800264946085609477897830608687054279691691952795360;
    uint256 constant IC2y = 3523119807913384602002658178065110202373759990838731707477776223917989097857;
    
    uint256 constant IC3x = 12850867715338590263837467408816957459965988513342711552245191784374718966922;
    uint256 constant IC3y = 8623292548445099023781205133625705174069508543073760107058573554830950531488;
    
    uint256 constant IC4x = 12324015909697605295683367356738203563862974098103411639391248131286963722866;
    uint256 constant IC4y = 14988056613341526354321909431746078239812736993239954710148265786071315156479;
    
    uint256 constant IC5x = 5624305164216956435918617640877510903760918255602579210945595913866531395357;
    uint256 constant IC5y = 14302379042901270545984549817489138429783272908842106622310352462108434267358;
    
    uint256 constant IC6x = 16851662136115438685222091271555482874130951656394884603770120180605957006837;
    uint256 constant IC6y = 15956887099210908780723654893126211253415239758458906813032024420581378714044;
    
    uint256 constant IC7x = 15067777780368028364329583250736316273261110486773500731383456577853167963956;
    uint256 constant IC7y = 3331181544741602072429492870963553021346689586804395078742899504728749805292;
    
    uint256 constant IC8x = 12756148439359919116716224640836536182296004659346856165098680660495687578065;
    uint256 constant IC8y = 21508520944679988529409538589080892917689983766528460392066905788502191357434;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pAttackPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[8] calldata _pubSignals) public view returns (bool) {
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

            function checkAttackPairing(pA, pB, pC, pubSignals, pMem) -> isOk {
                let _pAttackPairing := add(pMem, pAttackPairing)
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
                
                g1_mulAccC(_pVk, IC7x, IC7y, calldataload(add(pubSignals, 192)))
                
                g1_mulAccC(_pVk, IC8x, IC8y, calldataload(add(pubSignals, 224)))
                

                // -A
                mstore(_pAttackPairing, calldataload(pA))
                mstore(add(_pAttackPairing, 32), mod(sub(q, calldataload(add(pA, 32))), q))

                // B
                mstore(add(_pAttackPairing, 64), calldataload(pB))
                mstore(add(_pAttackPairing, 96), calldataload(add(pB, 32)))
                mstore(add(_pAttackPairing, 128), calldataload(add(pB, 64)))
                mstore(add(_pAttackPairing, 160), calldataload(add(pB, 96)))

                // alpha1
                mstore(add(_pAttackPairing, 192), alphax)
                mstore(add(_pAttackPairing, 224), alphay)

                // beta2
                mstore(add(_pAttackPairing, 256), betax1)
                mstore(add(_pAttackPairing, 288), betax2)
                mstore(add(_pAttackPairing, 320), betay1)
                mstore(add(_pAttackPairing, 352), betay2)

                // vk_x
                mstore(add(_pAttackPairing, 384), mload(add(pMem, pVk)))
                mstore(add(_pAttackPairing, 416), mload(add(pMem, add(pVk, 32))))


                // gamma2
                mstore(add(_pAttackPairing, 448), gammax1)
                mstore(add(_pAttackPairing, 480), gammax2)
                mstore(add(_pAttackPairing, 512), gammay1)
                mstore(add(_pAttackPairing, 544), gammay2)

                // C
                mstore(add(_pAttackPairing, 576), calldataload(pC))
                mstore(add(_pAttackPairing, 608), calldataload(add(pC, 32)))

                // delta2
                mstore(add(_pAttackPairing, 640), deltax1)
                mstore(add(_pAttackPairing, 672), deltax2)
                mstore(add(_pAttackPairing, 704), deltay1)
                mstore(add(_pAttackPairing, 736), deltay2)


                let success := staticcall(sub(gas(), 2000), 8, _pAttackPairing, 768, _pAttackPairing, 0x20)

                isOk := and(success, mload(_pAttackPairing))
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
            
            checkField(calldataload(add(_pubSignals, 224)))
            
            checkField(calldataload(add(_pubSignals, 256)))
            

            // Validate all evaluations
            let isValid := checkAttackPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }

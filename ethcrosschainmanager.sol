pragma solidity ^0.5.0;

library Utils {

    /* @notice      Convert the bytes array to bytes32 type, the bytes array length must be 32
    *  @param _bs   Source bytes array
    *  @return      bytes32
    */
    function bytesToBytes32(bytes memory _bs) internal pure returns (bytes32 value) {
        require(_bs.length == 32, "bytes length is not 32.");
        assembly {
            // load 32 bytes from memory starting from position _bs + 0x20 since the first 0x20 bytes stores _bs length
            value := mload(add(_bs, 0x20))
        }
    }

    /* @notice      Convert bytes to uint256
    *  @param _b    Source bytes should have length of 32
    *  @return      uint256
    */
    function bytesToUint256(bytes memory _bs) internal pure returns (uint256 value) {
        require(_bs.length == 32, "bytes length is not 32.");
        assembly {
            // load 32 bytes from memory starting from position _bs + 32
            value := mload(add(_bs, 0x20))
        }
        require(value <= 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, "Value exceeds the range");
    }

    /* @notice      Convert uint256 to bytes
    *  @param _b    uint256 that needs to be converted
    *  @return      bytes
    */
    function uint256ToBytes(uint256 _value) internal pure returns (bytes memory bs) {
        require(_value <= 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, "Value exceeds the range");
        assembly {
            // Get a location of some free memory and store it in result as
            // Solidity does for memory variables.
            bs := mload(0x40)
            // Put 0x20 at the first word, the length of bytes for uint256 value
            mstore(bs, 0x20)
            //In the next word, put value in bytes format to the next 32 bytes
            mstore(add(bs, 0x20), _value)
            // Update the free-memory pointer by padding our last write location to 32 bytes
            mstore(0x40, add(bs, 0x40))
        }
    }

    /* @notice      Convert bytes to address
    *  @param _bs   Source bytes: bytes length must be 20
    *  @return      Converted address from source bytes
    */
    function bytesToAddress(bytes memory _bs) internal pure returns (address addr)
    {
        require(_bs.length == 20, "bytes length does not match address");
        assembly {
            // for _bs, first word store _bs.length, second word store _bs.value
            // load 32 bytes from mem[_bs+20], convert it into Uint160, meaning we take last 20 bytes as addr (address).
            addr := mload(add(_bs, 0x14))
        }

    }
    
    /* @notice      Convert address to bytes
    *  @param _addr Address need to be converted
    *  @return      Converted bytes from address
    */
    function addressToBytes(address _addr) internal pure returns (bytes memory bs){
        assembly {
            // Get a location of some free memory and store it in result as
            // Solidity does for memory variables.
            bs := mload(0x40)
            // Put 20 (address byte length) at the first word, the length of bytes for uint256 value
            mstore(bs, 0x14)
            // logical shift left _a by 12 bytes, change _a from right-aligned to left-aligned
            mstore(add(bs, 0x20), shl(96, _addr))
            // Update the free-memory pointer by padding our last write location to 32 bytes
            mstore(0x40, add(bs, 0x40))
       }
    }

    /* @notice          Do hash leaf as the multi-chain does
    *  @param _data     Data in bytes format
    *  @return          Hashed value in bytes32 format
    */
    function hashLeaf(bytes memory _data) internal pure returns (bytes32 result)  {
        result = sha256(abi.encodePacked(byte(0x0), _data));
    }

    /* @notice          Do hash children as the multi-chain does
    *  @param _l        Left node
    *  @param _r        Right node
    *  @return          Hashed value in bytes32 format
    */
    function hashChildren(bytes32 _l, bytes32  _r) internal pure returns (bytes32 result)  {
        result = sha256(abi.encodePacked(bytes1(0x01), _l, _r));
    }

    /* @notice              Compare if two bytes are equal, which are in storage and memory, seperately
                            Refer from https://github.com/summa-tx/bitcoin-spv/blob/master/solidity/contracts/BytesLib.sol#L368
    *  @param _preBytes     The bytes stored in storage
    *  @param _postBytes    The bytes stored in memory
    *  @return              Bool type indicating if they are equal
    */
    function equalStorage(bytes storage _preBytes, bytes memory _postBytes) internal view returns (bool) {
        bool success = true;

        assembly {
            // we know _preBytes_offset is 0
            let fslot := sload(_preBytes_slot)
            // Arrays of 31 bytes or less have an even value in their slot,
            // while longer arrays have an odd value. The actual length is
            // the slot divided by two for odd values, and the lowest order
            // byte divided by two for even values.
            // If the slot is even, bitwise and the slot with 255 and divide by
            // two to get the length. If the slot is odd, bitwise and the slot
            // with -1 and divide by two.
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)

            // if lengths don't match the arrays are not equal
            switch eq(slength, mlength)
            case 1 {
                // fslot can contain both the length and contents of the array
                // if slength < 32 bytes so let's prepare for that
                // v. http://solidity.readthedocs.io/en/latest/miscellaneous.html#layout-of-state-variables-in-storage
                // slength != 0
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        // blank the last byte which is the length
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            // unsuccess:
                            success := 0
                        }
                    }
                    default {
                        // cb is a circuit breaker in the for loop since there's
                        //  no said feature for inline assembly loops
                        // cb = 1 - don't breaker
                        // cb = 0 - break
                        let cb := 1

                        // get the keccak hash to get the contents of the array
                        mstore(0x0, _preBytes_slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                        // the next line is the loop condition:
                        // while(uint(mc < end) + cb == 2)
                        for {} eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                // unsuccess:
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                // unsuccess:
                success := 0
            }
        }

        return success;
    }

    /* @notice              Slice the _bytes from _start index till the result has length of _length
                            Refer from https://github.com/summa-tx/bitcoin-spv/blob/master/solidity/contracts/BytesLib.sol#L246
    *  @param _bytes        The original bytes needs to be sliced
    *  @param _start        The index of _bytes for the start of sliced bytes
    *  @param _length       The index of _bytes for the end of sliced bytes
    *  @return              The sliced bytes
    */
    function slice(
        bytes memory _bytes,
        uint _start,
        uint _length
    )
        internal
        pure
        returns (bytes memory)
    {
        require(_bytes.length >= (_start + _length));

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice result is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                // lengthmod <= _length % 32
                let lengthmod := and(_length, 31)

                // The multiplication in the next line is necessary
                // because when slicing multiples of 32 bytes (lengthmod == 0)
                // the following copy loop was copying the origin's length
                // and then ending prematurely not copying everything it should.
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    // The multiplication in the next line has the same exact purpose
                    // as the one above.
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                //update free-memory pointer
                //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }
    /* @notice              Check if the elements number of _signers within _keepers array is no less than _m
    *  @param _keepers      The array consists of serveral address
    *  @param _signers      Some specific addresses to be looked into
    *  @param _m            The number requirement paramter
    *  @return              True means containment, false meansdo do not contain.
    */
    function containMAddresses(address[] memory _keepers, address[] memory _signers, uint _m) internal pure returns (bool){
        uint m = 0;
        for(uint i = 0; i < _signers.length; i++){
            for (uint j = 0; j < _keepers.length; j++) {
                if (_signers[i] == _keepers[j]) {
                    m++;
                    delete _keepers[j];
                }
            }
        }
        return m >= _m;
    }

    /* @notice              TODO
    *  @param key
    *  @return
    */
    function compressMCPubKey(bytes memory key) internal pure returns (bytes memory newkey) {
         require(key.length >= 67, "key lenggh is too short");
         newkey = slice(key, 0, 35);
         if (uint8(key[66]) % 2 == 0){
             newkey[2] = byte(0x02);
         } else {
             newkey[2] = byte(0x03);
         }
         return newkey;
    }
    
    /**
     * @dev Returns true if `account` is a contract.
     *      Refer from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol#L18
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * IMPORTANT: It is unsafe to assume that an address for which this
     * function returns false is an externally-owned account (EOA) and not a
     * contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) 
            return 0;
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

library ZeroCopySink {
    /* @notice          Convert boolean value into bytes
    *  @param b         The boolean value
    *  @return          Converted bytes array
    */
    function WriteBool(bool b) internal pure returns (bytes memory) {
        bytes memory buff;
        assembly{
            buff := mload(0x40)
            mstore(buff, 1)
            switch iszero(b)
            case 1 {
                mstore(add(buff, 0x20), shl(248, 0x00))
                // mstore8(add(buff, 0x20), 0x00)
            }
            default {
                mstore(add(buff, 0x20), shl(248, 0x01))
                // mstore8(add(buff, 0x20), 0x01)
            }
            mstore(0x40, add(buff, 0x21))
        }
        return buff;
    }

    /* @notice          Convert byte value into bytes
    *  @param b         The byte value
    *  @return          Converted bytes array
    */
    function WriteByte(byte b) internal pure returns (bytes memory) {
        return WriteUint8(uint8(b));
    }

    /* @notice          Convert uint8 value into bytes
    *  @param v         The uint8 value
    *  @return          Converted bytes array
    */
    function WriteUint8(uint8 v) internal pure returns (bytes memory) {
        bytes memory buff;
        assembly{
            buff := mload(0x40)
            mstore(buff, 1)
            mstore(add(buff, 0x20), shl(248, v))
            // mstore(add(buff, 0x20), byte(0x1f, v))
            mstore(0x40, add(buff, 0x21))
        }
        return buff;
    }

    /* @notice          Convert uint16 value into bytes
    *  @param v         The uint16 value
    *  @return          Converted bytes array
    */
    function WriteUint16(uint16 v) internal pure returns (bytes memory) {
        bytes memory buff;

        assembly{
            buff := mload(0x40)
            let byteLen := 0x02
            mstore(buff, byteLen)
            for {
                let mindex := 0x00
                let vindex := 0x1f
            } lt(mindex, byteLen) {
                mindex := add(mindex, 0x01)
                vindex := sub(vindex, 0x01)
            }{
                mstore8(add(add(buff, 0x20), mindex), byte(vindex, v))
            }
            mstore(0x40, add(buff, 0x22))
        }
        return buff;
    }
    
    /* @notice          Convert uint32 value into bytes
    *  @param v         The uint32 value
    *  @return          Converted bytes array
    */
    function WriteUint32(uint32 v) internal pure returns(bytes memory) {
        bytes memory buff;
        assembly{
            buff := mload(0x40)
            let byteLen := 0x04
            mstore(buff, byteLen)
            for {
                let mindex := 0x00
                let vindex := 0x1f
            } lt(mindex, byteLen) {
                mindex := add(mindex, 0x01)
                vindex := sub(vindex, 0x01)
            }{
                mstore8(add(add(buff, 0x20), mindex), byte(vindex, v))
            }
            mstore(0x40, add(buff, 0x24))
        }
        return buff;
    }

    /* @notice          Convert uint64 value into bytes
    *  @param v         The uint64 value
    *  @return          Converted bytes array
    */
    function WriteUint64(uint64 v) internal pure returns(bytes memory) {
        bytes memory buff;

        assembly{
            buff := mload(0x40)
            let byteLen := 0x08
            mstore(buff, byteLen)
            for {
                let mindex := 0x00
                let vindex := 0x1f
            } lt(mindex, byteLen) {
                mindex := add(mindex, 0x01)
                vindex := sub(vindex, 0x01)
            }{
                mstore8(add(add(buff, 0x20), mindex), byte(vindex, v))
            }
            mstore(0x40, add(buff, 0x28))
        }
        return buff;
    }

    /* @notice          Convert limited uint256 value into bytes
    *  @param v         The uint256 value
    *  @return          Converted bytes array
    */
    function WriteUint255(uint256 v) internal pure returns (bytes memory) {
        require(v <= 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, "Value exceeds uint255 range");
        bytes memory buff;

        assembly{
            buff := mload(0x40)
            let byteLen := 0x20
            mstore(buff, byteLen)
            for {
                let mindex := 0x00
                let vindex := 0x1f
            } lt(mindex, byteLen) {
                mindex := add(mindex, 0x01)
                vindex := sub(vindex, 0x01)
            }{
                mstore8(add(add(buff, 0x20), mindex), byte(vindex, v))
            }
            mstore(0x40, add(buff, 0x40))
        }
        return buff;
    }

    /* @notice          Encode bytes format data into bytes
    *  @param data      The bytes array data
    *  @return          Encoded bytes array
    */
    function WriteVarBytes(bytes memory data) internal pure returns (bytes memory) {
        uint64 l = uint64(data.length);
        return abi.encodePacked(WriteVarUint(l), data);
    }

    function WriteVarUint(uint64 v) internal pure returns (bytes memory) {
        if (v < 0xFD){
    		return WriteUint8(uint8(v));
    	} else if (v <= 0xFFFF) {
    		return abi.encodePacked(WriteByte(0xFD), WriteUint16(uint16(v)));
    	} else if (v <= 0xFFFFFFFF) {
            return abi.encodePacked(WriteByte(0xFE), WriteUint32(uint32(v)));
    	} else {
    		return abi.encodePacked(WriteByte(0xFF), WriteUint64(uint64(v)));
    	}
    }
}

library ZeroCopySource {
    /* @notice              Read next byte as boolean type starting at offset from buff
    *  @param buff          Source bytes array
    *  @param offset        The position from where we read the boolean value
    *  @return              The the read boolean value and new offset
    */
    function NextBool(bytes memory buff, uint256 offset) internal pure returns(bool, uint256) {
        require(offset + 1 <= buff.length && offset < offset + 1, "Offset exceeds limit");
        // byte === bytes1
        byte v;
        assembly{
            v := mload(add(add(buff, 0x20), offset))
        }
        bool value;
        if (v == 0x01) {
		    value = true;
    	} else if (v == 0x00) {
            value = false;
        } else {
            revert("NextBool value error");
        }
        return (value, offset + 1);
    }

    /* @notice              Read next byte starting at offset from buff
    *  @param buff          Source bytes array
    *  @param offset        The position from where we read the byte value
    *  @return              The read byte value and new offset
    */
    function NextByte(bytes memory buff, uint256 offset) internal pure returns (byte, uint256) {
        require(offset + 1 <= buff.length && offset < offset + 1, "NextByte, Offset exceeds maximum");
        byte v;
        assembly{
            v := mload(add(add(buff, 0x20), offset))
        }
        return (v, offset + 1);
    }

    /* @notice              Read next byte as uint8 starting at offset from buff
    *  @param buff          Source bytes array
    *  @param offset        The position from where we read the byte value
    *  @return              The read uint8 value and new offset
    */
    function NextUint8(bytes memory buff, uint256 offset) internal pure returns (uint8, uint256) {
        require(offset + 1 <= buff.length && offset < offset + 1, "NextUint8, Offset exceeds maximum");
        uint8 v;
        assembly{
            let tmpbytes := mload(0x40)
            let bvalue := mload(add(add(buff, 0x20), offset))
            mstore8(tmpbytes, byte(0, bvalue))
            mstore(0x40, add(tmpbytes, 0x01))
            v := mload(sub(tmpbytes, 0x1f))
        }
        return (v, offset + 1);
    }

    /* @notice              Read next two bytes as uint16 type starting from offset
    *  @param buff          Source bytes array
    *  @param offset        The position from where we read the uint16 value
    *  @return              The read uint16 value and updated offset
    */
    function NextUint16(bytes memory buff, uint256 offset) internal pure returns (uint16, uint256) {
        require(offset + 2 <= buff.length && offset < offset + 2, "NextUint16, offset exceeds maximum");
        
        uint16 v;
        assembly {
            let tmpbytes := mload(0x40)
            let bvalue := mload(add(add(buff, 0x20), offset))
            mstore8(tmpbytes, byte(0x01, bvalue))
            mstore8(add(tmpbytes, 0x01), byte(0, bvalue))
            mstore(0x40, add(tmpbytes, 0x02))
            v := mload(sub(tmpbytes, 0x1e))
        }
        return (v, offset + 2);
    }


    /* @notice              Read next four bytes as uint32 type starting from offset
    *  @param buff          Source bytes array
    *  @param offset        The position from where we read the uint32 value
    *  @return              The read uint32 value and updated offset
    */
    function NextUint32(bytes memory buff, uint256 offset) internal pure returns (uint32, uint256) {
        require(offset + 4 <= buff.length && offset < offset + 4, "NextUint32, offset exceeds maximum");
        uint32 v;
        assembly {
            let tmpbytes := mload(0x40)
            let byteLen := 0x04
            for {
                let tindex := 0x00
                let bindex := sub(byteLen, 0x01)
                let bvalue := mload(add(add(buff, 0x20), offset))
            } lt(tindex, byteLen) {
                tindex := add(tindex, 0x01)
                bindex := sub(bindex, 0x01)
            }{
                mstore8(add(tmpbytes, tindex), byte(bindex, bvalue))
            }
            mstore(0x40, add(tmpbytes, byteLen))
            v := mload(sub(tmpbytes, sub(0x20, byteLen)))
        }
        return (v, offset + 4);
    }

    /* @notice              Read next eight bytes as uint64 type starting from offset
    *  @param buff          Source bytes array
    *  @param offset        The position from where we read the uint64 value
    *  @return              The read uint64 value and updated offset
    */
    function NextUint64(bytes memory buff, uint256 offset) internal pure returns (uint64, uint256) {
        require(offset + 8 <= buff.length && offset < offset + 8, "NextUint64, offset exceeds maximum");
        uint64 v;
        assembly {
            let tmpbytes := mload(0x40)
            let byteLen := 0x08
            for {
                let tindex := 0x00
                let bindex := sub(byteLen, 0x01)
                let bvalue := mload(add(add(buff, 0x20), offset))
            } lt(tindex, byteLen) {
                tindex := add(tindex, 0x01)
                bindex := sub(bindex, 0x01)
            }{
                mstore8(add(tmpbytes, tindex), byte(bindex, bvalue))
            }
            mstore(0x40, add(tmpbytes, byteLen))
            v := mload(sub(tmpbytes, sub(0x20, byteLen)))
        }
        return (v, offset + 8);
    }

    /* @notice              Read next 32 bytes as uint256 type starting from offset,
                            there are limits considering the numerical limits in multi-chain
    *  @param buff          Source bytes array
    *  @param offset        The position from where we read the uint256 value
    *  @return              The read uint256 value and updated offset
    */
    function NextUint255(bytes memory buff, uint256 offset) internal pure returns (uint256, uint256) {
        require(offset + 32 <= buff.length && offset < offset + 32, "NextUint255, offset exceeds maximum");
        uint256 v;
        assembly {
            let tmpbytes := mload(0x40)
            let byteLen := 0x20
            for {
                let tindex := 0x00
                let bindex := sub(byteLen, 0x01)
                let bvalue := mload(add(add(buff, 0x20), offset))
            } lt(tindex, byteLen) {
                tindex := add(tindex, 0x01)
                bindex := sub(bindex, 0x01)
            }{
                mstore8(add(tmpbytes, tindex), byte(bindex, bvalue))
            }
            mstore(0x40, add(tmpbytes, byteLen))
            v := mload(tmpbytes)
        }
        require(v <= 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, "Value exceeds the range");
        return (v, offset + 32);
    }
    /* @notice              Read next variable bytes starting from offset,
                            the decoding rule coming from multi-chain
    *  @param buff          Source bytes array
    *  @param offset        The position from where we read the bytes value
    *  @return              The read variable bytes array value and updated offset
    */
    function NextVarBytes(bytes memory buff, uint256 offset) internal pure returns(bytes memory, uint256) {
        uint len;
        (len, offset) = NextVarUint(buff, offset);
        require(offset + len <= buff.length && offset < offset + len, "NextVarBytes, offset exceeds maximum");
        bytes memory tempBytes;
        assembly{
            switch iszero(len)
            case 0 {
                // Get a location of some free memory and store it in tempBytes as
                // Solidity does for memory variables.
                tempBytes := mload(0x40)

                // The first word of the slice result is potentially a partial
                // word read from the original array. To read it, we calculate
                // the length of that partial word and start copying that many
                // bytes into the array. The first word we copy will start with
                // data we don't care about, but the last `lengthmod` bytes will
                // land at the beginning of the contents of the new array. When
                // we're done copying, we overwrite the full first word with
                // the actual length of the slice.
                let lengthmod := and(len, 31)

                // The multiplication in the next line is necessary
                // because when slicing multiples of 32 bytes (lengthmod == 0)
                // the following copy loop was copying the origin's length
                // and then ending prematurely not copying everything it should.
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, len)

                for {
                    // The multiplication in the next line has the same exact purpose
                    // as the one above.
                    let cc := add(add(add(buff, lengthmod), mul(0x20, iszero(lengthmod))), offset)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, len)

                //update free-memory pointer
                //allocating the array padded to 32 bytes like the compiler does now
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            //if we want a zero-length slice let's just return a zero-length array
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return (tempBytes, offset + len);
    }
    /* @notice              Read next 32 bytes starting from offset,
    *  @param buff          Source bytes array
    *  @param offset        The position from where we read the bytes value
    *  @return              The read bytes32 value and updated offset
    */
    function NextHash(bytes memory buff, uint256 offset) internal pure returns (bytes32 , uint256) {
        require(offset + 32 <= buff.length && offset < offset + 32, "NextHash, offset exceeds maximum");
        bytes32 v;
        assembly {
            v := mload(add(buff, add(offset, 0x20)))
        }
        return (v, offset + 32);
    }

    /* @notice              Read next 20 bytes starting from offset,
    *  @param buff          Source bytes array
    *  @param offset        The position from where we read the bytes value
    *  @return              The read bytes20 value and updated offset
    */
    function NextBytes20(bytes memory buff, uint256 offset) internal pure returns (bytes20 , uint256) {
        require(offset + 20 <= buff.length && offset < offset + 20, "NextBytes20, offset exceeds maximum");
        bytes20 v;
        assembly {
            v := mload(add(buff, add(offset, 0x20)))
        }
        return (v, offset + 20);
    }
    
    function NextVarUint(bytes memory buff, uint256 offset) internal pure returns(uint, uint256) {
        byte v;
        (v, offset) = NextByte(buff, offset);

        uint value;
        if (v == 0xFD) {
            // return NextUint16(buff, offset);
            (value, offset) = NextUint16(buff, offset);
            require(value >= 0xFD && value <= 0xFFFF, "NextUint16, value outside range");
            return (value, offset);
        } else if (v == 0xFE) {
            // return NextUint32(buff, offset);
            (value, offset) = NextUint32(buff, offset);
            require(value > 0xFFFF && value <= 0xFFFFFFFF, "NextVarUint, value outside range");
            return (value, offset);
        } else if (v == 0xFF) {
            // return NextUint64(buff, offset);
            (value, offset) = NextUint64(buff, offset);
            require(value > 0xFFFFFFFF, "NextVarUint, value outside range");
            return (value, offset);
        } else{
            // return (uint8(v), offset);
            value = uint8(v);
            require(value < 0xFD, "NextVarUint, value outside range");
            return (value, offset);
        }
    }
}
 
library ECCUtils {

    struct Header {
        uint32 version;
        uint64 chainId;
        uint32 timestamp;
        uint32 height;
        uint64 consensusData;
        bytes32 prevBlockHash;
        bytes32 transactionsRoot;
        bytes32 crossStatesRoot;
        bytes32 blockRoot;
        bytes consensusPayload;
        bytes20 nextBookkeeper;
    }

    struct ToMerkleValue {
        bytes  txHash;  // cross chain txhash
        uint64 fromChainID;
        TxParam makeTxParam;
    }

    struct TxParam {
        bytes txHash; //  source chain txhash
        bytes crossChainId;
        bytes fromContract;
        uint64 toChainId;
        bytes toContract;
        bytes method;
        bytes args;
    }

    uint constant POLYCHAIN_PUBKEY_LEN = 67;
    uint constant POLYCHAIN_SIGNATURE_LEN = 65;

    /* @notice                  Verify Poly chain transaction whether exist or not
    *  @param _auditPath        Poly chain merkle proof
    *  @param _root             Poly chain root
    *  @return                  The verified value included in _auditPath
    */
    function merkleProve(bytes memory _auditPath, bytes32 _root) internal pure returns (bytes memory) {
        uint256 off = 0;
        bytes memory value;
        (value, off)  = ZeroCopySource.NextVarBytes(_auditPath, off);

        bytes32 hash = Utils.hashLeaf(value);
        uint size = (_auditPath.length - off) / 33;
        bytes32 nodeHash;
        byte pos;
        for (uint i = 0; i < size; i++) {
            (pos, off) = ZeroCopySource.NextByte(_auditPath, off);
            (nodeHash, off) = ZeroCopySource.NextHash(_auditPath, off);
            if (pos == 0x00) {
                hash = Utils.hashChildren(nodeHash, hash);
            } else if (pos == 0x01) {
                hash = Utils.hashChildren(hash, nodeHash);
            } else {
                revert("merkleProve, NextByte for position info failed");
            }
        }
        require(hash == _root, "merkleProve, expect root is not equal actual root");
        return value;
    }

    /* @notice              calculate next book keeper according to public key list
    *  @param _keyLen       consensus node number
    *  @param _m            minimum signature number
    *  @param _pubKeyList   consensus node public key list
    *  @return              two element: next book keeper, consensus node signer addresses
    */
    function _getBookKeeper(uint _keyLen, uint _m, bytes memory _pubKeyList) internal pure returns (bytes20, address[] memory){
         bytes memory buff;
         buff = ZeroCopySink.WriteUint16(uint16(_keyLen));
         address[] memory keepers = new address[](_keyLen);
         bytes32 hash;
         bytes memory publicKey;
         for(uint i = 0; i < _keyLen; i++){
             publicKey = Utils.slice(_pubKeyList, i*POLYCHAIN_PUBKEY_LEN, POLYCHAIN_PUBKEY_LEN);
             buff =  abi.encodePacked(buff, ZeroCopySink.WriteVarBytes(Utils.compressMCPubKey(publicKey)));
             hash = keccak256(Utils.slice(publicKey, 3, 64));
             keepers[i] = address(uint160(uint256(hash)));
         }

         buff = abi.encodePacked(buff, ZeroCopySink.WriteUint16(uint16(_m)));
         bytes20  nextBookKeeper = ripemd160(abi.encodePacked(sha256(buff)));
         return (nextBookKeeper, keepers);
    }

    /* @notice              Verify public key derived from Poly chain
    *  @param _pubKeyList   serialized consensus node public key list
    *  @param _sigList      consensus node signature list
    *  @return              return two element: next book keeper, consensus node signer addresses
    */
    function verifyPubkey(bytes memory _pubKeyList) internal pure returns (bytes20, address[] memory) {
        require(_pubKeyList.length % POLYCHAIN_PUBKEY_LEN == 0, "_pubKeyList length illegal!");
        uint n = _pubKeyList.length / POLYCHAIN_PUBKEY_LEN;
        require(n >= 1, "too short _pubKeyList!");
        return _getBookKeeper(n, n - (n - 1) / 3, _pubKeyList);
    }

    /* @notice              Verify Poly chain consensus node signature
    *  @param _rawHeader    Poly chain block header raw bytes
    *  @param _sigList      consensus node signature list
    *  @param _keepers      addresses corresponding with Poly chain book keepers' public keys
    *  @param _m            minimum signature number
    *  @return              true or false
    */
    function verifySig(bytes memory _rawHeader, bytes memory _sigList, address[] memory _keepers, uint _m) internal pure returns (bool){
        bytes32 hash = getHeaderHash(_rawHeader);

        uint signed = 0;
        uint sigCount = _sigList.length / POLYCHAIN_SIGNATURE_LEN;
        address[] memory signers = new address[](sigCount);
        bytes32 r;
        bytes32 s;
        uint8 v;
        for(uint j = 0; j  < sigCount; j++){
            r = Utils.bytesToBytes32(Utils.slice(_sigList, j*POLYCHAIN_SIGNATURE_LEN, 32));
            s =  Utils.bytesToBytes32(Utils.slice(_sigList, j*POLYCHAIN_SIGNATURE_LEN + 32, 32));
            v =  uint8(_sigList[j*POLYCHAIN_SIGNATURE_LEN + 64]) + 27;
            signers[j] =  ecrecover(sha256(abi.encodePacked(hash)), v, r, s);
        }
        return Utils.containMAddresses(_keepers, signers, _m);
    }
    

    /* @notice               Serialize Poly chain book keepers' info in Ethereum addresses format into raw bytes
    *  @param keepersBytes   The serialized addresses
    *  @return               serialized bytes result
    */
    function serializeKeepers(address[] memory keepers) internal pure returns (bytes memory) {
        uint256 keeperLen = keepers.length;
        bytes memory keepersBytes = ZeroCopySink.WriteUint64(uint64(keeperLen));
        for(uint i = 0; i < keeperLen; i++) {
            keepersBytes = abi.encodePacked(keepersBytes, ZeroCopySink.WriteVarBytes(Utils.addressToBytes(keepers[i])));
        }
        return keepersBytes;
    }

    /* @notice               Deserialize bytes into Ethereum addresses
    *  @param keepersBytes   The serialized addresses derived from Poly chain book keepers in bytes format
    *  @return               addresses
    */
    function deserializeKeepers(bytes memory keepersBytes) internal pure returns (address[] memory) {
        uint256 off = 0;
        uint64 keeperLen;
        (keeperLen, off) = ZeroCopySource.NextUint64(keepersBytes, off);
        address[] memory keepers = new address[](keeperLen);
        bytes memory keeperBytes;
        for(uint i = 0; i < keeperLen; i++) {
            (keeperBytes, off) = ZeroCopySource.NextVarBytes(keepersBytes, off);
            keepers[i] = Utils.bytesToAddress(keeperBytes);
        }
        return keepers;
    }

    /* @notice               Deserialize Poly chain transaction raw value
    *  @param _valueBs       Poly chain transaction raw bytes
    *  @return               ToMerkleValue struct
    */
    function deserializeMerkleValue(bytes memory _valueBs) internal pure returns (ToMerkleValue memory) {
        ToMerkleValue memory toMerkleValue;
        uint256 off = 0;

        (toMerkleValue.txHash, off) = ZeroCopySource.NextVarBytes(_valueBs, off);

        (toMerkleValue.fromChainID, off) = ZeroCopySource.NextUint64(_valueBs, off);

        TxParam memory txParam;

        (txParam.txHash, off) = ZeroCopySource.NextVarBytes(_valueBs, off);
        
        (txParam.crossChainId, off) = ZeroCopySource.NextVarBytes(_valueBs, off);

        (txParam.fromContract, off) = ZeroCopySource.NextVarBytes(_valueBs, off);

        (txParam.toChainId, off) = ZeroCopySource.NextUint64(_valueBs, off);

        (txParam.toContract, off) = ZeroCopySource.NextVarBytes(_valueBs, off);

        (txParam.method, off) = ZeroCopySource.NextVarBytes(_valueBs, off);

        (txParam.args, off) = ZeroCopySource.NextVarBytes(_valueBs, off);
        toMerkleValue.makeTxParam = txParam;

        return toMerkleValue;
    }

    /* @notice            Deserialize Poly chain block header raw bytes
    *  @param _valueBs    Poly chain block header raw bytes
    *  @return            Header struct
    */
    function deserializeHeader(bytes memory _headerBs) internal pure returns (Header memory) {
        Header memory header;
        uint256 off = 0;
        (header.version, off)  = ZeroCopySource.NextUint32(_headerBs, off);

        (header.chainId, off) = ZeroCopySource.NextUint64(_headerBs, off);

        (header.prevBlockHash, off) = ZeroCopySource.NextHash(_headerBs, off);

        (header.transactionsRoot, off) = ZeroCopySource.NextHash(_headerBs, off);

        (header.crossStatesRoot, off) = ZeroCopySource.NextHash(_headerBs, off);

        (header.blockRoot, off) = ZeroCopySource.NextHash(_headerBs, off);

        (header.timestamp, off) = ZeroCopySource.NextUint32(_headerBs, off);

        (header.height, off) = ZeroCopySource.NextUint32(_headerBs, off);

        (header.consensusData, off) = ZeroCopySource.NextUint64(_headerBs, off);

        (header.consensusPayload, off) = ZeroCopySource.NextVarBytes(_headerBs, off);

        (header.nextBookkeeper, off) = ZeroCopySource.NextBytes20(_headerBs, off);

        return header;
    }

    /* @notice            Deserialize Poly chain block header raw bytes
    *  @param rawHeader   Poly chain block header raw bytes
    *  @return            header hash same as Poly chain
    */
    function getHeaderHash(bytes memory rawHeader) internal pure returns (bytes32) {
        return sha256(abi.encodePacked(sha256(rawHeader)));
    }
}

contract EthCrossChainData {
    mapping(uint256 => bytes32) public EthToPolyTxHashMap;
    // This index records the current Map length
    uint256 public EthToPolyTxHashIndex;

    /* 
     When Poly chain switches the consensus epoch book keepers, the consensus peers public keys of Poly chain should be 
     changed into no-compressed version so that solidity smart contract can convert it to address type and 
     verify the signature derived from Poly chain account signature.
     ConKeepersPkBytes means Consensus book Keepers Public Key Bytes
    */
    bytes public ConKeepersPkBytes;
    
    // CurEpochStartHeight means Current Epoch Start Height of Poly chain block
    uint32 public CurEpochStartHeight;
    
    // Record the from chain txs that have been processed
    mapping(uint64 => mapping(bytes32 => bool)) FromChainTxExist;
    
    // Extra map for the usage of future potentially
    mapping(bytes32 => mapping(bytes32 => bytes)) public ExtraData;
    
    // Store Current Epoch Start Height of Poly chain block
    function putCurEpochStartHeight(uint32 curEpochStartHeight) public returns (bool) {
        CurEpochStartHeight = curEpochStartHeight;
        return true;
    }

    // Get Current Epoch Start Height of Poly chain block
    function getCurEpochStartHeight() public view returns (uint32) {
        return CurEpochStartHeight;
    }

    // Store Consensus book Keepers Public Key Bytes
    function putCurEpochConPubKeyBytes(bytes memory curEpochPkBytes) public returns (bool) {
        ConKeepersPkBytes = curEpochPkBytes;
        return true;
    }

    // Get Consensus book Keepers Public Key Bytes
    function getCurEpochConPubKeyBytes() public view returns (bytes memory) {
        return ConKeepersPkBytes;
    }

    // Mark from chain tx fromChainTx as exist or processed
    function markFromChainTxExist(uint64 fromChainId, bytes32 fromChainTx) public returns (bool) {
        FromChainTxExist[fromChainId][fromChainTx] = true;
        return true;
    }

    // Check if from chain tx fromChainTx has been processed before
    function checkIfFromChainTxExist(uint64 fromChainId, bytes32 fromChainTx) public view returns (bool) {
        return FromChainTxExist[fromChainId][fromChainTx];
    }

    // Get current recorded index of cross chain txs requesting from Ethereum to other public chains
    // in order to help cross chain manager contract differenciate two cross chain tx requests
    function getEthTxHashIndex() public view returns (uint256) {
        return EthToPolyTxHashIndex;
    }

    // Store Ethereum cross chain tx hash, increase the index record by 1
    function putEthTxHash(bytes32 ethTxHash) public returns (bool) {
        EthToPolyTxHashMap[EthToPolyTxHashIndex] = ethTxHash;
        EthToPolyTxHashIndex = EthToPolyTxHashIndex + 1;
        return true;
    }

    // Get Ethereum cross chain tx hash indexed by ethTxHashIndex
    function getEthTxHash(uint256 ethTxHashIndex) public view returns (bytes32) {
        return EthToPolyTxHashMap[ethTxHashIndex];
    }

    // Store extra data, which may be used in the future
    function putExtraData(bytes32 key1, bytes32 key2, bytes memory value) public returns (bool) {
        ExtraData[key1][key2] = value;
        return true;
    }
    // Get extra data, which may be used in the future
    function getExtraData(bytes32 key1, bytes32 key2) public view returns (bytes memory) {
        return ExtraData[key1][key2];
    }
    
    function pause()  public returns (bool) {
        _pause();
        return true;
    }
    
    function unpause() public returns (bool) {
        _unpause();
        return true;
    }

}


contract EthCrossChainManager {

     function verifyHeaderAndExecuteTx(bytes memory proof, bytes memory rawHeader, bytes memory headerProof, bytes memory curRawHeader,bytes memory headerSig) whenNotPaused public returns (bool){
        ECCUtils.Header memory header = ECCUtils.deserializeHeader(rawHeader);
        // Load ehereum cross chain data contract
        IEthCrossChainData eccd = IEthCrossChainData(EthCrossChainDataAddress);
        
        // Get stored consensus public key bytes of current poly chain epoch and deserialize Poly chain consensus public key bytes to address[]
        address[] memory polyChainBKs = ECCUtils.deserializeKeepers(eccd.getCurEpochConPubKeyBytes());

        uint256 curEpochStartHeight = eccd.getCurEpochStartHeight();

        uint n = polyChainBKs.length;
        if (header.height >= curEpochStartHeight) {
            // It's enough to verify rawHeader signature
            require(ECCUtils.verifySig(rawHeader, headerSig, polyChainBKs, n - ( n - 1) / 3), "Verify poly chain header signature failed!");
        } else {
            // We need to verify the signature of curHeader 
            require(ECCUtils.verifySig(curRawHeader, headerSig, polyChainBKs, n - ( n - 1) / 3), "Verify poly chain current epoch header signature failed!");

            // Then use curHeader.StateRoot and headerProof to verify rawHeader.CrossStateRoot
            ECCUtils.Header memory curHeader = ECCUtils.deserializeHeader(curRawHeader);
            bytes memory proveValue = ECCUtils.merkleProve(headerProof, curHeader.blockRoot);
            require(ECCUtils.getHeaderHash(rawHeader) == Utils.bytesToBytes32(proveValue), "verify header proof failed!");
        }
        
        // Through rawHeader.CrossStatesRoot, the toMerkleValue or cross chain msg can be verified and parsed from proof
        bytes memory toMerkleValueBs = ECCUtils.merkleProve(proof, header.crossStatesRoot);
        
        // Parse the toMerkleValue struct and make sure the tx has not been processed, then mark this tx as processed
        ECCUtils.ToMerkleValue memory toMerkleValue = ECCUtils.deserializeMerkleValue(toMerkleValueBs);
        require(!eccd.checkIfFromChainTxExist(toMerkleValue.fromChainID, Utils.bytesToBytes32(toMerkleValue.txHash)), "the transaction has been executed!");
        require(eccd.markFromChainTxExist(toMerkleValue.fromChainID, Utils.bytesToBytes32(toMerkleValue.txHash)), "Save crosschain tx exist failed!");
        
        // Ethereum ChainId is 2, we need to check the transaction is for Ethereum network
        require(toMerkleValue.makeTxParam.toChainId == uint64(2), "This Tx is not aiming at Ethereum network!");
        
        // Obtain the targeting contract, so that Ethereum cross chain manager contract can trigger the executation of cross chain tx on Ethereum side
        address toContract = Utils.bytesToAddress(toMerkleValue.makeTxParam.toContract);
        
        //TODO: check this part to make sure we commit the next line when doing local net UT test
        require(_executeCrossChainTx(toContract, toMerkleValue.makeTxParam.method, toMerkleValue.makeTxParam.args, toMerkleValue.makeTxParam.fromContract, toMerkleValue.fromChainID), "Execute CrossChain Tx failed!");

        // Fire the cross chain event denoting the executation of cross chain tx is successful,
        // and this tx is coming from other public chains to current Ethereum network
        emit VerifyHeaderAndExecuteTxEvent(toMerkleValue.fromChainID, toMerkleValue.makeTxParam.toContract, toMerkleValue.txHash, toMerkleValue.makeTxParam.txHash);

        return true;
    }
    
}
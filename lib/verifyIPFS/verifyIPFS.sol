pragma solidity ^0.4.0;

library verifyIPFS {
  /// @author Martin Lundfall (martin.lundfall@consensys.net)

  /// @dev generates the corresponding IPFS hash (in base 58) to the given string
  /// @param contentString The content of the IPFS object
  /// @return The IPFS hash in base 58
  function generateHash(string contentString) constant returns (bytes) {
    bytes memory prefix1 = hex"0a";
    bytes memory prefix2 = hex"080212";
    bytes memory postfix = hex"18";
    bytes memory sha256MultiHash = hex"1220";

    bytes memory content = bytes(contentString);
    bytes memory len = lengthEncode(content.length);
    bytes memory len2 = lengthEncode(content.length + 4 + 2*len.length);
    return toBase58(concat(sha256MultiHash, toBytes(sha256(prefix1, len2, prefix2, len, content, postfix, len))));
  }

  /// @dev Compares an IPFS hash with content
  function verifyHash(string contentString, string hash) constant returns (bool) {
    return equal(generateHash(contentString), bytes(hash));
  }


  /// @dev Converts hex string to base 58
  function toBase58(bytes source) constant returns (bytes) {
    if (source.length == 0) return new bytes(0);
        uint8[] memory digits = new uint8[](40); //TODO: figure out exactly how much is needed
        digits[0] = 0;
        uint8 digitlength = 1;
        for (var i = 0; i<source.length; ++i) {
            uint carry = uint8(source[i]);
            for (var j = 0; j<digitlength; ++j) {
                carry += uint(digits[j]) * 256;
                digits[j] = uint8(carry % 58);
                carry = carry / 58;
            }

            while (carry > 0) {
                digits[digitlength] = uint8(carry % 58);
                digitlength++;
                carry = carry / 58;
            }
        }
        //return digits;
        return toAlphabet(reverse(truncate(digits, digitlength)));
    }

  function lengthEncode(uint256 length) constant returns (bytes) {
    if (length < 128) {
      return to_binary(length);
    }
    else {
      return concat(to_binary(length % 128 + 128), to_binary(length / 128));
    }
  }

  function toBytes(bytes32 input) constant returns (bytes) {
    bytes memory output = new bytes(32);
    for (uint8 i = 0; i<32; i++) {
      output[i] = input[i];
    }
    return output;
  }

  function equal(bytes memory one, bytes memory two) returns (bool) {
    if (!(one.length == two.length)) {
      return false;
    }
    for (var i = 0; i<one.length; i++) {
      if (!(one[i] == two[i])) {
	return false;
      }
    }
    return true;
  }

    function truncate(uint8[] array, uint8 length) returns (uint8[]) {
        uint8[] memory output = new uint8[](length);
        for (var i = 0; i<length; i++) {
            output[i] = array[i];
        }
        return output;
    }

    function reverse(uint8[] input) returns (uint8[]) {
        uint8[] memory output = new uint8[](input.length);
        for (var i = 0; i<input.length; i++) {
            output[i] = input[input.length-1-i];
        }
        return output;
    }

    function toAlphabet(uint8[] indices) returns (bytes) {
        bytes memory ALPHABET = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

        bytes memory output = new bytes(indices.length);
        for (var i = 0; i<indices.length; i++) {
            output[i] = ALPHABET[indices[i]];
        }
        return output;
    }

  function concat(bytes byteArray, bytes byteArray2) returns (bytes) {
    bytes memory returnArray = new bytes(byteArray.length + byteArray2.length);
    for (uint16 i = 0; i < byteArray.length; i++) {
      returnArray[i] = byteArray[i];
    }
    for (i; i < (byteArray.length + byteArray2.length); i++) {
      returnArray[i] = byteArray2[i - byteArray.length];
    }
    return returnArray;
  }

  function to_binary(uint256 x) returns (bytes) {
    if (x == 0) {
      return new bytes(0);
    }
    else {
      byte s = byte(x % 256);
      bytes memory r = new bytes(1);
      r[0] = s;
      return concat(to_binary(x / 256), r);
    }
  }

}

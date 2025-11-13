import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

class CryptoHelper {
  static Uint8List convertCryptKey(String strKey) {
    final newKey = Uint8List(16);
    final strKeyBytes = utf8.encode(strKey);

    for (var i = 0; i < strKeyBytes.length; i++) {
      newKey[i % 16] ^= strKeyBytes[i];
    }
    return newKey;
  }

  static String decrypt(String encryptedBase64, String key) {
    try {
      // Decode base64
      final encryptedBytes = base64.decode(encryptedBase64);

      // Convert key
      final keyBytes = convertCryptKey(key);

      // Setup cipher
      final cipher = ECBBlockCipher(AESEngine());
      final params = KeyParameter(keyBytes);
      cipher.init(false, params);

      // Decrypt
      final paddedBytes = _processBlocks(cipher, encryptedBytes);

      // Remove PKCS7 padding
      final padLength = paddedBytes.last;
      final messageBytes =
          paddedBytes.sublist(0, paddedBytes.length - padLength);

      return utf8.decode(messageBytes);
    } catch (e) {
      throw Exception('Dữ liệu UTF-8 không hợp lệ: $e');
    }
  }

  static Uint8List _processBlocks(BlockCipher cipher, Uint8List input) {
    final output = Uint8List(input.length);
    for (var offset = 0; offset < input.length; offset += 16) {
      cipher.processBlock(input, offset, output, offset);
    }
    return output;
  }
}

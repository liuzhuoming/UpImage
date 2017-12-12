//
//  StringEncrypt.swift
//  UpImage
//
//  Created by 卓明 on 2017/12/7.
//  Copyright © 2017年 卓明. All rights reserved.
//

import Foundation
extension String {
    
    /**
     3DES的加密过程 和 解密过程
     
     - parameter op : CCOperation： 加密还是解密
     CCOperation（kCCEncrypt）加密
     CCOperation（kCCDecrypt) 解密
     
     - parameter key: 专有的key,一个钥匙一般
     - parameter iv : 可选的初始化向量，可以为nil
     - returns      : 返回加密或解密的参数
     */
    func threeDESEncryptOrDecrypt(op: CCOperation,key: String,iv: String) -> String? {
        
        // Key
        let keyData: NSData = (key as NSString).data(using: String.Encoding.utf8.rawValue) as NSData!
        let keyBytes         = UnsafeMutableRawPointer(mutating: keyData.bytes)
        
        // 加密或解密的内容
        var data: NSData = NSData()
        if op == CCOperation(kCCEncrypt) {
            data  = (self as NSString).data(using: String.Encoding.utf8.rawValue) as NSData!
        }
        else {
            data =  NSData(base64Encoded: self, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
        }
        
        let dataLength    = size_t(data.length)
        let dataBytes     = UnsafeMutableRawPointer(mutating: data.bytes)
        
        // 返回数据
        let cryptData    = NSMutableData(length: Int(dataLength) + kCCBlockSize3DES)
        let cryptPointer = UnsafeMutableRawPointer(cryptData!.mutableBytes)
        let cryptLength  = size_t(cryptData!.length)
        
        //  可选 的初始化向量
        let viData :NSData = (iv as NSString).data(using: String.Encoding.utf8.rawValue) as NSData!
        let viDataBytes    = UnsafeMutableRawPointer(mutating: viData.bytes)
        
        // 特定的几个参数
        let keyLength              = size_t(kCCKeySize3DES)
        let operation: CCOperation = UInt32(op)
        let algoritm:  CCAlgorithm = UInt32(kCCAlgorithm3DES)
        let options:   CCOptions   = UInt32(kCCOptionPKCS7Padding)
        
        var numBytesCrypted :size_t = 0
        
        let cryptStatus = CCCrypt(operation, // 加密还是解密
            algoritm, // 算法类型
            options,  // 密码块的设置选项
            keyBytes, // 秘钥的字节
            keyLength, // 秘钥的长度
            viDataBytes, // 可选初始化向量的字节
            dataBytes, // 加解密内容的字节
            dataLength, // 加解密内容的长度
            cryptPointer, // output data buffer
            cryptLength,  // output data length available
            &numBytesCrypted) // real output data length
        
        
        
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            
            cryptData!.length = Int(numBytesCrypted)
            if op == CCOperation(kCCEncrypt)  {
                let base64cryptString = cryptData?.base64EncodedString(options: .lineLength64Characters)
                return base64cryptString
            }
            else {
                //   let base64cryptString = NSString(bytes: cryptPointer, length: cryptLength, encoding: NSUTF8StringEncoding) as? String  // 用这个会导致返回的JSON数据格式可能有问题，最好不用
                let base64cryptString = NSString(data: cryptData! as Data,  encoding: String.Encoding.utf8.rawValue) as String?
                return base64cryptString
            }
        } else {
            print("Error: \(cryptStatus)")
        }
        return nil
    }
    
    
    /*sha1不可逆加密**/
    func sha1() -> String {
        let data = self.data(using: String.Encoding.utf8)!
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
    
    
    func MD5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        //        let result = UnsafeMutablePointer<CUnsignedChar>.init(allocatingCapacity: digestLen)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deinitialize()
        
        return String(format: hash as String)
    }
    
    func hmac(algorithm: HMACAlgorithm, key: String) -> Data {
        let cKey = key.cString(using: String.Encoding.utf8)
        let cData = self.cString(using: String.Encoding.utf8)
        var result = [CUnsignedChar](repeating: 0, count: Int(algorithm.digestLength()))
        CCHmac(algorithm.toCCHmacAlgorithm(), cKey!, strlen(cKey!), cData!, strlen(cData!), &result)
        let hmacData:NSData = NSData(bytes: result, length: (Int(algorithm.digestLength())))
        let hmacBase64 = hmacData.base64EncodedData(options: NSData.Base64EncodingOptions.lineLength64Characters)
        return hmacBase64
    }
}

enum HMACAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    func toCCHmacAlgorithm() -> CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:
            result = kCCHmacAlgMD5
        case .SHA1:
            result = kCCHmacAlgSHA1
        case .SHA224:
            result = kCCHmacAlgSHA224
        case .SHA256:
            result = kCCHmacAlgSHA256
        case .SHA384:
            result = kCCHmacAlgSHA384
        case .SHA512:
            result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .MD5:
            result = CC_MD5_DIGEST_LENGTH
        case .SHA1:
            result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:
            result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:
            result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:
            result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:
            result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}




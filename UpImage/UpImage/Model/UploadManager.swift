//
//  UploadManager.swift
//  UpImage
//
//  Created by 卓明 on 2017/12/7.
//  Copyright © 2017年 卓明. All rights reserved.
//

import Foundation
import Alamofire

enum KNotificationName : String {
    case uploadSuccess = "uploadSuccess"
    case uploadFailure = "uploadFailure"
    case uploadProgressUpdate = "uploadProgressUpdate"
}



class UploadManager: NSObject {
    static let shareManager = UploadManager()
    var TsessionManager:SessionManager?
    override init() {
        super.init()
        if self.TsessionManager == nil {
            
            
        }
        
    }
    
    func uploadToTencent(data:NSData,fileName:String,progressCallback:@escaping (Double)->()) -> Void {
        
        if let signString = self.caculateTencentSign() {
            print("签名成功"+signString);
            // 根据配置生成host
            guard let host = SettingManager.shareManager.tencentSetting?.hosturl else{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: KNotificationName.uploadFailure.rawValue), object: nil, userInfo: ["info":"腾讯配置出错"])
                print("腾讯配置出错");
                return;
            }
            // 如果文件名没有就随机生成
            let imageName = fileName.count<1 ? (self.randomString(length: 10)+".jpg") :fileName
            // 生成随机文件名
            var url = host+self.randomString(length: 10)+"$$$"+imageName
            url = url.urlEncoded()
            print("url \(url)")
            // Alamofire
            var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
            defaultHeaders["Authorization"] = signString
            defaultHeaders["Content-Type"] = "multipart/form-data;"
            Alamofire.upload(
            multipartFormData:{ (multipartFormData) in
                multipartFormData.append(data as Data, withName: "fileContent")
                multipartFormData.append("upload".data(using: String.Encoding.utf8)!, withName: "op")
                multipartFormData.append("0".data(using: String.Encoding.utf8)!, withName: "insertOnly")},
             usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold,
             to:url,
             method: HTTPMethod.post,
             headers: defaultHeaders,
             encodingCompletion: { (encodingResult) in
                DispatchQueue.main.async {
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.uploadProgress { progress in
                            print(progress)
                            //                        progressCallback(progress.fractionCompleted)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KNotificationName.uploadProgressUpdate.rawValue), object: nil, userInfo: ["progress":progress])
                        }
                        upload.responseJSON { response in
                            
                            if let json = response.result.value as? [String:Any] {
                                print(json)
                                if let stateCodeInt = json["code"] as? Int {
                                    if stateCodeInt == 0{
                                        if let data = json["data"] as? [String:String]{
                                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KNotificationName.uploadSuccess.rawValue), object: nil, userInfo: data)
                                            return;
                                        }
                                    }
                                }
                            }
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KNotificationName.uploadFailure.rawValue), object: nil, userInfo: nil)
                            
                        }
                    case .failure(let encodingError):
                        print(encodingError)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: KNotificationName.uploadFailure.rawValue), object: nil, userInfo: nil)
                    }
                }
            })
           
        
            //end
        }
    }
    
    
    func caculateTencentSign() -> String? {
        // 数据
        let appid = SettingManager.shareManager.tencentSetting?.appid ?? ""
        let bucket = SettingManager.shareManager.tencentSetting?.bucketName ?? ""
        let secret_id = SettingManager.shareManager.tencentSetting?.secret_id ?? ""
        let secret_key = SettingManager.shareManager.tencentSetting?.secret_key ?? ""
        let timeArray = self.getCurrentTimestamp()
        let expireStr = timeArray.lastObject ?? ""
        let nowStr = timeArray.firstObject ?? ""
        let random = arc4random()%100000000

        // 拼装
        let original = "a=\(appid)&b=\(bucket)&k=\(secret_id)&e=\(expireStr)&t=\(nowStr)&r=\(random)&f=";
//        print("签名字符串是 \(original)")
        // 第一次HmacSHA1加密算法的封装
        let temp = original.hmac(algorithm: .SHA1, key: secret_key)
//        print("temp \(temp)")
        let originalData = NSMutableData(base64Encoded: temp, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        
        originalData?.append(original.data(using: String.Encoding.utf8)!)
        let result = originalData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
//        print("最终结果 \(result ?? "")")
        return result
    }
    
    /// 获取用户时间
    ///
    /// - Returns: 【现在时间，过期时间】
    func getCurrentTimestamp() -> NSArray {
        let date = NSDate.init(timeIntervalSinceNow: 0)
        let now = date.timeIntervalSince1970
        let expire = now + 100*24*60*60
        let nowStr = String(now)
        let expireStr = String(expire)
        return [nowStr,expireStr];
        
    }
    
    /// 随机文件名
    ///
    /// - Parameter length: 文件名长度
    /// - Returns: 文件名
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
}


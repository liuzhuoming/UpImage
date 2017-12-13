//
//  SettingManager.swift
//  UpImage
//
//  Created by 卓明 on 2017/12/7.
//  Copyright © 2017年 卓明. All rights reserved.
//

import Foundation

enum CloudType : String {
    case Tencent = "Tencent"
    case Qiniu = "Qiniu"
}

/// <Region>.file.myqcloud.com/files/v2/<appid>/<bucket_name>[/dir_name/<file_name>]
struct Tencent {
    var region: String
    var version: String
    var appid : String
    var bucketName: String
    var dirName :String
    var secret_id: String
    var secret_key: String
    var hosturl :String{
        get{
            return "http://\(self.region).file.myqcloud.com/files/\(self.version)/\(self.appid)/\(self.bucketName)/\(dirName)"
        }
    }
    var dictInfo : NSDictionary{
        get{
            return ["region":region,"version":version,"appid":appid,"bucketName":bucketName,"dirName":dirName,"secret_id":secret_id,"secret_key":secret_key]
        }
    }
    
    
    
}

class SettingManager: NSObject {
    static let shareManager = SettingManager()
    var tencentSetting : Tencent?
    var setting:[String:NSDictionary]
    var isMarkdown:Bool = false
    
    
    override init() {
        if let set = UserDefaults.standard.value(forKey: "Setting")  {
            setting = set as! [String : NSDictionary]
        }else{
            setting = [String:NSDictionary]()
        }
        self.isMarkdown = UserDefaults.standard.bool(forKey: "MarkDown")
        print(setting);
        
        if let tcDict = setting["Tencent"] {
            
            self.tencentSetting = Tencent(region: tcDict["region"] as! String,
                                          version: tcDict["version"]as! String,
                                          appid: tcDict["appid"]as! String,
                                          bucketName: tcDict["bucketName"]as! String,
                                          dirName: tcDict["dirName"]as! String,
                                          secret_id:tcDict["secret_id"]as!String,
                                          secret_key:tcDict["secret_key"]as!String )
        }
        super.init()
    }
    
    func save() {
        
        if self.tencentSetting != nil {
            self.setting[CloudType.Tencent.rawValue] = self.tencentSetting?.dictInfo
            UserDefaults.standard.set(self.setting, forKey: "Setting")
            UserDefaults.standard.synchronize()
        }
    }
    
    
}

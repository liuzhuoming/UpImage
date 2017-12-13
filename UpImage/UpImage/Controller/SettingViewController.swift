//
//  SettingViewController.swift
//  UpImage
//
//  Created by 卓明 on 2017/12/11.
//  Copyright © 2017年 卓明. All rights reserved.
//

import Cocoa

class SettingViewController: NSViewController {

    @IBOutlet weak var tfAppID: NSTextField!
    @IBOutlet weak var tfBucketName: NSTextField!
    @IBOutlet weak var tfSecret_id: NSTextField!
    @IBOutlet weak var tfSecret_key: NSTextField!
    @IBOutlet weak var tfDir: NSTextField!
    @IBOutlet weak var region: NSTextField!
    @IBOutlet weak var isMarkdown: NSButton!
    
    @IBOutlet weak var btnStatu: NSButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.btnStatu.isHidden = true
        
        if ((SettingManager.shareManager.tencentSetting?.appid) != nil) {
            // 已经设置好了
            self.tfAppID.stringValue = (SettingManager.shareManager.tencentSetting?.appid)!
            self.region.stringValue = (SettingManager.shareManager.tencentSetting?.region)!
            self.tfBucketName.stringValue = (SettingManager.shareManager.tencentSetting?.bucketName)!
            self.tfSecret_id.stringValue = (SettingManager.shareManager.tencentSetting?.secret_id)!
            self.tfSecret_key.stringValue = (SettingManager.shareManager.tencentSetting?.secret_key)!
            self.tfDir.stringValue = (SettingManager.shareManager.tencentSetting?.dirName)!
            self.isMarkdown.state = SettingManager.shareManager.isMarkdown==true ? .on:.off
        }
        
    }
    
    @IBAction func saveAction(_ sender: NSButton) {
        
        if self.tfAppID.stringValue.count>0 ,
           self.tfBucketName.stringValue.count>0,
           self.tfSecret_id.stringValue.count>0 ,
           self.tfSecret_key.stringValue.count>0,
           self.region.stringValue.count>0{
            if SettingManager.shareManager.tencentSetting == nil {
                SettingManager.shareManager.tencentSetting = Tencent(region: "", version: "", appid: "", bucketName: "", dirName: "", secret_id: "", secret_key: "")
            }
            SettingManager.shareManager.tencentSetting?.appid = self.tfAppID.stringValue
            SettingManager.shareManager.tencentSetting?.region = self.region.stringValue
            SettingManager.shareManager.tencentSetting?.bucketName = self.tfBucketName.stringValue
            SettingManager.shareManager.tencentSetting?.secret_id = self.tfSecret_id.stringValue
            SettingManager.shareManager.tencentSetting?.secret_key = self.tfSecret_key.stringValue
            SettingManager.shareManager.tencentSetting?.dirName = self.tfDir.stringValue
            SettingManager.shareManager.tencentSetting?.version = "v2"
            SettingManager.shareManager.save();
            UserDefaults.standard.set(self.isMarkdown.state == .on, forKey: "MarkDown")
            SettingManager.shareManager.isMarkdown = self.isMarkdown.state == .on
            self.showStatu(statu: "保存成功")
            
        }else{
            self.showStatu(statu: "请填写完整")
        }
    }
    
    func showStatu(statu:String) -> Void {
        self.btnStatu.title = statu
        self.btnStatu.isHidden = false;
        let walltime = DispatchWallTime.now() + 5.0
        DispatchQueue.main.asyncAfter(wallDeadline: walltime, execute: {
            self.btnStatu.isHidden = true;
            self.btnStatu.title = ""
        })
    }
    
}

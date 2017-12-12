//
//  UploadViewController.swift
//  UpImage
//
//  Created by 卓明 on 2017/12/6.
//  Copyright © 2017年 卓明. All rights reserved.
//

import Cocoa

class UploadViewController: NSViewController , NSDrawerDelegate {

    @IBOutlet weak var btnStatu: NSButton!
    @IBOutlet weak var btnAdd: NSButton!
    @IBOutlet weak var btnSetting: NSButton!
    @IBOutlet weak var btnUpload: NSButton!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var progress: NSProgressIndicator!
    //临时参数
    var urlSelect:URL?
    var imageData:NSData?
    var fileName :String?
    
    var SettingVC : SettingViewController?
    var SettingWindow : NSWindowController?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        // 获取粘贴板
        let pasteboard = NSPasteboard.general
        // 1、优先获取本地图片
        if let data = pasteboard.readObjects(forClasses: [NSURL.self], options: [NSPasteboard.ReadingOptionKey.urlReadingFileURLsOnly:true]) {
            // 过滤，其中的图片
            data.forEach({ (url) in
                    print(url)
                if let imageSelect = NSImage(contentsOf: url as! URL){
                        self.imageView.image = imageSelect
                        self.imageView.isHidden = false
                        self.btnAdd.isHidden = true
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue:NSPopoverEvent.open.rawValue), object: nil)
                        self.urlSelect = url as? URL
                        return;
                    }else{
                        print("类型不对")
                        self.showStatu(statu: "类型不对")
                    }
            })
        }
        // 再获取是否有图片 （网络？）
        if let imageArr = pasteboard.readObjects(forClasses: [NSImage.self], options: [NSPasteboard.ReadingOptionKey.urlReadingFileURLsOnly:true]) {
            print(imageArr.count)
            imageArr.forEach({ (imageData) in
                if imageData is NSImage{
                    if let image = imageData as? NSImage{
                        self.imageView.image = image
                        self.imageView.isHidden = false
                        self.imageData = image.tiffRepresentation! as NSData
                    }
                }
            })
            
        }
        
    }
    
    
    func initUI() -> Void {
        self.btnAdd.focusRingType = .none
        self.btnSetting.focusRingType = .none
        self.btnUpload.focusRingType = .none
        self.imageView.focusRingType = .none
        self.progress.doubleValue = 0
        self.btnStatu.isHidden = true
        
//        self.btnStatu.layer?.backgroundColor = NSColor.green.cgColor
        /*
         通过通知监听进度
         */
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: KNotificationName.uploadProgressUpdate.rawValue), object: nil, queue: OperationQueue.main) { (notification) in
            guard let info = notification.userInfo,
                let progress1 = info["progress"] as? Progress else{
                return;
            }
            self.progress.doubleValue =  progress1.fractionCompleted
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:KNotificationName.uploadSuccess.rawValue), object: nil, queue: OperationQueue.main) { (notification) in
            guard let data = notification.userInfo as? [String:String]else{return}
            
            self.showStatu(statu: "上传成功")
            let source_url = data["source_url"]
            let pasteboard = NSPasteboard.general
            pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
            pasteboard.setString(source_url!, forType: NSPasteboard.PasteboardType.string)
            
            
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:KNotificationName.uploadFailure.rawValue), object: nil, queue: OperationQueue.main) { (notification) in
            guard let data = notification.userInfo as? [String:String]else{return}
            guard let info = data["info"] else {
                self.showStatu(statu: "上传失败")
                return
            }
            self.showStatu(statu: info)
            
        }
        
    }
    @IBAction func uploadAction(_ sender: Any) {
        if let urlSelect = self.urlSelect {
            if let data = NSData.init(contentsOf: urlSelect) {
                UploadManager.shareManager.uploadToTencent(data: data, fileName: (self.urlSelect?.lastPathComponent)!, progressCallback: { (progress) in
                    self.progress.doubleValue = progress
                })
            }
        }else if self.imageData != nil{
            UploadManager.shareManager.uploadToTencent(data: self.imageData!, fileName: "", progressCallback: { (progress) in
                self.progress.doubleValue = progress
            })
        }else{
            self.showStatu(statu: "请选择文件")
        }
        
    }
    @IBAction func addImageAction(_ sender: NSButton) {
        let open = NSOpenPanel()
        open.canChooseFiles = true
        open.canChooseDirectories = false
        open.allowsMultipleSelection = false
        open.begin { (result:NSApplication.ModalResponse) in
            if result == NSApplication.ModalResponse.OK{
                open.urls.forEach({ (url) in
                    print(url)
                    if let imageSelect = NSImage(contentsOf: url){
                        self.imageView.image = imageSelect
                        self.imageView.isHidden = false
                        self.btnAdd.isHidden = true
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue:NSPopoverEvent.open.rawValue), object: nil)
                        self.urlSelect = url
                    }else{
                        print("类型不对")
                    }
                })
            }
        }
    }
    
    /// 设置action
    ///
    /// - Parameter sender: Setting button
    @IBAction func SettingAction(_ sender: NSButton) {
        
        if self.SettingWindow == nil {
            let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
            guard let settingWC = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "SettingWindowController")) as? NSWindowController else {
                fatalError("Error getting SettingWindowController ")
                
                
            }
            self.SettingWindow = settingWC;
        }
        self.SettingWindow?.showWindow(self);
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

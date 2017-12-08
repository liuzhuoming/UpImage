//
//  UploadViewController.swift
//  UpImage
//
//  Created by 卓明 on 2017/12/6.
//  Copyright © 2017年 卓明. All rights reserved.
//

import Cocoa

class UploadViewController: NSViewController {

    @IBOutlet weak var btnStatu: NSButton!
    @IBOutlet weak var btnAdd: NSButton!
    @IBOutlet weak var btnSetting: NSButton!
    @IBOutlet weak var btnUpload: NSButton!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var progress: NSProgressIndicator!
    
    var urlSelect:URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
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
//            NSPasteboard *paste = [NSPasteboard generalPasteboard];
//            [paste clearContents];
//            [paste writeObjects:@[@"123"]];
            let source_url = data["source_url"]
            let pasteboard = NSPasteboard.general
            pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
            pasteboard.setString(source_url!, forType: NSPasteboard.PasteboardType.string)
            
            
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue:KNotificationName.uploadFailure.rawValue), object: nil, queue: OperationQueue.main) { (notification) in

            self.showStatu(statu: "上传失败")
            
        }
        
    }
    @IBAction func uploadAction(_ sender: Any) {
        if let urlSelect = self.urlSelect {
            if let data = NSData.init(contentsOf: urlSelect) {
                UploadManager.shareManager.uploadToTencent(data: data, fileName: (self.urlSelect?.lastPathComponent)!, progressCallback: { (progress) in
                    self.progress.doubleValue = progress
                })
            }
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

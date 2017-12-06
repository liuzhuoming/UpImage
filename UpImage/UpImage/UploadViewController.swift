//
//  UploadViewController.swift
//  UpImage
//
//  Created by 卓明 on 2017/12/6.
//  Copyright © 2017年 卓明. All rights reserved.
//

import Cocoa

class UploadViewController: NSViewController {

    @IBOutlet weak var btnAdd: NSButton!
    
    @IBOutlet weak var imageView: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                    }else{
                        print("类型不对")
                    }
                })
            }
        }
    }
    
   
}

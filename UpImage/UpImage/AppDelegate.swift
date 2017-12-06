//
//  AppDelegate.swift
//  UpImage
//
//  Created by 卓明 on 2017/12/6.
//  Copyright © 2017年 卓明. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    var statuItem : NSStatusItem!
    var popview : NSPopover!
    var uploadViewController:NSViewController?
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        self.addStatuItem();
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func addStatuItem() -> Void {
        let statubar = NSStatusBar.system
        self.statuItem = statubar.statusItem(withLength: NSStatusItem.squareLength)
        self.statuItem.image = NSImage.init(named: NSImage.Name(rawValue: "upload"))
        self.statuItem.toolTip = "拖拽图片到图标附近即可上传"
//        self.statuItem.action = #selector(statuAction)
        self.statuItem.button?.action = #selector(statuAction(btn:))
        
    }

    
    @objc func statuAction(btn:NSButton) -> Void {
        print("statuAction")
        if self.uploadViewController == nil  {
//            self.UploadViewController = NSViewController(nibName: NSNib.Name(rawValue: "UploadViewController"), bundle: Bundle.main)
            self.uploadViewController = UploadViewController(nibName: NSNib.Name(rawValue: "UploadViewController"), bundle: Bundle.main)
        }
        if self.popview == nil {
            self.popview = NSPopover()
            self.popview.appearance = NSAppearance(appearanceNamed: NSAppearance.Name.aqua, bundle: nil)
            self.popview.contentViewController = self.uploadViewController
            self.popview.behavior = NSPopover.Behavior.semitransient
            self.popview.contentSize = CGSize(width: 230, height: 219)
        }
//        NSApplication.shared.activate(ignoringOtherApps: true)
        self.popview.show(relativeTo:btn.bounds, of: btn, preferredEdge: NSRectEdge.maxY)
    }

}


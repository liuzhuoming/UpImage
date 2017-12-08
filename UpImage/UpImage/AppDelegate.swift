//
//  AppDelegate.swift
//  UpImage
//
//  Created by 卓明 on 2017/12/6.
//  Copyright © 2017年 卓明. All rights reserved.
//

import Cocoa

enum NSPopoverEvent:String {
    case open = "NSPopoverEvent.open"
    case close = "NSPopoverEvent.close"
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate,NSPopoverDelegate {

    @IBOutlet weak var window: NSWindow!
    public var statuItem : NSStatusItem!
    var popview : NSPopover!
    var uploadViewController:NSViewController?
    var popoverTransiencyMonitor :AnyObject?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        self.addStatuItem();
        
        
        UploadManager.shareManager.caculateTencentSign();
        
        weak var weakSelf = self
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NSPopoverEvent.open.rawValue), object: nil, queue: OperationQueue.main) { (noti) in
            weakSelf?.openPopover(btn: (weakSelf?.statuItem.button)!)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NSPopoverEvent.close.rawValue), object: nil, queue: OperationQueue.main) { (noti) in
            weakSelf?.closePopover()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func addStatuItem() -> Void {
        let statubar = NSStatusBar.system
        self.statuItem = statubar.statusItem(withLength: NSStatusItem.squareLength)
        self.statuItem.image = NSImage.init(named: NSImage.Name(rawValue: "upload"))
        self.statuItem.toolTip = "拖拽图片到图标附近即可上传"
        self.statuItem.button?.action = #selector(openPopover(btn:))
        if self.uploadViewController == nil  {
            self.uploadViewController = UploadViewController(nibName: NSNib.Name(rawValue: "UploadViewController"), bundle: Bundle.main)
        }
        if self.popview == nil {
            self.popview = NSPopover()
            self.popview.appearance = NSAppearance(appearanceNamed: NSAppearance.Name.aqua, bundle: nil)
            self.popview.contentViewController = self.uploadViewController
            self.popview.behavior = NSPopover.Behavior.transient
            self.popview.contentSize = CGSize(width: 230, height: 219)
            self.popview.delegate = self
        }

    }

    
    @objc func openPopover(btn:NSButton) -> Void {
        print("statuAction")
        self.popview.show(relativeTo:btn.bounds, of: btn, preferredEdge: NSRectEdge.maxY)

        self.popoverTransiencyMonitor = NSEvent.addGlobalMonitorForEvents(matching: [NSEvent.EventTypeMask.leftMouseDown,NSEvent.EventTypeMask.rightMouseDown], handler: { (event) in
            self.closePopover()
        }) as AnyObject
    }
    
    @objc func closePopover() -> Void {
        if let popEvent = self.popoverTransiencyMonitor {
            NSEvent.removeMonitor(popEvent)
            self.popoverTransiencyMonitor = nil
             self.popview.close()
        }
       
    }
    

}


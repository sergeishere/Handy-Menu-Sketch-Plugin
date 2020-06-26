//
//  ShortcutController.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 18/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//
public protocol ShortcutControllerDelegate: class {
    func shortcutController(_ shortcutController: ShortcutController, didRecognize shortcut: Shortcut, in event: NSEvent) -> NSEvent?
}

public class ShortcutController {
    
    // MARK: - Private Variables
    private var keyDownMonitor:Any?
    private var keyUpMonitor:Any?
    
    // MARK: - Public Variables
    public var currentShortcut = Shortcut.empty
    public weak var delegate: ShortcutControllerDelegate?
    
    public var isEnabled: Bool = false
    
    // MARK: - Instance Lifecycle
    public init() {
        keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] (event) -> NSEvent? in
            if let strongSelf = self,
                strongSelf.isEnabled,
                let delegate = strongSelf.delegate {
                strongSelf.currentShortcut.keyCode = Int(event.keyCode)
                strongSelf.currentShortcut.character = event.charactersIgnoringModifiers ?? ""
                strongSelf.currentShortcut.modifierFlags = [event.modifierFlags.contains(.command) ? .command : [],
                                                            event.modifierFlags.contains(.option) ? .option : [],
                                                            event.modifierFlags.contains(.control) ? .control : [],
                                                            event.modifierFlags.contains(.shift) ? .shift : []]
                return delegate.shortcutController(strongSelf, didRecognize: strongSelf.currentShortcut, in: event)
            }
            
            return event
        }
        
        keyUpMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyUp) { [weak self](event) -> NSEvent? in
            self?.currentShortcut.keyCode = 0
            self?.currentShortcut.character = ""
            return event
        }
    }
    
    public func start() {
        self.isEnabled = true
        plugin_log("Shortcut controller is ON")
    }
    
    public func stop() {
        self.isEnabled = false
        plugin_log("Shortcut controller is OFF")
    }
}

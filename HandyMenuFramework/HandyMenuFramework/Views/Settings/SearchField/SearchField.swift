//
//  SearchField.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 03/08/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

protocol SearchFieldDelegate: class {
    func searchField(_ searchField: SearchField, didChanged value: String)
}

class SearchField: NSView, NSTextFieldDelegate {
    
    // MARK: - View States
    private enum State {
        case active, inactive
    }

    // MARK: - Outlets
    @IBOutlet private var contentView: NSBox!
    @IBOutlet private weak var textField: ResponsiveTextField!
    @IBOutlet private weak var clearButton: NSButton!
    @IBOutlet private weak var searchIcon: NSImageView!
    
    // MARK: - Private Variables
    private var state: State = .inactive
    
    // MARK: - Public Variables
    public weak var delegate: SearchFieldDelegate?
    public var stringValue: String {
        set {
            self.textField.stringValue = newValue
            let isEmpty = (newValue.count == 0)
            self.clearButton.isHidden = isEmpty
            self.delegate?.searchField(self, didChanged: newValue)
        }
        get {
            return self.textField.stringValue
        }
    }
    
    // MARK: - Lifecycle
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        if let nib = NSNib(nibNamed: .searchField, bundle: Bundle(for: type(of: self))) {
            nib.instantiate(withOwner: self, topLevelObjects: nil)
            self.prepare()
        }
    }
    
    // MARK: - Instance Methods
    private func prepare() {
        self.addSubview(self.contentView)
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.width,.height]
        self.textField.delegate = self
        self.render(for: .inactive)
        self.textField.onFocus = { [unowned self] in
            self.state = .active
            self.render(for: .active)
        }
        
        self.textField.onBlur = { [unowned self] in
            self.state = .inactive
            self.render(for: .inactive)
        }
        
        if let cell = self.textField.cell as? SearchFieldTextFieldCell {
            cell.leftPadding = 32.0
            cell.rightPadding = 32.0
        }
    }
    
    private func render(for state: State) {
        switch state {
        case .active:
            if #available(OSX 10.14, *) {
                self.contentView.borderColor = NSColor.controlAccentColor
                self.searchIcon.contentTintColor = NSColor.controlAccentColor
            } else {
                self.contentView.borderColor = NSColor.alternateSelectedControlColor
                self.searchIcon.image = NSImage.searchIconImage?.tinted(by: NSColor.alternateSelectedControlColor)
            }
        case .inactive:
            self.contentView.borderColor = NSColor.gridColor
            if #available(OSX 10.14, *) {
                self.searchIcon.contentTintColor = NSColor.gridColor
            } else {
                self.searchIcon.image = NSImage.searchIconImage?.tinted(by: NSColor.gridColor)
            }
        }
        self.needsDisplay = true
    }
    
    func controlTextDidChange(_ obj: Notification) {
        self.stringValue = self.textField.stringValue
    }
    
    @IBAction func clear(_ sender: Any) {
        self.stringValue = ""
    }
}


class ResponsiveTextField: NSTextField {
    
    public var onFocus: (() -> Void)?
    public var onBlur: (() -> Void)?
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        self.onFocus?()
    }
    
    override func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)
        self.onBlur?()
    }
}

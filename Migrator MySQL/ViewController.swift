//
//  ViewController.swift
//  Migrator MySQL
//
//  Created by Алихан on 13/02/2020.
//  Copyright © 2020 Nexen Origin, LLC. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    //MARK: - Outlets -
    @IBOutlet weak var pathTextField: NSTextField!
    @IBOutlet weak var mySqlTextView: NSTextView!
    @IBOutlet weak var resultLabel: NSTextField!
    @IBOutlet weak var migrationsCheckbox: NSButton!
    @IBOutlet weak var modelsCheckbox: NSButton!
    @IBOutlet weak var authCheckbox: NSButton!
    @IBOutlet weak var authTextField: NSTextField!
    
    
    //MARK: - Lyfecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    //MARK: - Actions

    @IBAction func choosePathButtonAction(_ sender: Any) {
        
        let openPanel = NSOpenPanel();
        openPanel.title = "Select a folder to save generated migrations"
        openPanel.showsResizeIndicator=true;
        openPanel.canChooseDirectories = true;
        openPanel.canChooseFiles = false;
        openPanel.allowsMultipleSelection = false;
        openPanel.canCreateDirectories = true;
        
        
        openPanel.begin { (result) -> Void in
            if(result.rawValue == NSApplication.ModalResponse.OK.rawValue){
                if let path = openPanel.url?.path {
                    self.pathTextField.stringValue = path
                }
            }
        }
        
    }
    
    @IBAction func generateButtonAction(_ sender: Any) {
        if self.pathTextField.stringValue != "" && self.mySqlTextView.string != "" {
            let generator = Generator(path: self.pathTextField.stringValue, sqlCode: self.mySqlTextView.string, isMigrationsNeeded: self.migrationsCheckbox.state == NSControl.StateValue.on, isModelsNeeded: self.modelsCheckbox.state == NSControl.StateValue.off, isAuthTableDefined: false, authTableName: "")
            generator.delegate = self
            generator.start()
        } else {
            self.resultLabel.textColor = .red
            self.resultLabel.stringValue = "Path and SQL-code can't be empty"
        }
        
    }
    
}


//MARK: GeneratorDelegate

extension ViewController: GeneratorDelegate {
    func generationDoneWith(fail: Bool, message: String?) {
        if fail {
            self.resultLabel.stringValue = message ?? "Something went wrong"
            self.resultLabel.textColor = .red
        } else {
            self.resultLabel.stringValue = "Done!"
            self.resultLabel.textColor = .green
        }
    }
}

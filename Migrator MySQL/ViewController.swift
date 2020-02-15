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
            let generator = MigrationsGenerator(path: self.pathTextField.stringValue, sqlCode: self.mySqlTextView.string)
            generator.delegate = self
            generator.start()
        } else {
            self.resultLabel.textColor = .red
            self.resultLabel.stringValue = "Path and SQL-code can't be empty"
        }
        
    }
    
}


//MARK: MigrationsGeneratorDelegate

extension ViewController: MigrationsGeneratorDelegate {
    func generationDoneWith(fail: Bool) {
        if fail {
            self.resultLabel.stringValue = "Something went wrong :("
            self.resultLabel.textColor = .red
        } else {
            self.resultLabel.stringValue = "Done!"
            self.resultLabel.textColor = .green
        }
    }
}

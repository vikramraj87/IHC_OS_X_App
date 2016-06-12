//
//  CreateDiagnosisViewController.swift
//  IHC App
//
//  Created by Vikram Raj Gopinathan on 12/06/16.
//  Copyright © 2016 Kivi. All rights reserved.
//

import Cocoa

class CreateDiagnosisViewController: NSViewController {
    var category: Category!
    
    dynamic var icdoCode = ICDOCode(morphologyCode: 1000, behaviorCode: 0)
    dynamic var name = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

extension CreateDiagnosisViewController: NSTextFieldDelegate {
    override func controlTextDidChange(obj: NSNotification) {
        let userInfo = obj.userInfo!
        print(userInfo)
    }
}
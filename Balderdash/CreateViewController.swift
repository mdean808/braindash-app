//
//  CreateViewController.swift
//  Balderdash
//
//  Created by Morgan Dean on 1/7/19.
//  Copyright © 2019 Morgan Dean. All rights reserved.
//

import UIKit
import ChameleonFramework
import LGButton
import GradientView
import SnapKit

class CreateViewController: UIViewController {

    // UI Views
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var actionView: UIView!
    @IBOutlet  weak var infoView: UIView!
    
    // Text Fields
    @IBOutlet weak var nick: UITextField!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.nick = nil
        appDelegate.thisPlayer = nil
        appDelegate.game = nil
        
        setupUI()
        
        setupKeyboard()
        
        setupSnapKit()

    }
    
    // Button actions
    @IBAction func submitGame(_ sender: LGButton) {
        appDelegate.nick = nick.text
        loadOtherView(viewName: "gameSetup", animationType: "page")
    }
    
    @IBAction func goBack(_ sender: LGButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // UI
    
    func setupUI() {

        // Initialize a gradient view
        let gradientView = GradientView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        gradientView.colors = [UIColor(hexString: "#5a85b3"), UIColor(hexString: "#ff6b6b")] as? [UIColor]
        gradientView.locations = [0.01, 0.9]
        gradientView.direction = .vertical
        self.view.addSubview(gradientView)
        self.view.sendSubviewToBack(gradientView)
        
    }
    
    // Snapkit
    
    func setupSnapKit() {
        titleView.snp.makeConstraints { (make)  in
            make.width.equalTo(319)
            make.height.equalTo(103)
            make.centerX.equalToSuperview()
            make.top.equalTo(30)
        }
        
        actionView.snp.makeConstraints{ (make) in
            make.width.equalTo(205)
            make.height.equalTo(142)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-20)
        }
        infoView.snp.makeConstraints{ (make) in
            make.width.equalTo(343)
            make.height.equalTo(181)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            
        }
    }
    
    // Misc Functions
    
    func loadOtherView(viewName: String, animationType: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view : UIViewController = storyboard.instantiateViewController(withIdentifier: viewName)
        if animationType == "page" {
            view.modalTransitionStyle = .crossDissolve
        }
        self.present(view, animated: true, completion: nil)
    }
    
    // Keyboard
    
    func setupKeyboard() {
        let toolbarDone = UIToolbar.init()
        toolbarDone.sizeToFit()
        let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(hideKeyboard))
        
        toolbarDone.items = [barBtnDone] // You can even add cancel button too
        toolbarDone.barStyle = .black
        nick.inputAccessoryView = toolbarDone

    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return range.location < 15
    }
    
    @objc func hideKeyboard() {
        nick.resignFirstResponder()

    }
}

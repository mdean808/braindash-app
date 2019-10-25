//
//  JoinViewController.swift
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
import Starscream

class JoinViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var actionView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var joinButton: LGButton!
    
    @IBOutlet weak var code: UITextField!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var gameCode: Int = 000000, nick: String = "Player", codeLength = 6

    override func viewDidLoad() {
        super.viewDidLoad()
        code.delegate = self
        // Initialize a gradient view
        let gradientView = GradientView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        
        // Set the gradient colors
        gradientView.colors = [UIColor(hexString: "#d38312"), UIColor(hexString: "#a83279")] as? [UIColor]
        
        gradientView.locations = [0.01, 0.9]
        
        // Optionally change the direction. The default is vertical.
        gradientView.direction = .vertical
        
        // Add it as a subview in all of its awesome
        self.view.addSubview(gradientView)
        self.view.sendSubviewToBack(gradientView)
        // Do any additional setup after loading the view.
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
        let toolbarDone = UIToolbar.init()
        toolbarDone.sizeToFit()
        let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(hideKeyboard))
        
        toolbarDone.items = [barBtnDone] // You can even add cancel button too
        toolbarDone.barStyle = .black
        code.inputAccessoryView = toolbarDone
    }
    
    @IBAction func submitCode(_ sender: LGButton) {
        UIApplication.shared.isIdleTimerDisabled = true

        if self.joinButton.titleString == "Next" {
            if self.code.text != "" {
                gameCode = Int(self.code.text!)!
                self.code.keyboardType = .default
                self.code.placeholder = "Nickname"
                self.code.text = ""
                self.code.autocapitalizationType = .none
                self.codeLength = 15
                self.joinButton.titleString = "Join"
            } else {
                let alert = UIAlertController(title: "Error", message: "Please submit a code.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(alert, animated: true)
            }
        } else {
            if self.code.text != "" {
                nick = self.code.text!
                let randNum = Int.random(in: 0 ..< 10)
                appDelegate.socket = WebSocket(url: URL(string: "ws://159.89.129.98:3420/game/\(gameCode)/\(nick.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "Player\(randNum)")")!)
                appDelegate.socket.respondToPingWithPong = true
                appDelegate.nick = nick
                loadOtherView(viewName: "joinLobby")
            } else {
                let alert = UIAlertController(title: "Error", message: "Please submit a nickname.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(alert, animated: true)
            }
        }
    }
    
    @IBAction func goBack(_ sender: LGButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadOtherView(viewName:String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view : UIViewController = storyboard.instantiateViewController(withIdentifier: viewName)
        self.present(view, animated: true, completion: nil)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return range.location < codeLength
    }
    @objc func hideKeyboard() {
        code.resignFirstResponder()
    }
}

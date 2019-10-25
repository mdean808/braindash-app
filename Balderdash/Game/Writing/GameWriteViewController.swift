//
//  GameWriteViewController.swift
//  Balderdash
//
//  Created by Morgan Dean on 1/14/19.
//  Copyright © 2019 Morgan Dean. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SnapKit
import ChameleonFramework
import LGButton
import SwiftyJSON
import Hero
import FontAwesome_swift

class GameWriteViewController: UIViewController {
    
    @IBOutlet weak var cardQuestion: UILabel!
    @IBOutlet weak var responseDesc: UILabel!
    @IBOutlet weak var cardResponse: UITextView!
    @IBOutlet weak var submitButton: LGButton!
    @IBOutlet weak var leaveButton: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true

        setupKeyboard()
        leaveButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 24, style: .solid)
        leaveButton.setTitle(String.fontAwesomeIcon(name: .times), for: .normal)
        leaveButton.tintColor = .white
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: self.view.window)
        
        leaveButton.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.top.equalToSuperview().offset(35)
        }
        
        if appDelegate.thisPlayer!.role != "dasher" {
            cardQuestion.text = appDelegate.game!.card?.text
            
            cardQuestion.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.top.equalTo(leaveButton.snp.bottom).offset(25)
            }
            
            responseDesc.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(10)
                make.height.equalTo(20)
                make.top.equalTo(cardQuestion.snp.bottom).offset(70)
            }
            
            cardResponse.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.height.equalTo(150)
                make.top.equalTo(responseDesc.snp.bottom).offset(10)
            }
            
            submitButton.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.width.equalTo(187)
                make.height.equalTo(52)
                make.bottom.equalToSuperview().offset(-20)
            }
        } else {
            cardQuestion.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.top.equalTo(leaveButton.snp.bottom).offset(25)
            }
            cardQuestion.text = "Please wait while the other players formulate their responses."
            responseDesc.isHidden = true
            cardResponse.isHidden = true
            submitButton.isHidden = true
            
            let frame = CGRect(x: 10, y: 200, width: 50, height: 50)
            let activityIndicatorView = NVActivityIndicatorView(frame: frame, type: .ballPulseSync)
            self.view.addSubview(activityIndicatorView)
            
            activityIndicatorView.snp.makeConstraints{ (make) in
                make.width.equalTo(50)
                make.height.equalTo(50)
                make.center.equalToSuperview()
            }
            
            activityIndicatorView.startAnimating()
        }
        appDelegate.socket.onText = { (text: String) in
            print("Write: got some text: \(text)")
            //
            if let dataFromString = text.data(using: .utf8, allowLossyConversion: false) {
                do {
                    let res = try JSON(data: dataFromString)
                    if res["type"] == "game" {
                        var users = [Player]();
                        for (_, user):(String, JSON) in res["content"]["users"] {
                            users += [Player(nick: user["nick"].string!, points: user["points"].int!, host: user["host"].bool!, role: user["role"].string!)]
                            if user["nick"].string! == self.appDelegate.nick {
                                self.appDelegate.thisPlayer = Player(nick: user["nick"].string!, points: user["points"].int!, host: user["host"].bool!, role: user["role"].string!)
                            }
                        }
                        
                        
                        if res["content"]["state"] != "creating" || res["content"]["state"] != "starting" {
                            let card = Card(text: res["content"]["card"]["text"].string!, answer: res["content"]["card"]["answer"].string!, id: res["content"]["card"]["id"].int!)
                            var responses = [Response]();
                            for (_, response):(String, JSON) in res["content"]["responses"] {
                                var votes = [Vote]()
                                 for (_, vote):(String, JSON) in response["votes"] {
                                    votes += [Vote(nick: vote["nick"].string!)]
                                }
                                responses += [Response(text: response["text"].string!, votes: votes, isAnswer: response["isAnswer"].bool!)]
                            }
                            self.appDelegate.game = Game(card: card, code: res["content"]["code"].int!, responses: responses, state: res["content"]["state"].string!, users: users)
                            if self.appDelegate.game?.state == "picking" {
                                let gameView = self.selectView(viewName: "gamePick")
                                gameView.hero.isEnabled = true
                                gameView.hero.modalAnimationType = .zoomSlide(direction: .left)
                                self.present(gameView, animated: true, completion: nil)
                            } else if self.appDelegate.game?.state == "intermission" {
                                let gameView = self.selectView(viewName: "gameIntermission")
                                gameView.hero.isEnabled = true
                                gameView.hero.modalAnimationType = .zoomSlide(direction: .left)
                                self.present(gameView, animated: true, completion: nil)
                            }
                            
                        } else {
                            self.appDelegate.game = Game(card: nil, code: res["content"]["code"].int!, responses: [Response](), state: res["content"]["state"].string!, users: users)
                        }
                    }
                } catch let error {
                    print(error)
                }
            }
        }
    }

    @IBAction func leaveGame(_ sender: Any) {
        appDelegate.socket.disconnect()
        loadOtherView(viewName: "home")
    }
    
    @IBAction func submitResponse(_ sender: Any) {
        let responseData = "{ \"type\": \"response\", \"content\": { \"text\": \"\(cardResponse!.text!.trimmingCharacters(in: .whitespacesAndNewlines))\" }}"
        appDelegate.socket.write(string: responseData)
        cardQuestion.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(66)
        }
        cardQuestion.text = "Please wait while the other players formulate their responses."
        responseDesc.isHidden = true
        cardResponse.isHidden = true
        submitButton.isHidden = true
        
        let frame = CGRect(x: 10, y: 200, width: 50, height: 50)
        let activityIndicatorView = NVActivityIndicatorView(frame: frame, type: .ballPulseSync)
        self.view.addSubview(activityIndicatorView)
        
        activityIndicatorView.snp.makeConstraints{ (make) in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.center.equalToSuperview()
        }
        
        activityIndicatorView.startAnimating()
        
        
    }
    
    func loadOtherView(viewName:String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view : UIViewController = storyboard.instantiateViewController(withIdentifier: viewName)
        self.present(view, animated: true, completion: nil)
    }
    func selectView(viewName: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: viewName)
    }
    
    func setupKeyboard() {
        let toolbarDone = UIToolbar.init()
        toolbarDone.sizeToFit()
        let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(hideKeyboard))
        
        toolbarDone.items = [barBtnDone] // You can even add cancel button too
        toolbarDone.barStyle = .black
        cardResponse.inputAccessoryView = toolbarDone
        
    }
    
    @objc func hideKeyboard() {
        cardResponse.resignFirstResponder()
        
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        let userInfo: [AnyHashable : AnyObject] = sender.userInfo! as [AnyHashable : AnyObject]
        let keyboardSize: CGSize = userInfo[UIResponder.keyboardFrameBeginUserInfoKey]!.cgRectValue.size
        let offset: CGSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey]!.cgRectValue.size
        
        if keyboardSize.height == offset.height {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.view.frame.origin.y -= keyboardSize.height
            })
        } else {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.view.frame.origin.y += keyboardSize.height - offset.height - 34
            })
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
    }
}

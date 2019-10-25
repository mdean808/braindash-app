//
//  GameDasherViewController.swift
//  Balderdash
//
//  Created by Morgan Dean on 1/12/19.
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

class GameDasherViewController: UIViewController {

    @IBOutlet var dasherImage: UIView!
    @IBOutlet weak var waitLabel: UILabel!
    @IBOutlet weak var submitButton: LGButton!
    @IBOutlet weak var leaveButton: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let viewTitle = UILabel()
    let cardQuestionBox = UITextView()
    let cardQuestionText = UILabel()
    let cardAnswerBox = UITextView()
    let cardAnswerText = UILabel()
    
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
        
        if appDelegate.thisPlayer?.role == "dasher" {
            dasherImage.isHidden = true
            waitLabel.isHidden = true
            
            viewTitle.text = "Create a Card"
            viewTitle.textAlignment = .center
            viewTitle.textColor = UIColor(hexString: "5F42C0")
            viewTitle.font = UIFont(name: "Futura", size: 38)
            
            self.view.addSubview(viewTitle)
        
            cardQuestionText.text = "Please type the question below."
            cardQuestionText.font = UIFont(name: "Futura", size: 12)
            cardQuestionText.textColor = .white

            cardAnswerText.text = "Please type the answer below."
            cardAnswerText.font = UIFont(name: "Futura", size: 12)
            cardAnswerText.textColor = .white

            self.view.addSubview(cardQuestionBox)
            self.view.addSubview(cardQuestionText)
            self.view.addSubview(cardAnswerBox)
            self.view.addSubview(cardAnswerText)
            
            viewTitle.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.width.equalToSuperview()
                make.top.equalTo(leaveButton.snp.bottom).offset(5)
                make.height.equalTo(45)
            }
            
            cardQuestionText.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.left.equalToSuperview().offset(10)
                make.top.equalTo(viewTitle.snp.bottom).offset(20)
                make.height.equalTo(20)
            }
            cardQuestionBox.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.left.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.top.equalTo(cardQuestionText.snp.bottom).offset(5)
                make.height.equalTo(100)
            }


            
            cardAnswerText.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.left.equalToSuperview().offset(10)
                make.top.equalTo(cardQuestionBox.snp.bottom).offset(20)
                make.height.equalTo(20)
            }
            cardAnswerBox.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.left.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.top.equalTo(cardAnswerText.snp.bottom).offset(5)
                make.height.equalTo(100)
            }
            
            submitButton.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.width.equalTo(187)
                make.height.equalTo(52)
                make.top.equalTo(cardAnswerBox.snp.top).offset(175)
                make.bottom.equalToSuperview().offset(-50)
            }
            
            
            cardQuestionBox.keyboardAppearance = .dark
            cardAnswerBox.keyboardAppearance = .dark
            
        } else {
            submitButton.isHidden = true
            
            let frame = CGRect(x: 10, y: 200, width: 50, height: 50)
            let activityIndicatorView = NVActivityIndicatorView(frame: frame, type: .ballPulseSync)
            self.view.addSubview(activityIndicatorView)
            
            activityIndicatorView.snp.makeConstraints{ (make) in
                make.width.equalTo(50)
                make.height.equalTo(50)
                make.centerX.equalToSuperview()
                make.bottom.equalTo(-60)
            }
            
            dasherImage.snp.makeConstraints{ (make) in
                make.width.equalTo(150)
                make.height.equalTo(150)
                make.center.equalToSuperview()
            }
            
            waitLabel.snp.makeConstraints{ (make) in
                make.width.equalToSuperview()
                make.height.equalTo(30)
                make.centerX.equalToSuperview()
                make.bottom.equalTo(-30)
            }
    
            activityIndicatorView.startAnimating()

                // Do any additional setup after loading the view.
        }
        
        appDelegate.socket.onText = { (text: String) in
            //
            if let dataFromString = text.data(using: .utf8, allowLossyConversion: false) {
                do {
                    let res = try JSON(data: dataFromString)
                    if res["type"] == "game" {
                        var users = [Player]();
                        print(res["content"]["state"])

                        for (_, user):(String, JSON) in res["content"]["users"] {
                            users += [Player(nick: user["nick"].string!, points: user["points"].int!, host: user["host"].bool!, role: user["role"].string!)]
                            if user["nick"].string! == self.appDelegate.nick {
                                self.appDelegate.thisPlayer = Player(nick: user["nick"].string!, points: user["points"].int!, host: user["host"].bool!, role: user["role"].string!)
                            }
                        }
                        if res["content"]["state"] == "writing" {
                            let card = Card(text: res["content"]["card"]["text"].string!, answer: res["content"]["card"]["answer"].string!, id: res["content"]["card"]["id"].int!)
                            self.appDelegate.game = Game(card: card, code: res["content"]["code"].int!, responses: [Response](), state: res["content"]["state"].string!, users: users)
                            let gameView = self.selectView(viewName: "gameWrite")
                            gameView.hero.isEnabled = true
                            gameView.hero.modalAnimationType = .zoomSlide(direction: .left)
                            self.present(gameView, animated: true, completion: nil)
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
    

    @IBAction func submitCard(_ sender: Any) {
        if cardQuestionBox.text != "" || cardAnswerText.text != "" {
            let cardData = "{ \"type\": \"card\",\"content\": { \"text\": \"\(cardQuestionBox.text!.trimmingCharacters(in: .whitespacesAndNewlines))\", \"answer\": \"\(cardAnswerBox.text!.trimmingCharacters(in: .whitespacesAndNewlines))\"}}"
            appDelegate.socket.write(string: cardData)
        } else {
            let alert = UIAlertController(title: "Error", message: "Please fill out all the boxes.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    func selectView(viewName: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: viewName)
    }

    @IBAction func leaveGame(_ sender: Any) {
        appDelegate.socket.disconnect()
        loadOtherView(viewName: "home")
    }
    func loadOtherView(viewName:String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view : UIViewController = storyboard.instantiateViewController(withIdentifier: viewName)
        self.present(view, animated: true, completion: nil)
    }
    
    func setupKeyboard() {
        let toolbarDone = UIToolbar.init()
        toolbarDone.sizeToFit()
        let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(hideKeyboard))
        
        toolbarDone.items = [barBtnDone] // You can even add cancel button too
        toolbarDone.barStyle = .black
        cardQuestionBox.inputAccessoryView = toolbarDone
        cardAnswerBox.inputAccessoryView = toolbarDone

    }
    
    @objc func hideKeyboard() {
        cardQuestionBox.resignFirstResponder()
        cardAnswerBox.resignFirstResponder()

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

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
import Starscream
import SwiftyJSON
import Hero

struct Game {
    var card: Card?
    var code: Int
    var responses = [Response]()
    var state: String
    var users = [Player]()
}

struct Player {
    var nick: String
    var points: Int
    var host: Bool
    var role: String
    
}

struct Card {
    var text: String
    var answer: String
    var id: Int
    
}

struct Response {
    var text: String
    var votes = [Vote]()
    var isAnswer: Bool
}

struct Vote {
    var nick: String
}


class SetupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // UI Views
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var actionView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playersCount: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var nick: String?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        UIApplication.shared.isIdleTimerDisabled = true

        setupUI()
        
        setupSnapKit()
        
        createGame()
        
    }
    
    // Button actions
    @IBAction func startGame(_ sender: LGButton) {
        appDelegate.socket.write(string: "{ \"type\": \"game_update\", \"content\": { \"text\": \"starting\"}}")
        print("wrote game starting")
        let gameView = selectView(viewName: "gameStart")
        gameView.hero.isEnabled = true
        gameView.hero.modalAnimationType = .zoom
        present(gameView, animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: LGButton) {
        appDelegate.socket.disconnect()
        loadOtherView(viewName: "home", animationType: "regular")
    }
    
    // Game
    
    func createGame() {
        nick = appDelegate.nick
        let randNum = Int.random(in: 0 ..< 10)
        appDelegate.socket = WebSocket(url: URL(string: "ws://159.89.129.98:3420/new/\(nick!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "Player\(randNum)")")!)
        appDelegate.socket.respondToPingWithPong = true

        appDelegate.socket.onConnect = {
            print("websocket is connected")
        }
        //websocketDidDisconnect
        appDelegate.socket.onDisconnect = { (error: Error?) in
            print("websocket is disconnected: \(String(describing: error))")
            self.loadOtherView(viewName: "home", animationType: "")
        }
        //websocketDidReceiveMessage
        appDelegate.socket.onText = { (text: String) in
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
                         self.appDelegate.game = Game(card: nil, code: res["content"]["code"].int!, responses: [Response](), state: res["content"]["state"].string!, users: users)
                        self.codeLabel.text = String(self.appDelegate.game!.code)
                        self.tableView.reloadData()
                    }
                } catch let error {
                    print(error)
                }
            }

        }
        //websocketDidReceiveData
        appDelegate.socket.onData = { (data: Data) in
            print("got some data: \(data.count)")
        }
        appDelegate.socket.connect()
    }
    
    // UI
    
    func setupUI() {
        
        // Initialize a gradient view
        let gradientView = GradientView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        gradientView.colors = [UIColor(hexString: "#38ef7d"), UIColor(hexString: "#11998e")] as? [UIColor]
        gradientView.locations = [0.01, 0.9]
        gradientView.direction = .vertical
        self.view.addSubview(gradientView)
        self.view.sendSubviewToBack(gradientView)
        
        tableView.layer.borderWidth = 0.4
        tableView.layer.cornerRadius = 10
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
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(titleView.snp.bottom).offset(10)
            make.bottom.equalTo(actionView.snp.top).offset(-10)
            make.centerX.equalToSuperview()
        }
        
    }
    
    // Misc Functions
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    
    func loadOtherView(viewName: String, animationType: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view : UIViewController = storyboard.instantiateViewController(withIdentifier: viewName)
        if animationType == "page" {
            view.modalTransitionStyle = .crossDissolve
        }
        
        if animationType == "cancel" {
            view.modalTransitionStyle = .flipHorizontal
        }
        self.present(view, animated: true, completion: nil)
    }
    
    func selectView(viewName: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: viewName)
    }
    
    // Player List
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.appDelegate.game?.users.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.playersCount.text = "Players - \( self.appDelegate.game?.users.count ?? 0)"
        let cellIdentifier = "PlayerTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PlayerTableViewCell
        let user =  self.appDelegate.game?.users[indexPath.row]
        if user!.nick == nick {
            cell!.nickLabel.text = "\(user!.nick) (You)"
        } else {
            cell!.nickLabel.text = user!.nick
        }
        return cell!
    }
    
}

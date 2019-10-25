//
//  GameIntermissionViewController.swift
//  Balderdash
//
//  Created by Morgan Dean on 1/16/19.
//  Copyright © 2019 Morgan Dean. All rights reserved.
//

import UIKit
import LGButton
import FontAwesome_swift
import SwiftyJSON

class GameIntermissionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var newRoundButton: LGButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var votesTable: UITableView!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var pointsTable: UITableView!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var leaveButton: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true

        votesTable.delegate = self
        pointsTable.delegate = self

        votesTable.dataSource = self
        pointsTable.dataSource = self
        
        votesTable.layer.cornerRadius = 5.0
        pointsTable.layer.cornerRadius = 5.0

        leaveButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 24, style: .solid)
        leaveButton.setTitle(String.fontAwesomeIcon(name: .times), for: .normal)
        leaveButton.tintColor = .white
        
        headerLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.width.equalTo(115)
        }
        
        answerLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(headerLabel.snp.bottom).offset(1)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        votesLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(answerLabel.snp.bottom).offset(50)
        }
        
        votesTable.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.lessThanOrEqualTo(140)
            make.top.equalTo(votesLabel.snp.bottom).offset(1)
        }
        
        pointsLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(votesTable.snp.bottom).offset(15)
        }
        
        pointsTable.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.lessThanOrEqualTo(140)
            make.top.equalTo(pointsLabel.snp.bottom).offset(1)
        }
        
        answerLabel.text = appDelegate.game?.card?.answer
        
        if appDelegate.thisPlayer?.role == "dasher" {
            newRoundButton.isHidden = false
            newRoundButton.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview().offset(-20)
                make.centerX.equalToSuperview()
                make.width.equalTo(187)
                make.height.equalTo(52)
            }
        } else {
            newRoundButton.isHidden = true
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
                        if res["content"]["state"] == "starting" {
                            self.appDelegate.game = Game(card: nil, code: res["content"]["code"].int!, responses: [Response](), state: res["content"]["state"].string!, users: users)
                            let gameView = self.selectView(viewName: "gameStart")
                            gameView.hero.isEnabled = true
                            gameView.hero.modalAnimationType = .pull(direction: .down)
                            self.present(gameView, animated: true, completion: nil)
                        }
                    }
                } catch let error {
                    print(error)
                }
            }
        }

        
    }
    @IBAction func newRound(_ sender: Any) {
        let roundData = "{ \"type\": \"next_round\" }"
        appDelegate.socket.write(string: roundData)
        appDelegate.thisPlayer?.role = "player"
        let gameView = self.selectView(viewName: "gameStart")
        gameView.hero.isEnabled = true
        gameView.hero.modalAnimationType = .pull(direction: .down)
        self.present(gameView, animated: true, completion: nil)
    }
    @IBAction func leaveGame(_ sender: Any) {
        appDelegate.socket.disconnect()
        loadOtherView(viewName: "home")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of items in the sample data structure.
        
        var count:Int?
        
        if tableView == self.votesTable {
            count = appDelegate.game?.responses.count
        }
        
        if tableView == self.pointsTable {
            count =  appDelegate.game?.users.count
        }
        
        return count!
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        if tableView == self.votesTable {
            let cellIdentifier = "VotesTableCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? VotesTableCell
            let response = appDelegate.game?.responses[indexPath.row]
            
            cell!.response.text = response?.text
            if (response?.isAnswer)!  {
                cell!.votes.text = "\((response?.votes.count)! - 1 ) Votes"
            } else {
                cell!.votes.text = "\(response?.votes.count ?? 0) Votes"
            }
            
            return cell!
        }
        
        if tableView == self.pointsTable {
            let cellIdentifier = "PointsTableCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PointsTableCell
            let player = appDelegate.game?.users[indexPath.row]
            
            cell!.playerName.text = player?.nick
            cell!.points.text = "\(player!.points) Points"
            
            return cell!
        }
        
        return UITableViewCell()

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

}

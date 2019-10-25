//
//  GamePickViewController.swift
//  Balderdash
//
//  Created by Morgan Dean on 1/14/19.
//  Copyright © 2019 Morgan Dean. All rights reserved.
//

import UIKit
import LGButton
import NVActivityIndicatorView
import FontAwesome_swift
import SwiftyJSON

class GamePickViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var pickButton: LGButton!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var leaveButton: UIButton!
    @IBOutlet weak var responseCollection: UICollectionView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true

        responseCollection.dataSource = self
        responseCollection.delegate = self
        
        responseCollection.isPagingEnabled = true
        
        leaveButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 24, style: .solid)
        leaveButton.setTitle(String.fontAwesomeIcon(name: .times), for: .normal)
        leaveButton.tintColor = .white
        
        leftButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 24, style: .solid)
        leftButton.setTitle(String.fontAwesomeIcon(name: .arrowLeft), for: .normal)
        leftButton.tintColor = .white
        
        rightButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 24, style: .solid)
        rightButton.setTitle(String.fontAwesomeIcon(name: .arrowRight), for: .normal)
        rightButton.tintColor = .white
        
        leaveButton.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.top.equalToSuperview().offset(35)
        }
        
        titleText.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(leaveButton.snp.bottom).offset(25)
        }
        
        if appDelegate.thisPlayer?.role == "dasher" {
            // is the dasher, doesn't pick
            pickButton.isHidden = true
            responseCollection.isHidden = true
            leftButton.isHidden = true
            rightButton.isHidden = true
            
            titleText.text = "Please wait while the other players select an answer."
            
            
            let frame = CGRect(x: 10, y: 200, width: 50, height: 50)
            let activityIndicatorView = NVActivityIndicatorView(frame: frame, type: .ballPulseSync)
            self.view.addSubview(activityIndicatorView)
            
            activityIndicatorView.snp.makeConstraints{ (make) in
                make.width.equalTo(50)
                make.height.equalTo(50)
                make.center.equalToSuperview()
            }
            
            activityIndicatorView.startAnimating()
        } else {
            responseCollection.snp.makeConstraints { (make) in
                make.width.equalTo(250)
                make.center.equalToSuperview()
                make.height.equalTo(200)
            }
            
            leftButton.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(5)
                make.right.equalTo(responseCollection.snp.left).offset(-5)
                make.height.equalTo(40)
                make.centerY.equalToSuperview()
            }
            
            rightButton.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-5)
                make.left.equalTo(responseCollection.snp.right).offset(5)
                make.height.equalTo(40)
                make.centerY.equalToSuperview()
            }
            
            pickButton.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(-40)
                make.width.equalTo(187)
                make.height.equalTo(52)
            }
            
            responseCollection.layer.cornerRadius = 5.0
            responseCollection.showsHorizontalScrollIndicator = false
            responseCollection.layer.borderColor = UIColor.white.cgColor
            responseCollection.layer.borderWidth = 2.0
            
        }
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
                            self.responseCollection.reloadData()
                            if self.appDelegate.game?.state == "intermission" {
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
    @IBAction func rightResponse(_ sender: Any) {
        let visibleItems: NSArray = responseCollection.indexPathsForVisibleItems as NSArray
        let currentItem: IndexPath = visibleItems.object(at: 0) as! IndexPath
        
        if currentItem.item < responseCollection.numberOfItems(inSection: 0) - 1 {

            let nextItem: IndexPath = IndexPath(item: currentItem.item + 1, section: 0)
            responseCollection.scrollToItem(at: nextItem, at: .centeredHorizontally, animated: true)
            if currentItem.item == responseCollection.numberOfItems(inSection: 0) - 1 {
                rightButton.isEnabled = false
            }
            leftButton.isEnabled = true
        }
    }
    
    @IBAction func leftResponse(_ sender: Any) {
        let visibleItems: NSArray = responseCollection.indexPathsForVisibleItems as NSArray
        var currentItem: IndexPath = visibleItems.object(at: 0) as! IndexPath
        if currentItem.item > 0 {
            let lastItem: IndexPath = IndexPath(item: currentItem.item - 1, section: 0)
            responseCollection.scrollToItem(at: lastItem, at: .centeredHorizontally, animated: true)
            let visibleItems: NSArray = responseCollection.indexPathsForVisibleItems as NSArray
            let currentItem: IndexPath = visibleItems.object(at: 0) as! IndexPath
            if currentItem.item == 0 {
                leftButton.isEnabled = false
            }
            rightButton.isEnabled = true
        }
    }
    
    @IBAction func pickResponse(_ sender: Any) {
        let visibleItems: NSArray = responseCollection.indexPathsForVisibleItems as NSArray
        var currentItem: IndexPath = visibleItems.object(at: 0) as! IndexPath
        let voteData = "{ \"type\": \"vote\", \"content\": { \"text\": \"\(appDelegate.game!.responses[currentItem.item].text)\" } }"
        
        appDelegate.socket.write(string: voteData)
        // is the dasher, doesn't pick
        pickButton.isHidden = true
        responseCollection.isHidden = true
        leftButton.isHidden = true
        rightButton.isHidden = true
        
        
        titleText.text = "Please wait while the other players select an answer."
        
        
        let frame = CGRect(x: 10, y: 200, width: 50, height: 50)
        let activityIndicatorView = NVActivityIndicatorView(frame: frame, type: .ballPulseSync)
        self.view.addSubview(activityIndicatorView)
        
        activityIndicatorView.snp.makeConstraints{ (make) in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.center.equalToSuperview()
        }
        
        activityIndicatorView.startAnimating()
        
        // waiting for response!
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        // Make sure that the number of items is worth the computing effort.
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout,
            let dataSourceCount = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section),
            dataSourceCount > 0 else {
                return .zero
        }
        
        
        let cellCount = CGFloat(dataSourceCount)
        let itemSpacing = flowLayout.minimumInteritemSpacing
        let cellWidth = flowLayout.itemSize.width + itemSpacing
        var insets = flowLayout.sectionInset
        
        
        // Make sure to remove the last item spacing or it will
        // miscalculate the actual total width.
        let totalCellWidth = (cellWidth * cellCount) - itemSpacing
        let contentWidth = collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right
        
        
        // If the number of cells that exist take up less room than the
        // collection view width, then center the content with the appropriate insets.
        // Otherwise return the default layout inset.
        guard totalCellWidth < contentWidth else {
            return insets
        }
        
        
        // Calculate the right amount of padding to center the cells.
        let padding = (contentWidth - totalCellWidth) / 2.0
        insets.left = padding
        insets.right = padding
        return insets
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (appDelegate.game?.responses.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = responseCollection.dequeueReusableCell(withReuseIdentifier: "PickerCell", for: indexPath) as! PickerCollectionViewCell
        let response = appDelegate.game?.responses[indexPath.item]
        cell.responseText.text = response!.text
        if response!.isAnswer {
            cell.votesText.text = "0 votes."
        } else {
            cell.votesText.text = "\(response!.votes.count) votes."
        }
        cell.layer.cornerRadius = 5.0

        
        return cell
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

//
//  Home.swift
//  Balderdash
//
//  Created by Morgan Dean on 1/7/19.
//  Copyright © 2019 Morgan Dean. All rights reserved.
//

import UIKit
import ChameleonFramework
import GradientView
import LGButton
import SnapKit

class Home: UIViewController {

    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var actionView: UIView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientView = GradientView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height:
        self.view.frame.height))
                gradientView.colors = [UIColor(hexString: "#fc00ff"), UIColor(hexString: "#00dbde")] as? [UIColor]
        gradientView.locations = [0.01, 0.9]
        gradientView.direction = .vertical
        self.view.addSubview(gradientView)
        self.view.sendSubviewToBack(gradientView)
        
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
    }
    
    @IBAction func createGame(_ sender: LGButton) {
        loadOtherView(viewName: "createGame")
    }
    @IBAction func joinGame(_ sender: LGButton) {
        loadOtherView(viewName: "joinGame")
    }
    
    func loadOtherView(viewName:String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view : UIViewController = storyboard.instantiateViewController(withIdentifier: viewName)
        self.present(view, animated: true, completion: nil)
    }
    
    /*
     
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

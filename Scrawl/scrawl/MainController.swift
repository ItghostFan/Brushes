//
//  MainController.swift
//  scrawl
//
//  Created by Itghost Fan on 2022/4/18.
//

import UIKit

import RxCocoa
import RxSwift

class MainController: UIViewController {

    @IBOutlet weak var assistantSceneButton: UIButton!
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        makeActions()
    }

    private func makeActions() {
        assistantSceneButtonTapped()
    }

    private func assistantSceneButtonTapped() {
        disposeBag.insert(
            assistantSceneButton.rx.tap.subscribe(onNext: {
//                for session in UIApplication.shared.openSessions {
//                    if session.configuration.name == "Assistant Configuration" {
//                        UIApplication.shared.requestSceneSessionActivation(session, userActivity: nil, options: nil, errorHandler: nil)
//                    }
//                }
                let userActivity = NSUserActivity(activityType: "Assistant Configuration")
                UIApplication.shared.requestSceneSessionActivation(nil, userActivity: userActivity, options: nil)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
        )
    }
}


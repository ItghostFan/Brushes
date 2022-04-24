//
//  StartController.swift
//  scrawl
//
//  Created by Itghost Fan on 2022/4/18.
//

import UIKit

import RxCocoa
import RxSwift

class StartController: UIViewController {

    @IBOutlet weak var openGLSceneButton: UIButton!
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        makeActions()
    }

    private func makeActions() {
        openGLSceneButtonTapped()
    }

    private func openGLSceneButtonTapped() {
        disposeBag.insert(
            openGLSceneButton.rx.tap.subscribe(onNext: {
                if UIApplication.shared.supportsMultipleScenes {
                    let activityType = AppScene.sceneConfigurationNameAtIndex(AppSceneIndex.OPENGL)
                    guard activityType != nil else {
                        return
                    }
                    let userActivity = NSUserActivity(activityType: activityType!)
                    UIApplication.shared.requestSceneSessionActivation(nil, userActivity: userActivity, options: nil)
                } else {
                    self.navigationController!.pushViewController(AppScene.openGLControllerBuild(), animated: true)
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil)
        )
    }
}


//
//  AppScene.swift
//  scrawl
//
//  Created by Itghost Fan on 2022/4/21.
//

import UIKit

enum AppSceneIndex : Int {
    case DEFAULT    = 0
    case OPENGL     = 1
}

class AppScene {
    static func sceneConfigurationNameAtIndex(_ index: AppSceneIndex) -> String? {
        let sceneManifest = Bundle.main.infoDictionary!["UIApplicationSceneManifest"] as? [String: Any?]
        guard sceneManifest != nil else {
            return nil
        }
        let sceneConfigurations = sceneManifest!["UISceneConfigurations"] as? [String: Any?]
        guard sceneConfigurations != nil else {
            return nil
        }
        let sceneSessionRoleApplication = sceneConfigurations!["UIWindowSceneSessionRoleApplication"] as? [[String: Any?]]
        guard sceneSessionRoleApplication != nil else {
            return nil
        }
        return sceneSessionRoleApplication![index.rawValue]["UISceneConfigurationName"] as? String
    }
    
    static func startControllerBuild() -> StartController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let startController = storyboard.instantiateViewController(withIdentifier: "StartController")
        return startController as! StartController
    }
    
    static func openGLControllerBuild() -> OpenGLController {
        let storyboard = UIStoryboard(name: "OpenGL", bundle: Bundle.main)
        let startController = storyboard.instantiateInitialViewController()
        return startController as! OpenGLController
    }
}

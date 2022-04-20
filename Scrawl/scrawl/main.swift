//
//  main.swift
//  scrawl
//
//  Created by Itghost Fan on 2022/4/18.
//

import Foundation
import UIKit

let exitCode = main(CommandLine.argc,
                    CommandLine.unsafeArgv,
                    NSStringFromClass(UIApplication.self),
                    NSStringFromClass(AppDelegate.self))

public func main(_ argc: Int32,
                 _ argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>,
                 _ principalClassName: String?,
                 _ delegateClassName: String?) -> Int32 {
    return UIApplicationMain(argc, argv, principalClassName, delegateClassName)
}

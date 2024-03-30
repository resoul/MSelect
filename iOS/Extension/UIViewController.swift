//
//  UIViewController.swift
//  iOS
//

import UIKit

extension UIViewController {
    func addChildController(_ childController: UIViewController, parentView: UIView) {
        addChild(childController)
        parentView.addSubview(childController.view)
        childController.didMove(toParent: self)
    }
    
    func addChildController(_ childController: UIViewController) {
        addChild(childController)
        view.addSubview(childController.view)
        childController.didMove(toParent: self)
    }

    func removeChildController(_ childController: UIViewController) {
        childController.willMove(toParent: nil)
        childController.view.removeFromSuperview()
        childController.removeFromParent()
    }
}

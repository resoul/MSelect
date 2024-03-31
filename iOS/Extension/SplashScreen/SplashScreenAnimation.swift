//
//  SplashScreenAnimation.swift
//  iOS
//

import UIKit
import QuartzCore

class SplashScreenAnimation: NSObject, CAAnimationDelegate {
    
    private var removeFromSuperview: Bool = true

    let animationView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    func configure(parentView: UIView, image: UIImage?, size: CGSize, removeFromSuperview: Bool = true) {
        animationView.image = image
        parentView.addSubview(animationView)
        animationView.fillCenter(for: parentView, size: size)
        self.removeFromSuperview = removeFromSuperview
    }
    
    func showScaleAnimation() {
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, 4.0, 7.0, 11.0, 19.0, 25.0]
        scaleAnimation.keyTimes = [0, 0.25, 0.5, 0.75, 0.89, 1]
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        scaleAnimation.duration = 1
        scaleAnimation.delegate = self
        
        animationView.layer.add(scaleAnimation, forKey: "logoScaleAnimation")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if removeFromSuperview {
            animationView.removeFromSuperview()
        }
    }
}

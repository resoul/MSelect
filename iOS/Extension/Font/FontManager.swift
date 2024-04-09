//
//  FontManager.swift
//  iOS
//

import UIKit

class FontManager {
    enum FontWeight {
        case bold
        case medium
        case regular
        case light
        case italic
    }
    
    static func roboto(size: CGFloat, weight: FontWeight) -> UIFont {
        switch weight {
        case .bold:
            return UIFont(name: "Roboto-Bold", size: size)!
        case .medium:
            return UIFont(name: "Roboto-Medium", size: size)!
        case .regular:
            return UIFont(name: "Roboto-Regular", size: size)!
        case .light:
            return UIFont(name: "Roboto-Light", size: size)!
        case .italic:
            return UIFont(name: "Roboto-Italic", size: size)!
        }
    }
    
    static func montserrat(size: CGFloat, weight: FontWeight) -> UIFont {
        switch weight {
        case .bold:
            return UIFont(name: "Montserrat-Bold", size: size)!
        case .medium:
            return UIFont(name: "Montserrat-Medium", size: size)!
        case .regular:
            return UIFont(name: "Montserrat-Regular", size: size)!
        case .light:
            return UIFont(name: "Montserrat-Light", size: size)!
        case .italic:
            return UIFont(name: "Montserrat-Italic", size: size)!
        }
    }
}

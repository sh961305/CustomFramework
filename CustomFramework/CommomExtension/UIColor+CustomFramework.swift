//
//  UIColor+CustomFramework.swift
//  CustomFramework
//
//  Created by Administrator on 2020/7/7.
//  Copyright © 2020 Kevin. All rights reserved.
//

import UIKit

public extension UIColor
{
    /// 透過RGB初始化
    /// - Parameters:
    ///   - red: 紅色
    ///   - green: 綠色
    ///   - blue: 藍色
    ///   - alpha: 透明度
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0)
    {
        self.init(red: CGFloat(red) / 255.0,
                  green: CGFloat(green) / 255.0,
                  blue: CGFloat(blue) / 255.0,
                  alpha: alpha)
    }
    
    /// 透過十六進位字串初始化
    /// - Parameters:
    ///   - hex: 十六進位字串
    ///   - alpha: 透明度
    convenience init(hex: String, alpha: CGFloat = 1.0)
    {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(red: CGFloat(r) / 0xff,
                  green: CGFloat(g) / 0xff,
                  blue: CGFloat(b) / 0xff,
                  alpha: alpha)
    }
}

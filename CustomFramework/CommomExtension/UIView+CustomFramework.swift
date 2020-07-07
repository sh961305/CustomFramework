//
//  UIView+CustomFramework.swift
//  CustomFramework
//
//  Created by Administrator on 2020/7/7.
//  Copyright © 2020 Kevin. All rights reserved.
//

import UIKit

public extension UIView
{
    var cacheImage: UIImage
    {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    /// 移除該視圖底下所有的子視圖
    func removeAllSubviews()
    {
        self.subviews.forEach { $0.removeFromSuperview() }
    }
}

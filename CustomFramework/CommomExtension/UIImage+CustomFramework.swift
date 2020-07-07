//
//  UIImage+CustomFramework.swift
//  CustomFramework
//
//  Created by Administrator on 2020/7/7.
//  Copyright © 2020 Kevin. All rights reserved.
//

import UIKit

public extension UIImage
{
    /// 重新繪圖至指定大小
    /// - Parameters:
    ///   - width: 寬度
    ///   - height: 高度
    /// - Returns: 重繪後的圖片
    func resize(_ width: CGFloat, _ height: CGFloat) -> UIImage
    {
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(size)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return resultImage
    }
}

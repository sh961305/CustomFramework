//
//  UIResponder+CustomFramework.swift
//  CustomFramework
//
//  Created by Administrator on 2020/7/7.
//  Copyright © 2020 Kevin. All rights reserved.
//

import UIKit

private var _first: UIResponder? = nil

public extension UIResponder
{
    /// get first responder in the window
    static var first: UIResponder?
    {
        _first = nil
        
        UIApplication.shared.sendAction(#selector(self.whereIsFirstResponder),
                                        to: nil,
                                        from: self,
                                        for: nil)
        
        return _first
    }
    
    @objc private func whereIsFirstResponder()
    {
        _first = self
    }
}

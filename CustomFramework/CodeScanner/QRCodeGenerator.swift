//
//  QRCodeGenerator.swift
//  CustomFramework
//
//  Created by Administrator on 2020/7/7.
//  Copyright © 2020 Kevin. All rights reserved.
//

import UIKit

@IBDesignable
open class QRCodeGenerator: UIImageView
{
    @IBInspectable
    /// QRCode的字串
    public var stringValue: String = "QRCodeString"
    {
        didSet { self.qrCodeImageGenerator() }
    }
    
    public init()
    {
        super.init(frame: .zero)
        
        self.qrCodeImageGenerator()
    }
    
    override public init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.qrCodeImageGenerator()
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        self.qrCodeImageGenerator()
    }
    
    /// 將QRCode的字串轉成image顯示至`UIImageView`上面
    private func qrCodeImageGenerator()
    {
        let data = self.stringValue.data(using: .utf8)
        
        let filter = CIFilter(name: "CIQRCodeGenerator")!
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("Q", forKey: "inputCorrectionLevel")
        
        filter.outputImage.flatMap {
            
            let resizeCIImage = self.qrCodeImageResize(ciImage: $0)
            
            self.image = UIImage(ciImage: resizeCIImage)
        }
    }
    
    private func qrCodeImageResize(ciImage: CIImage) -> CIImage
    {
        let scaleX = self.bounds.width / ciImage.extent.width
        let scaleY = self.bounds.height / ciImage.extent.height
        let transformedImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX,
                                                                         y: scaleY))
        return transformedImage
    }
}

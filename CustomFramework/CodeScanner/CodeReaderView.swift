//
//  CodeReaderView.swift
//  CustomFramework
//
//  Created by Administrator on 2020/7/7.
//  Copyright © 2020 Kevin. All rights reserved.
//

import UIKit
import AVFoundation

/// 條碼掃描器的錯誤
///
/// - requestDeviceFailed: 取得鏡頭時發生問題
/// - cantAddInput: 無法載入影像輸入設備
/// - cantAddOutput: 無法載入輸入設備
public enum ReadCodeError: Error
{
    case requestDeviceFailed
    case cantAddInput
    case cantAddOutput
    
    var localizedDescription: String
    {
        switch self
        {
        case .requestDeviceFailed:  return "Failed to get the camera device."
        case .cantAddInput:         return "AVCaptureDeviceInput can not be added to the AVCaptureSession."
        case .cantAddOutput:        return "AVCaptureMetadataOutput can not be added to the AVCaptureSession."
        }
    }
}

public protocol CodeReaderViewDelegate: NSObjectProtocol
{
    /// 讀到條碼時，會呼叫此方法
    /// - Parameters:
    ///   - view: CodeReaderView
    ///   - codeObject: 條碼物件
    func readerView(_ view: CodeReaderView, didRead codeObject: AVMetadataMachineReadableCodeObject)
    
    /// 條碼掃描器在建立時發生錯誤，會呼叫此方法
    /// - Parameters:
    ///   - view: CodeReaderView
    ///   - error: 錯誤
    func readerView(_ view: CodeReaderView, didFailWith error: Error)
}

/// 用來讀取條碼的視圖
open class CodeReaderView: UIView
{
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private let metadataOutput = AVCaptureMetadataOutput()
    
    public weak var delegate: CodeReaderViewDelegate?
    
    /// 掃描範圍
    public var scanFrame: CGRect?
    
    /// 允許掃描的條碼類型
    public var allowMetadataObjectTypes: [AVMetadataObject.ObjectType] = []
    
    public init()
    {
        super.init(frame: .zero)
        
        self.setup()
    }
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required public init?(coder: NSCoder)
    {
        super.init(coder: coder)
        
        self.setup()
    }
    
    deinit
    {
        self.stopScan()
    }
    
    open override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.previewLayer.frame = self.bounds
        
        if self.scanFrame == nil { self.scanFrame = self.bounds }
        
        let orientation: AVCaptureVideoOrientation
        
        // 當設備轉向時，更新鏡頭方向
        if #available(iOS 13.0, *) { orientation = AVCaptureVideoOrientation(rawValue: UIApplication.shared.windows.first!.windowScene!.interfaceOrientation.rawValue)! }
        else { orientation = AVCaptureVideoOrientation(rawValue: UIApplication.shared.statusBarOrientation.rawValue)! }
        
        self.previewLayer.connection?.videoOrientation = orientation
    }
    
    func setup()
    {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else
        {
            self.delegate?.readerView(self, didFailWith: ReadCodeError.requestDeviceFailed)
            
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do
        {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        }
        catch
        {
            self.delegate?.readerView(self, didFailWith: error)
            
            return
        }
        
        guard self.captureSession.canAddInput(videoInput) else
        {
            self.delegate?.readerView(self, didFailWith: ReadCodeError.cantAddInput)
            
            return
        }
                
        guard self.captureSession.canAddOutput(self.metadataOutput) else
        {
            self.delegate?.readerView(self, didFailWith: ReadCodeError.cantAddOutput)
            
            return
        }
        
        self.captureSession.beginConfiguration()
        self.captureSession.addInput(videoInput)
        self.captureSession.addOutput(self.metadataOutput)
        self.metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        self.metadataOutput.metadataObjectTypes = self.metadataOutput.availableMetadataObjectTypes
        self.captureSession.commitConfiguration()
        
        self.allowMetadataObjectTypes = self.metadataOutput.availableMetadataObjectTypes // default
        
        self.previewLayer.videoGravity = .resizeAspectFill
        self.layer.insertSublayer(self.previewLayer, at: 0)
        
        self.startScan()
    }
    
    /// 開始掃描
    public func startScan()
    {
        guard !self.captureSession.isRunning else { return }
        
        // 相機載入需要些許時間，會造成轉場動畫卡頓，故而將之放在背景執行緒。
        DispatchQueue.global().async { self.captureSession.startRunning() }
    }
    
    /// 停止掃描
    public func stopScan()
    {
        guard self.captureSession.isRunning else { return }
        
        self.captureSession.stopRunning()
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension CodeReaderView: AVCaptureMetadataOutputObjectsDelegate
{
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection)
    {
        guard let metadataObject = metadataObjects.first,
            self.allowMetadataObjectTypes.contains(metadataObject.type),
            let barCodeObject = self.previewLayer.transformedMetadataObject(for: metadataObject) as? AVMetadataMachineReadableCodeObject,
            self.scanFrame?.contains(barCodeObject.bounds) == true else { return }
        
        self.delegate?.readerView(self, didRead: barCodeObject)
    }
}

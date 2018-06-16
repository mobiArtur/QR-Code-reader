//  Created by Artur Skiba on 15.02.2018.
//  Copyright © 2018 Artur Skiba. All rights reserved.

import UIKit
import CoreMedia

typealias QrCodeCornersCoordinate = [RectangleCorners: CGPoint]

public enum RectangleCorners {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

extension CIQRCodeFeature {
    
    /// Returns coordinate for each QR Code corner
    func corners() -> QrCodeCornersCoordinate {
        return  [ RectangleCorners.topLeft : self.topLeft,
                  RectangleCorners.bottomLeft : self.bottomLeft,
                  RectangleCorners.topRight : self.topRight,
                  RectangleCorners.bottomRight : self.bottomRight ]
    }
}

struct QrCode {

    let height: CGFloat
    let width: CGFloat
    
    /// Coordinate for each QR Code corner
    let corners: QrCodeCornersCoordinate
    /// Text encoded in QR Code
    let message: String?
    

    /// - parameter image: that we look for QR COde
    /// - returns: Can return nil if there is no QR Code in image, or image is not valid
    init?(_ image: CIImage?) {
        guard let image = image else { return nil }
        var height: CGFloat = 0.0
        var width: CGFloat = 0.0
        var corners = QrCodeCornersCoordinate()
        var message = String()
        let detectoOptions = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        guard let qrCodeDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: detectoOptions) else { return nil }
        
        let features = qrCodeDetector.features(in: image)
        if features.isEmpty { return nil }
        for qrCode in features as! [CIQRCodeFeature] {
            let qrCodeCorners = qrCode.corners()
            guard let decode = qrCode.messageString else { return nil }

            message = decode
            height = qrCode.bounds.height
            width = qrCode.bounds.width
            corners = qrCodeCorners
        }
        
        self.width = width
        self.height = height
        self.corners = corners
        self.message = message
    }
    
    init?(_ image: UIImage?) {
        guard let image = image else { return nil }
        let ciImageFormUiImage = CIImage(image: image)
        self.init(ciImageFormUiImage)
    }
    
    init?(_ image: CGImage?) {
        guard let image = image else { return nil }
        let ciImageFromCgImage = CIImage(cgImage: image)
        self.init(ciImageFromCgImage)
    }
    
    init?(_ imageSampleBuffer: CMSampleBuffer ) {
        guard let pixelBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(imageSampleBuffer) else { return nil }
        let ciImageFormPixelBuffer = CIImage(cvImageBuffer: pixelBuffer)
        self.init(ciImageFormPixelBuffer)
    }
}

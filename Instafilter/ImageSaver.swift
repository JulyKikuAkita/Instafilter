//
//  ImageSaver.swift
//  Instafilter
//
//  Created by Ifang Lee on 12/11/21.
//

import Foundation
import UIKit

/**
 ImageSaver class that inherits from NSObject, have a callback method that is marked with @objc, then point to that method using the #selector compiler directive.
 In order to save UIImage to SwiftUI Image
 */
class ImageSaver: NSObject {
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?

    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            errorHandler?(error)
        } else {
            successHandler?()
        }
    }
}

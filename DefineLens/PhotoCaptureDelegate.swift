//
//  PhotoCaptureDelegate.swift
//  DefineLens
//
//  Created by Sai Sandeep Vaddi on 11/22/23.
//

import AVFoundation
import UIKit

class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void

    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            completion(nil)
            return
        }

        guard let imageData = photo.fileDataRepresentation() else {
            completion(nil)
            return
        }

        let image = UIImage(data: imageData)
        completion(image)
    }
}

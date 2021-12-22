//
//  ImagePicker.swift
//  Instafilter
//
//  Created by Ifang Lee on 12/10/21.
//

import PhotosUI
import SwiftUI

/**
 - We created a SwiftUI view that conforms to UIViewControllerRepresentable.
 - We gave it a makeUIViewController() method that created some sort of UIViewController, which in our example was a PHPickerViewController.
 - We added a nested Coordinator class to act as a bridge between the UIKit view controller and our SwiftUI view.
 - We gave that coordinator a didFinishPicking method, which will be triggered by iOS when an image was selected.
 - Finally, we gave our ImagePicker an @Binding property so that it can send changes back to a parent view.
 */
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    //Rather than just pass the data down one level,
    //a better idea is to tell the coordinator what its parent is, so it can modify values there directly.
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // Tell the picker to go away
            picker.dismiss(animated: true)

            // Exit if no selection was made
            guard let provider = results.first?.itemProvider else { return }

            // If this has an image we can use, use it
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    self.parent.image = image as? UIImage
                }
            }
        }
    }
}

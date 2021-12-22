//
//  ContentView.swift
//  Instafilter
//
//  Created by Ifang Lee on 12/7/21.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

/**
 UIImage, which comes from UIKit. This is an extremely powerful image type capable of working with a variety of image types, including bitmaps (like PNG), vectors (like SVG), and even sequences that form an animation. UIImage is the standard image type for UIKit, and of the three it’s closest to SwiftUI’s Image type.

 CGImage, which comes from Core Graphics. This is a simpler image type that is really just a two-dimensional array of pixels.

 CIImage, which comes from Core Image. This stores all the information required to produce an image but doesn’t actually turn that into pixels unless it’s asked to. Apple calls CIImage “an image recipe” rather than an actual image.

 There is some interoperability between the various image types:

 We can create a UIImage from a CGImage, and create a CGImage from a UIImage.
 We can create a CIImage from a UIImage and from a CGImage, and can create a CGImage from a CIImage.
 We can create a SwiftUI Image from both a UIImage and a CGImage.
 */
struct ContentView: View {
    @State private var image: Image? //can't apply Core Image filters
    @State private var filterIntesity = 0.5
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage? //pass to ImagePicker
    @State private var showingFilterSheet = false
    @State private var processedImage: UIImage? //pass to ImageSaver


    @State private var currentFilter: CIFilter = CIFilter.sepiaTone() // check protocol CISepiaTone
    let context = CIContext() //context is epensive to create //rederning CIImage to CGImage

    var body: some View {
        NavigationView {
            VStack {
                Text("Tap Gray box to select a picture")
                    .font(.headline)

                ZStack {
                    Rectangle()
                        .fill(.gray)

                    image?
                        .resizable()
                        .scaledToFit()
                }
                .onTapGesture {
                        showingImagePicker = true
                }

                HStack {
                    Text("Intensity")
                    Slider(value: $filterIntesity)
                        .onChange(of: filterIntesity) { _ in applyProcessing() } //tracking change of slider intesity
                }
                .padding(.vertical)

                HStack {
                    Button("Change Filter") {
                        showingFilterSheet = true
                    }

                    Spacer()

                    Button("Save", action: save)
                }
            }
        }
        .padding([.horizontal, .bottom])
        .navigationTitle("Instafilter")
        .onChange(of: inputImage) { _ in loadImage() } //tracking change of inputImage
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
        }
        .confirmationDialog("Select a filter", isPresented: $showingFilterSheet) {
            Button("Crystallize") { setFilter(CIFilter.crystallize()) }
            Button("Edges") { setFilter(CIFilter.edges()) }
            Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
            Button("Pixellate") { setFilter(CIFilter.pixellate()) }
            Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
            Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
            Button("Vignette") { setFilter(CIFilter.vignette()) }
            Button("Line Overlay") { setFilter(CIFilter.lineOverlay()) }
            Button("Cancel", role: .cancel) { }
        } // refer to https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html
    }

    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }

    func loadImage() {
        guard let inputImage = inputImage else { return }

        let beginImage = CIImage(image: inputImage)
        // Note: prone to crash if use core image dedicated property - inputImage, use setValue() instead
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }

    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntesity, forKey: kCIInputIntensityKey)
        }

        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterIntesity * 200, forKey: kCIInputRadiusKey)
        }

        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(filterIntesity * 10, forKey: kCIInputScaleKey)
        }

        guard let outputImage = currentFilter.outputImage else { return }

        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }

    func save() {
        guard let processedImage = processedImage else { return }

        let imageSaver = ImageSaver()
        imageSaver.successHandler = {
            print("Success save filter image")
        }

        imageSaver.errorHandler = {
            print("Oops: \($0.localizedDescription)")
        }

        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

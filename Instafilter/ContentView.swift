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

 CHALLENGES:
 1. Try making the Save button disabled if there is no image in the image view.
 2. Experiment with having more than one slider, to control each of the input keys you care about. For example, you might have one for radius and one for intensity.
 3. Explore the range of available Core Image filters, and add any three of your choosing to the app. (Tip: That last one might be a little trickier than you expect. Why? Maybe have a think about it for 10 seconds!)
 */
struct ContentView: View {
    @State private var image: Image? //can't apply Core Image filters
    @State private var filterIntesity = 0.5
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage? //pass to ImagePicker
    @State private var showingFilterSheet = false
    @State private var processedImage: UIImage? //pass to ImageSaver
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone() // check protocol CISepiaTone
    @State private var filterRadius = 10.0
    @State private var filterName = "Change Filter"

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

                VStack {
                    Text("Intensity")
                    Slider(value: $filterIntesity)
                        .onChange(of: filterIntesity) { _ in applyProcessing() } //tracking change of slider intesity

                    Text("Radius")
                    Slider(value: $filterRadius, in: 0...100)
                        .onChange(of: filterRadius) { _ in applyProcessing() }
                }
                .padding()

                HStack {
                    Button(filterName) {
                        showingFilterSheet = true
                    }

                    Spacer()

                    Button("Save", action: save)
                        .disabled(processedImage == nil)
                }
            }
        }
        .padding([.horizontal, .bottom])
        .navigationTitle("Instafilter")
        .onChange(of: inputImage) { _ in loadImage() } //tracking change of inputImage
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
        }
        .confirmationDialog("Select a filter", isPresented: $showingFilterSheet) { //not abel to take more than 10 buttons
            Button("Crystallize") { setFilter(CIFilter.crystallize()) }
            Button("Edges") { setFilter(CIFilter.edges()) }
            Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
            Button("Pixellate") { setFilter(CIFilter.pixellate()) }
            Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
            Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
            Button("Vignette") { setFilter(CIFilter.vignette()) }
            Button("Line Overlay") { setFilter(CIFilter.lineOverlay()) }
//            Button("Vibrance") { setFilter(CIFilter.vibrance()) }
                Button("Hue Blend") { setFilter(CIFilter.hueBlendMode()) }
            Button("Cancel", role: .cancel) { }
        } // refer to https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html
    }

    func setFilter(_ filter: CIFilter) {
        filterName = filter.name
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
            currentFilter.setValue(filterRadius, forKey: kCIInputRadiusKey)
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

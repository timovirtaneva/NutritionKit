import SwiftUI
import PhotosUI
import Toolbox

public struct NutritionLabelPhotoScannerView: View {
    /// The scanned nutrition label.
    @Binding var label: NutritionLabel?
    
    /// Whether we're currently processing an image.
    @State private var isProcessingImage: Bool = false
    
    /// The cutout rectangle.
    @State private var cameraRectangle: CameraRect = DefaultCameraOverlayView.defaultLabelCutoutRect
    
    /// The threshold blur score below which an image is rejected.
    let minBlurScore: Float
    
    /// The selected image from the photo picker.
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    
    public init(label: Binding<NutritionLabel?>, minBlurScore: Float = 1300) {
        self._label = label
        self.minBlurScore = minBlurScore
    }
    
    func reset() {
        self.label = nil
        self.isProcessingImage = false
        self.resetCameraCutout()
        self.selectedImage = nil
        self.selectedItem = nil
    }
    
    func resetCameraCutout() {
        withAnimation {
            self.cameraRectangle = DefaultCameraOverlayView.defaultLabelCutoutRect
        }
    }
    
    func onImageSelected(_ img: UIImage) {
        guard let cgImage = img.cgImage else {
            self.reset()
            return
        }
        self.isProcessingImage = true
        Task {
            await self.processCapturedImage(cgImage)
        }
    }
    
    func processCapturedImage(_ image: CGImage) async {
        let scanner = NutritionLabelDetector(image: image)
        do {
            guard let (_, rect) = try await scanner.findNutritionLabel() else {
                DispatchQueue.main.async {
                    self.reset()
                }
                return
            }
            DispatchQueue.main.async {
                withAnimation {
                    self.cameraRectangle = .init(rect.topLeft, rect.topRight, rect.bottomLeft, rect.bottomRight)
                }
            }
            let label = try await scanner.scanNutritionLabel()
            guard label.isValid else {
                DispatchQueue.main.async {
                    self.reset()
                }
                return
            }
            DispatchQueue.main.async {
                self.isProcessingImage = false
                self.label = label
            }
        } catch {
            Log.nutritionKit.error("finding nutrition label failed: \(error.localizedDescription)")
        }
    }
    
    public var body: some View {
        VStack {
            if let image = selectedImage {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .overlay(
                            DefaultCameraOverlayView(rectangle: $cameraRectangle)
                        )
                    if isProcessingImage {
                        ProgressView("Processing...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .background(Color.black.opacity(0.5))
                    }
                }
                Button("Scan Another Photo") {
                    reset()
                }
                .padding()
            } else {
                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    Label("Select or Take a Photo", systemImage: "photo.on.rectangle")
                        .font(.title2)
                        .padding()
                }
            }
        }
        .onChange(of: selectedItem) { newItem in
            guard let item = newItem else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    self.selectedImage = uiImage
                    self.onImageSelected(uiImage)
                } else {
                    self.reset()
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker(sourceType: .camera) { image in
                self.showCamera = false // Always dismiss the sheet
                if let img = image {
                    self.selectedImage = img
                    self.onImageSelected(img)
                } else {
                    self.reset()
                }
            }
        }
    }
}

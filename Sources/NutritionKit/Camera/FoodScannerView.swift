
import SwiftUI
//import Toolbox

public struct FoodScannerView: View {
    /// The current scanned food item.
    @Binding var nkFoodItem: NkFoodItem?
    
    /// Whether or not a nkBarcode is currently being processed.
    @State var isProcessingNkBarcode: Bool = false
    
    /// The cutout rectangle.
    @State var cameraRectangle: CameraRect = DefaultCameraOverlayView.defaultNkBarcodeCutoutRect
    
    public init(nkFoodItem: Binding<NkFoodItem?>) {
        self._nkFoodItem = nkFoodItem
    }
    
    func reset() {
        self.nkFoodItem = nil
        self.isProcessingNkBarcode = false
        self.resetCameraCutout()
    }
    
    func resetCameraCutout() {
        withAnimation {
            self.cameraRectangle = DefaultCameraOverlayView.defaultNkBarcodeCutoutRect
        }
    }
    
    func onNkBarcodeRead(nkBarcode: String, corners: [CGPoint]) {
        guard !self.isProcessingNkBarcode else {
            return
        }
        
        self.isProcessingNkBarcode = true
        self.cameraRectangle = .init(corners[3], corners[0], corners[2], corners[1])
        
        Task {
            do {
                let data = try await OpenFoodFactsAPI.shared.find(nkBarcode)
                DispatchQueue.main.async {
                    self.isProcessingNkBarcode = false
                    self.nkFoodItem = data
                }
            }
            catch {
                Log.nutritionKit.error("\(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isProcessingNkBarcode = false
                }
            }
        }
    }
    
    public var body: some View {
        ZStack {
            AnyCameraView(onNkBarcodeRead: { data, corners in
                self.onNkBarcodeRead(nkBarcode: data, corners: corners)
            }) {
                DefaultCameraOverlayView(rectangle: $cameraRectangle)
            }
        }
    }
}

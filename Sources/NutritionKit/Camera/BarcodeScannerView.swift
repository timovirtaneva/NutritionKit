
import SwiftUI
import Toolbox

public struct NkBarcode: Codable, Hashable {
    /// The nkBarcode data.
    let data: String
    
    /// The corners of the nkBarcode.
    let corners: [CGPoint]
}

public struct NkBarcodeScannerView: View {
    /// The current nkBarcode data.
    @Binding var nkBarcodeData: NkBarcode?
    
    /// The cutout rectangle.
    @State var cameraRectangle: CameraRect = DefaultCameraOverlayView.defaultNkBarcodeCutoutRect
    
    public init(nkBarcodeData: Binding<NkBarcode?>) {
        self._nkBarcodeData = nkBarcodeData
    }
    
    func resetCameraCutout() {
        withAnimation {
            self.cameraRectangle = DefaultCameraOverlayView.defaultNkBarcodeCutoutRect
        }
    }
    
    public var body: some View {
        ZStack {
            AnyCameraView(onNkBarcodeRead: { data, corners in
                self.nkBarcodeData = .init(data: data, corners: corners)
            }) {
                DefaultCameraOverlayView(rectangle: $cameraRectangle)
            }
        }
    }
}

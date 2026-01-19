import SwiftUI
//import Toolbox

public struct NkSingleBarcodeScannerView: View {
    /// The current nkBarcode data.
    @Binding var nkBarcodeData: NkBarcode?
    /// The cutout rectangle.
    @State var cameraRectangle: CameraRect = DefaultCameraOverlayView.defaultNkBarcodeCutoutRect
    /// Track if a scan has occurred.
    @State private var hasScanned: Bool = false
    /// Dismiss environment for modal exit.
    @Environment(\.dismiss) private var dismiss

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
                guard !hasScanned else { return }
                self.nkBarcodeData = .init(data: data, corners: corners)
                self.hasScanned = true
                dismiss()
            }) {
                DefaultCameraOverlayView(rectangle: $cameraRectangle)
            }
            VStack {
                HStack {
                    Spacer()
                    Button("Cancel") {
                        dismiss()
                    }
                    .padding()
                }
                Spacer()
            }
        }
    }
}

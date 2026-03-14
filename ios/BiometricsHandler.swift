import Foundation
import LocalAuthentication

final class BiometricsHandler: AsyncHandler {
    let namespace = "biometrics"

    var onAsyncCallback: ((String, Any?) -> Void)?

    func handle(method: String, args: [String: Any]) -> Any? {
        switch method {
        case "authenticate":
            return authenticate(args)

        case "isAvailable":
            return checkAvailability()

        case "biometryType":
            let context = LAContext()
            var error: NSError?
            context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
            switch context.biometryType {
            case .faceID: return "faceID"
            case .touchID: return "touchID"
            case .opticID: return "opticID"
            case .none: return "none"
            @unknown default: return "unknown"
            }

        default:
            return ["error": "Unknown method: \(method)"]
        }
    }

    private func checkAvailability() -> Any? {
        let context = LAContext()
        var error: NSError?
        let available = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return [
            "available": available,
            "error": error?.localizedDescription as Any
        ]
    }

    private func authenticate(_ args: [String: Any]) -> Any? {
        let reason = args["reason"] as? String ?? "Authenticate to continue"
        let ref = args["_callbackRef"] as? String

        dbg.log("Biometrics", "authenticate() called, ref=\(ref ?? "nil"), onAsyncCallback=\(onAsyncCallback == nil ? "nil" : "set")")

        let context = LAContext()

        if let fallbackTitle = args["fallbackTitle"] as? String {
            context.localizedFallbackTitle = fallbackTitle
        }
        if let cancelTitle = args["cancelTitle"] as? String {
            context.localizedCancelTitle = cancelTitle
        }

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            dbg.log("Biometrics", "canEvaluatePolicy failed: \(error?.localizedDescription ?? "unknown")")
            return [
                "success": false,
                "error": error?.localizedDescription ?? "Biometrics not available"
            ]
        }

        dbg.log("Biometrics", "calling evaluatePolicy...")

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            dbg.log("Biometrics", "evaluatePolicy completed: success=\(success), error=\(error?.localizedDescription ?? "none")")
            dbg.log("Biometrics", "onAsyncCallback is \(self.onAsyncCallback == nil ? "nil" : "set"), ref=\(ref ?? "nil")")
            self.onAsyncCallback?(ref ?? "", [
                "success": success,
                "error": error?.localizedDescription as Any
            ])
            dbg.log("Biometrics", "onAsyncCallback invoked")
        }

        return ["status": "authenticating"]
    }
}

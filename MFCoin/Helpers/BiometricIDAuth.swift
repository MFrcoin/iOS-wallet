//
//  BiometricIDAuth.swift
//  MFCoin
//
//  Created by Admin on 07.01.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import LocalAuthentication

class BiometricIDAuth {
    
    static let shared = BiometricIDAuth()
    
    let context = LAContext()
    var loginReason = "Logging in with Touch ID"
    
    private func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func authenticateUser (completion: @escaping (String?) -> Void) {
        guard canEvaluatePolicy() else {
            completion("Biometric is not available")
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: loginReason) { (success, evaluateError) in
            if success {
                DispatchQueue.main.async {
                    completion("success")
                }
            } else {
                let message: String
                
                switch evaluateError {
                case LAError.authenticationFailed?:
                    message = "There was a problem verifying your identity"
                case LAError.userCancel?:
                    message = "You pressed cancel"
                case LAError.userFallback?:
                    message = "You pressed password"
                case LAError.biometryNotAvailable?:
                    message = "Face ID/Touch ID is not available"
                case LAError.biometryNotEnrolled?:
                    message = "Face ID/Touch ID is not set up"
                case LAError.biometryLockout?:
                    message = "Face ID/Touch ID is locked"
                default:
                    message = "Face ID/Touch ID is not be configured"
                }
                
                completion(message)
            }
        }
    }
}

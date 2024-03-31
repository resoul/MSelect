//
//  AuthController.swift
//  iOS
//

import UIKit
import Combine
import AuthenticationServices

class AuthController: UIViewController {
    
    private let networkViewModel = NetworkViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var logoView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "logo")
        
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let button = ASAuthorizationAppleIDButton(type: .default, style: .whiteOutline)
        button.addTarget(self, action: #selector(handleAppleIDButton), for: .touchUpInside)
        view.addSubviews(logoView, button)
        button.constraints(top: nil, leading: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 20, right: 0), size: .init(width: 350, height: 50))
        button.fillXCenter(for: view)
        logoView.fillCenter(for: view, size: .init(width: 640, height: 640))
    }
    
    private func handleData(_ data: Data?, userIdentifier: String) {
        if let data = data {
            print("handleData", data)
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(Account.self, from: data)
                print(response)
                try KeychainItem(service: "org.airlance.iOS", account: "userIdentifier").saveItem(userIdentifier)
            } catch {
                print(error)
            }
        }
    }
    
    @objc
    func handleAppleIDButton() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

extension AuthController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential, let token = credential.identityToken else {
            return
        }
        print(credential.fullName)
        print(credential.email)
        
        if let identityToken = String(data: token, encoding: .utf8) {
            networkViewModel.$data
                .sink { [weak self] in self?.handleData($0, userIdentifier: credential.user)}
                .store(in: &cancellables)
            networkViewModel.validateToken(for: URL(string: "https://example.com/token")!, token: identityToken)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        if let error = error as? ASAuthorizationError {
            switch error.code {
            case .canceled:
                print("User cancelled authorization request.")
            case .unknown:
                print("Unknown error occurred.")
            case .invalidResponse:
                print("Invalid response received.")
            case .notHandled:
                print("Authorization request not handled.")
            case .failed:
                print("Authorization request failed.")
            default:
                print("Unexpected error occurred.")
            }
        }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = view.window else {
            return UIWindow()
        }
        
        return window
    }
}

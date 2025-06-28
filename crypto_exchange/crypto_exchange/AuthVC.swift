//
//  AuthVC.swift
//  crypto_exchange
//
//  Created by Nikita Makhov on 02.06.2025.
//

import UIKit

class AuthVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        addPlaceHolder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        switch textField {
        case emailTextField:
            return updatedText.count <= 64
        case passwordTextField:
            return updatedText.count <= 128
        default:
            return true
        }
    }
    func addPlaceHolder() {
        let textFields: [UITextField] = [emailTextField, passwordTextField]
        let placeholders = ["Email", "Пароль"]
        
        for (index, field) in textFields.enumerated() {
            if index < placeholders.count {
                field.placeholder = placeholders[index]
            }
        }
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        guard
            let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty
        else { return }
        
        let url = URL(string: "http://127.0.0.1:8000/authorize_user")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { return }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let authorized = json["authorized"] as? Bool,
               let id = json["id"] as? Int,
               let name = json["name"] as? String,
               authorized {
                DispatchQueue.main.async {
                    UserDefaults.standard.set(id, forKey: "user_id")
                    UserDefaults.standard.set(name, forKey: "user_name")
                    UserDefaults.standard.set(true, forKey: "isAuthorized")
                    if let window = UIApplication.shared.windows.first {
                        window.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
                        window.makeKeyAndVisible()
                    }                }
            } else {
                print("Ошибка: неверные данные или пользователь не найден")
            }
        }.resume()
    }
    
    @IBAction func backToRegistrationAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}

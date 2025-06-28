//
//  RegisterVC.swift
//  crypto_exchange
//
//  Created by Nikita Makhov on 02.06.2025.
//

import UIKit

class RegisterVC: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var supportLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var authorizationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        addPlaceHolder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        switch textField {
        case nameTextField, emailTextField:
            return updatedText.count <= 64
        case passwordTextField:
            return updatedText.count <= 128
        default:
            return true
        }
    }
    func addPlaceHolder() {
        let textFields: [UITextField] = [nameTextField, emailTextField, passwordTextField]
        let placeholders = ["Имя", "Email", "Пароль"]

        for (index, field) in textFields.enumerated() {
            if index < placeholders.count {
                field.placeholder = placeholders[index]
            }
        }
    }
    
    @IBAction func registerTapped(_ sender: UIButton) {
        guard
            let name = nameTextField.text, !name.isEmpty,
            let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty
        else { return }

        let checkUrl = URL(string: "http://127.0.0.1:8000/check_user")!
        var request = URLRequest(url: checkUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["name": name]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { return }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let exists = json["exists"] as? Bool {
                DispatchQueue.main.async {
                    if exists {
                        self.performSegue(withIdentifier: "toAuth", sender: nil)
                    } else {
                        self.registerUser(name: name, email: email, password: password)
                    }
                }
            }
        }.resume()
    }

    func registerUser(name: String, email: String, password: String) {
        let url = URL(string: "http://127.0.0.1:8000/register_user")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["name": name, "email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { return }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let id = json["id"] as? Int,
               let name = json["name"] as? String {
                DispatchQueue.main.async {
                    UserDefaults.standard.set(id, forKey: "user_id")
                    UserDefaults.standard.set(name, forKey: "user_name")
                    UserDefaults.standard.set(true, forKey: "isAuthorized")
                    if let window = UIApplication.shared.windows.first {
                        window.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
                        window.makeKeyAndVisible()
                    }
                }
            }
        }.resume()
    }
    @IBAction func authorizationAction(_ sender: UIButton) {
        let authVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AuthVC")
        authVC.modalPresentationStyle = .fullScreen
        present(authVC, animated: true)
    }


}

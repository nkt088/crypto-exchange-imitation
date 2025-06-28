////
////  ViewController.swift
////  crypto_exchange
////
////  Created by Nikita Makhov on 31.05.2025.
////
//import UIKit
//
//struct User: Decodable {
//    let id: Int
//    let name: String
//    let email: String
//}
//class ViewController: UIViewController, UITableViewDataSource {
//    
//    @IBOutlet weak var tableView: UITableView!
//    var users: [User] = []
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        tableView.dataSource = self
//
//        // Регистрируем стандартную ячейку с подзаголовком
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
//    }
//    @IBAction func loadUsersButtonTapped(_ sender: UIButton) {
//        fetchUsers()
//    }
//    func fetchUsers() {
//        guard let url = URL(string: "http://127.0.0.1:8000/users") else { return }
//
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            guard let data = data else { return }
//            do {
//                let fetched = try JSONDecoder().decode([User].self, from: data)
//                DispatchQueue.main.async {
//                    self.users = fetched
//                    self.tableView.reloadData()
//                }
//            } catch {
//                print("Ошибка декодирования: \(error)")
//            }
//        }.resume()
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return users.count
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let user = users[indexPath.row]
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "UserCell")
//        cell.textLabel?.text = user.name
//        cell.detailTextLabel?.text = user.email
//        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
//        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
//        cell.detailTextLabel?.textColor = .gray
//        return cell
//    }
//    
//}


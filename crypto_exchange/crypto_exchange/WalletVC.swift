import UIKit
struct Wallet: Decodable {
    let id_wallet: Int
    let currency: String
    let balance: Double
}
class WalletVC: UIViewController, UITableViewDataSource, UITableViewDelegate, ColorsThemed {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!

    var wallets: [Wallet] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        applyTheme()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchWallets()
    }
    func applyTheme() {
        addButton.setTitle(nil, for: .normal)
        addButton.layer.cornerRadius = 20
        addButton.tintColor = .white
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.backgroundColor = ButtonColor
        
        let labels = [titleLabel]
        for label in labels {
            label?.textColor = TintTitleColor
        }
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
    }
    @IBAction func addWalletTapped(_ sender: UIButton) {
        let userId = UserDefaults.standard.integer(forKey: "user_id")

        let wallet: [String: Any] = [
            "currency": "USD",
            "balance": 0.0,
            "user_id": userId
        ]

        guard let url = URL(string: "http://127.0.0.1:8000/add_wallet") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: wallet)

        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                self.fetchWallets()
            }
        }.resume()
    }

    func fetchWallets() {
        let userId = UserDefaults.standard.integer(forKey: "user_id")
        guard userId > 0 else { return }

        guard let url = URL(string: "http://127.0.0.1:8000/wallets/\(userId)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            if let wallets = try? JSONDecoder().decode([Wallet].self, from: data) {
                DispatchQueue.main.async {
                    self.wallets = wallets
                    self.tableView.reloadData()

                    // Сохраняем количество кошельков
                    UserDefaults.standard.set(wallets.count, forKey: "wallets_count")

                    // Считаем и сохраняем общий баланс
                    let total = wallets.reduce(0.0) { $0 + $1.balance }
                    UserDefaults.standard.set(total, forKey: "wallets_total_balance")
                }
            }
        }.resume()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallets.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let wallet = wallets[indexPath.row]
        let (cell, bgView) = makeBaseCell(tableView: tableView, height: 50)

        let titleLabel = UILabel(frame: CGRect(x: 12, y: 6, width: bgView.frame.width - 24, height: 20))
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.text = "Wallet \(wallet.id_wallet)"

        let subtitleLabel = UILabel(frame: CGRect(x: 12, y: 26, width: bgView.frame.width - 24, height: 18))
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        subtitleLabel.text = "Balance: $\(String(format: "%.2f", wallet.balance)) — \(wallet.currency)"

        bgView.addSubview(titleLabel)
        bgView.addSubview(subtitleLabel)
        return cell
//        let wallet = wallets[indexPath.row]
//        let cell = UITableViewCell(style: .default, reuseIdentifier: "WalletCell")
//
//        for subview in cell.contentView.subviews {
//            subview.removeFromSuperview()
//        }
//
//        let inset: CGFloat = 16
//        let bgView = UIView(frame: CGRect(x: inset, y: 5, width: tableView.bounds.width - 2 * inset, height: 50))
//        bgView.backgroundColor = .white
//        bgView.layer.cornerRadius = 12
//        bgView.layer.masksToBounds = true
//
//        let titleLabel = UILabel(frame: CGRect(x: 12, y: 6, width: bgView.frame.width - 24, height: 20))
//        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
//        titleLabel.text = "Wallet \(wallet.id_wallet)"
//
//        let subtitleLabel = UILabel(frame: CGRect(x: 12, y: 26, width: bgView.frame.width - 24, height: 18))
//        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
//        subtitleLabel.textColor = .gray
//        subtitleLabel.text = "Balance: $\(String(format: "%.2f", wallet.balance)) — \(wallet.currency)"
//
//        bgView.addSubview(titleLabel)
//        bgView.addSubview(subtitleLabel)
//        cell.contentView.addSubview(bgView)
//
//        cell.backgroundColor = .clear
//        cell.contentView.backgroundColor = .clear
//        cell.selectionStyle = .none
//        return cell
    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let wallet = wallets[indexPath.row]
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "WalletCell")
//        cell.textLabel?.text = "Wallet \(wallet.id_wallet)"
//        cell.detailTextLabel?.text = "Balance: $\(String(format: "%.2f", wallet.balance)) — \(wallet.currency)"
//        return cell
//    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let wallet = wallets[indexPath.row]

        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { (_, _, completionHandler) in
            if wallet.balance != 0 {
                let alert = UIAlertController(title: "Ошибка", message: "Нельзя удалить кошелёк с ненулевым балансом", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ок", style: .default))
                self.present(alert, animated: true)
                completionHandler(false)
                return
            }

            guard let url = URL(string: "http://127.0.0.1:8000/delete_wallet/\(wallet.id_wallet)") else {
                completionHandler(false)
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"

            URLSession.shared.dataTask(with: request) { _, _, _ in
                DispatchQueue.main.async {
                    self.fetchWallets()
                    completionHandler(true)
                }
            }.resume()
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    //размер ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

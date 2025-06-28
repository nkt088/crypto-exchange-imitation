import UIKit

class BuySellCrypto: UIViewController, UITableViewDelegate, UITableViewDataSource, ColorsThemed {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var walletTextField: UITextField!
    @IBOutlet weak var walletTableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!

    var crypto: Cryptocurrency!
    var wallets: [Wallet] = []
    var walletId: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        
        walletTextField.addTarget(self, action: #selector(walletTextFieldTapped), for: .editingDidBegin)
        walletTableView.delegate = self
        walletTableView.dataSource = self
        walletTableView.isScrollEnabled = true
        walletTableView.isHidden = true

        fetchWallets()
    }
    func applyTheme() {
        titleLabel.text = "Торговля"
        currencyLabel.text = "Валюта: \(crypto.name)"
        priceLabel.text = String(format: "Цена: $%.2f", crypto.price)

        navigationItem.hidesBackButton = true
        
        let buttons = [cancelButton, confirmButton ]
        for button in buttons {
            button?.layer.cornerRadius = 12
            button?.tintColor = .white
        }
        cancelButton.backgroundColor = .systemGray
        confirmButton.backgroundColor = ButtonColor
        
        let labels = [currencyLabel,priceLabel]
        for label in labels {
            label?.textColor = TintColorWhite
        }
        titleLabel.textColor = TintTitleColor
        view.backgroundColor = BackGroundColor
        segmentedControl.backgroundColor = .clear
        
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        updateSegmentColor()
    }

    @objc func segmentChanged() {
        updateSegmentColor()
    }

    func updateSegmentColor() {
        if segmentedControl.selectedSegmentIndex == 0 {
            segmentedControl.selectedSegmentTintColor = .systemGreen
        } else {
            segmentedControl.selectedSegmentTintColor = .systemRed
        }
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
                    self.walletTableView.reloadData()
                }
            }
        }.resume()
    }

    @objc private func walletTextFieldTapped() {
        walletTableView.reloadData()
        walletTableView.isHidden = false
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let wallet = wallets[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "WalletCell")
        cell.textLabel?.text = "Wallet (\(wallet.id_wallet))"
        cell.detailTextLabel?.text = "Баланс: \(String(format: "%.2f", wallet.balance)) — \(wallet.currency)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedWallet = wallets[indexPath.row]
        walletTextField.text = "Wallet (\(selectedWallet.id_wallet))"
        walletId = selectedWallet.id_wallet
        walletTableView.isHidden = true
        view.endEditing(true)
    }

    @IBAction func cancelTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func confirmTapped(_ sender: UIButton) {
        guard let text = amountTextField.text,
              !text.isEmpty,
              let amount = Float(text),
              walletId != 0 else {
            showAlert("Введите сумму и выберите кошелёк")
            return
        }

        let userId = UserDefaults.standard.integer(forKey: "user_id")
        let orderType = segmentedControl.selectedSegmentIndex == 0

        let order = [
            "id_users": userId,
            "id_currency": crypto.id,
            "order_count_currency": amount,
            "order_type": orderType,
            "order_status": true
        ] as [String: Any]

        guard let url = URL(string: "http://127.0.0.1:8000/create_order") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: order)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { return }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let orderId = json["id_order"] as? Int {
                self.createTransaction(orderId: orderId)
            }
        }.resume()
    }

    private func createTransaction(orderId: Int) {
        let transaction = [
            "id_wallet": walletId,
            "id_order": orderId,
            "id_currency": crypto.id,
            "trans_status": true
        ] as [String: Any]

        guard let url = URL(string: "http://127.0.0.1:8000/create_transaction") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: transaction)

        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }.resume()
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}

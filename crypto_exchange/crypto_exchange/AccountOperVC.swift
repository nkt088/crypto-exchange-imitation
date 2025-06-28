import UIKit

struct AccountOperRequest: Codable {
    let id_wallet: Int
    let account_oper_sum: Float
    let account_oper_currency: String
    let account_oper_type: Bool
}

class AccountOperVC: UIViewController, UITableViewDelegate, UITableViewDataSource, ColorsThemed {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var addOperButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var walletsTextField: UITextField!
    @IBOutlet weak var walletsTableView: UITableView!

    var walletId: Int = 0
    var wallets: [Wallet] = []
    var accountOperType: Bool = true // true — пополнение, false — вывод
    var selectedWalletBalance = 0.0

    private var overlayView: UIView?
    private var activityIndicator: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        walletsTextField.addTarget(self, action: #selector(walletsTextFieldTapped), for: .editingDidBegin)
        walletsTableView.delegate = self
        walletsTableView.dataSource = self
        walletsTableView.isHidden = true
        fetchWallets()
        let buf = accountOperType ? "Пополнение" : "Вывод на карту"
        actionLabel.text = "Операция: " + buf
    }

    func applyTheme() {
        titleLabel.text = "Операции со счётом"
        navigationItem.hidesBackButton = true
        walletsTextField.placeholder = "Выберите кошелёк"
        [cancelButton, addOperButton].forEach {
            $0?.layer.cornerRadius = 12
            $0?.tintColor = .white
        }
        actionLabel.textColor = TintColorWhite
        cancelButton.backgroundColor = .systemGray
        addOperButton.backgroundColor = ButtonColor
        titleLabel.textColor = TintTitleColor
        view.backgroundColor = BackGroundColor
    }

    func fetchWallets() {
        let userId = UserDefaults.standard.integer(forKey: "user_id")
        guard let url = URL(string: "http://127.0.0.1:8000/wallets/\(userId)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let wallets = try? JSONDecoder().decode([Wallet].self, from: data) else { return }
            DispatchQueue.main.async {
                self.wallets = wallets
                self.walletsTableView.reloadData()
            }
        }.resume()
    }

    @objc private func walletsTextFieldTapped() {
        walletsTableView.isHidden = false
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let wallet = wallets[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "WalletCell")
        cell.textLabel?.text = "Wallet (\(wallet.id_wallet))"
        cell.detailTextLabel?.text = "Баланс: \(String(format: "%.2f", wallet.balance)) \(wallet.currency)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wallet = wallets[indexPath.row]
        walletsTextField.text = "Wallet (\(wallet.id_wallet))"
        walletId = wallet.id_wallet
        selectedWalletBalance = Double(wallet.balance)
        walletsTableView.isHidden = true
        view.endEditing(true)
    }

    @IBAction func cancelTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func addOperTapped(_ sender: UIButton) {
        guard
            let text = amountTextField.text,
            !text.isEmpty,
            let amount = Float(text),
            walletId != 0
        else {
            showAlert("Введите сумму и выберите кошелёк")
            return
        }
        if !accountOperType && Double(amount) > selectedWalletBalance {
            showAlert("Недостаточно средств на кошельке для вывода")
            return
        }
        let operData = AccountOperRequest(
            id_wallet: walletId,
            account_oper_sum: amount,
            account_oper_currency: "USD",
            account_oper_type: accountOperType
        )

        guard let url = URL(string: "http://127.0.0.1:8000/account_oper") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(operData)

        showLoadingOverlay()

        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.hideLoadingOverlay()
                let successAlert = UIAlertController(title: "Успешно", message: "Перевод успешно выполнен", preferredStyle: .alert)
                successAlert.addAction(UIAlertAction(title: "Ок", style: .default) { _ in
                    self.navigationController?.popViewController(animated: true)
                })
                self.present(successAlert, animated: true)
            }
        }.resume()
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }

    private func showLoadingOverlay() {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        let blur = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = overlay.bounds
        overlay.addSubview(blurView)

        let indicator = UIActivityIndicatorView(style: .large)
        indicator.center = overlay.center
        indicator.startAnimating()
        overlay.addSubview(indicator)

        view.addSubview(overlay)

        self.overlayView = overlay
        self.activityIndicator = indicator
    }

    private func hideLoadingOverlay() {
        activityIndicator?.stopAnimating()
        overlayView?.removeFromSuperview()
        overlayView = nil
        activityIndicator = nil
    }
}

import UIKit

class AddStakingVC: UIViewController, UITableViewDelegate, UITableViewDataSource, ColorsThemed {

    struct StakingRequest: Codable {
        let id_wallet: Int
        let staking_start_date: String
        let staking_end_date: String
        let staking_sum: Float
        let staking_percentage: Float
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var finishDateLabel: UILabel!
    @IBOutlet weak var stakeLabel: UILabel!
    @IBOutlet weak var stakeAmountTextField: UITextField!
    @IBOutlet weak var startStakeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    @IBOutlet weak var walletsTextField: UITextField!
    @IBOutlet weak var walletsTableView: UITableView!

    var walletId: Int = 0
    private let percentage: Float = 20.0
    private let startDate = Date()
    private let endDate = Calendar.current.date(byAdding: .month, value: 3, to: Date())!

    var wallets: [Wallet] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        walletsTextField.addTarget(self, action: #selector(walletsTextFieldTapped), for: .editingDidBegin)

        walletsTableView.delegate = self
        walletsTableView.dataSource = self
        walletsTableView.isScrollEnabled = true
        walletsTableView.isHidden = true

        fetchWallets()
    }
    func applyTheme() {
        titleLabel.text = "Начать стейкинг"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        startDateLabel.text = "Дата открытия: \(formatter.string(from: startDate))"
        finishDateLabel.text = "Дата окончания: \(formatter.string(from: endDate))"
        stakeLabel.text = "Доступный процент: \(Int(percentage)) %"

        navigationItem.hidesBackButton = true

        walletsTextField.placeholder = "Выберите кошелёк"
        
        let buttons = [cancelButton, startStakeButton ]
        for button in buttons {
            button?.layer.cornerRadius = 12
            button?.tintColor = .white
        }
        cancelButton.backgroundColor = .systemGray
        startStakeButton.backgroundColor = ButtonColor
        
        let labels = [startDateLabel,finishDateLabel, stakeLabel]
        for label in labels {
            label?.textColor = TintColorWhite
        }
        titleLabel.textColor = TintTitleColor
        view.backgroundColor = BackGroundColor
        
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
                    self.walletsTableView.reloadData()

                    for wallet in wallets {
                        print("Кошелёк ID: \(wallet.id_wallet), Валюта: \(wallet.currency), Баланс: \(wallet.balance)")
                    }
                }
            }
        }.resume()
    }

    @objc private func walletsTextFieldTapped() {
        walletsTableView.reloadData()
        walletsTableView.isHidden = false
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
        walletsTextField.text = "Wallet (\(selectedWallet.id_wallet))"
        walletId = selectedWallet.id_wallet
        walletsTableView.isHidden = true
        view.endEditing(true)
    }

    @IBAction func cancelTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func startStakeTapped(_ sender: UIButton) {
        guard let text = stakeAmountTextField.text,
              !text.isEmpty,
              let amount = Float(text),
              walletId != 0 else {
            showAlert("Введите сумму и выберите кошелёк")
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let stakingData = StakingRequest(
            id_wallet: walletId,
            staking_start_date: formatter.string(from: startDate),
            staking_end_date: formatter.string(from: endDate),
            staking_sum: amount,
            staking_percentage: percentage
        )

        guard let url = URL(string: "http://127.0.0.1:8000/add_staking") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(stakingData)

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

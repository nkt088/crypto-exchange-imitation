
import UIKit

class CustomerVC: UIViewController, ColorsThemed {
//просто заголовки
    @IBOutlet weak var userTitle: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var balanceTitle: UILabel!
    @IBOutlet weak var walletCountTitle: UILabel!
//label для userDefault значений
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var walletCount: UILabel!
    
    
    
    @IBOutlet weak var addFundButton: UIButton!
    @IBOutlet weak var sendFromButton: UIButton!
    @IBOutlet weak var logoutUserButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserInfo()
        applyTheme()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserInfo()
    }
    func applyTheme() {
        titleLabel.textColor = TintTitleColor
        let labels = [userTitle, balanceTitle, walletCountTitle ]
        for label in labels {
            label?.textColor = TintColorWhite
        }
        let labelsValue = [userName, balance, walletCount ]
        for label in labelsValue {
            label?.textColor = TintColorWhite
            label?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        }
        let buttons = [addFundButton,sendFromButton]
        for button in buttons {
            button?.layer.cornerRadius = 12
            button?.tintColor = .white
            button?.backgroundColor = ButtonColor
        }
        logoutUserButton.tintColor = .systemRed
    }
    func loadUserInfo() {
            let defaults = UserDefaults.standard
            userName.text = defaults.string(forKey: "user_name") ?? "Неизвестный"
            balance.text = String(format: "$%.2f", defaults.double(forKey: "wallets_total_balance"))
            walletCount.text = String(defaults.integer(forKey: "wallets_count"))
        }
    
    @IBAction func addMoneyAction(_ sender: UIButton) {
        openAccountOperVC(isDeposit: true)
    }

    @IBAction func sendOutAction(_ sender: UIButton) {
        openAccountOperVC(isDeposit: false)
    }

    private func openAccountOperVC(isDeposit: Bool) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "AccountOperVC") as? AccountOperVC {
            vc.accountOperType = isDeposit
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func logoutTapped(_ sender: UIButton) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "user_id")
        defaults.removeObject(forKey: "user_name")
        defaults.removeObject(forKey: "wallets_count")
        defaults.removeObject(forKey: "wallets_total_balance")
        defaults.set(false, forKey: "isAuthorized")

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registerVC = storyboard.instantiateViewController(withIdentifier: "RegisterVC")
        registerVC.modalPresentationStyle = .fullScreen
        self.present(registerVC, animated: true)
    }
}

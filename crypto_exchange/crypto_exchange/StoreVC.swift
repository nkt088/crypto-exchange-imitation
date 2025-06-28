import UIKit

struct Cryptocurrency: Decodable {
    let id: Int
    let name: String
    let price: Float
}

class StoreVC: UIViewController, UITableViewDataSource, UITableViewDelegate, ColorsThemed {

    var cryptos: [Cryptocurrency] = []

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        applyTheme()
        fetchCryptocurrencies()
    }
    func applyTheme() {
        let labels = [titleLabel]
        for label in labels {
            label?.textColor = TintTitleColor
        }
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
        applyTheme()
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "isAuthorized") == nil {
            defaults.set(false, forKey: "isAuthorized")
        }

        let isAuthorized = defaults.bool(forKey: "isAuthorized")
        let userIdExists = defaults.object(forKey: "user_id") != nil

        // Если не авторизован или нет user_id, показать регистрацию
        if !isAuthorized || !userIdExists {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let registerVC = storyboard.instantiateViewController(withIdentifier: "RegisterVC")
            registerVC.modalPresentationStyle = .fullScreen
            self.present(registerVC, animated: false)
        }
    }
    func fetchCryptocurrencies() {
        guard let url = URL(string: "http://127.0.0.1:8000/cryptocurrencies") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else { return }
            do {
                let decoded = try JSONDecoder().decode([Cryptocurrency].self, from: data)
                DispatchQueue.main.async {
                    self.cryptos = decoded
                    self.tableView.reloadData()
                }
            } catch {
                print("Ошибка при декодировании: \(error)")
            }
        }.resume()
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cryptos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let crypto = cryptos[indexPath.row]
//        let cell = UITableViewCell(style: .value1, reuseIdentifier: "CryptoCell")
//        cell.textLabel?.text = crypto.name
//        cell.detailTextLabel?.text = String(format: "$%.2f", crypto.price)
//        return cell
        //это все код для скругления
        
        
//        let cell = UITableViewCell(style: .default, reuseIdentifier: "CryptoCell")
//
//        for subview in cell.contentView.subviews {
//            subview.removeFromSuperview()
//        }
//
//        let inset: CGFloat = 16
//        let bgView = UIView(frame: CGRect(x: inset, y: 5, width: tableView.bounds.width - 2*inset, height: 36))
//        bgView.backgroundColor = .white
//        bgView.layer.cornerRadius = 12
//        bgView.layer.masksToBounds = true
//
//        let nameLabel = UILabel(frame: CGRect(x: 12, y: 8, width: 80, height: 20))
//        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
//        nameLabel.text = crypto.name
//        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
//
//        let priceLabel = UILabel(frame: CGRect(x: bgView.frame.width - 80 - 12, y: 8, width: 80, height: 20))
//        priceLabel.font = UIFont.systemFont(ofSize: 14)
//        priceLabel.text = String(format: "$%.2f", crypto.price)
//        priceLabel.font = UIFont.systemFont(ofSize: 16)
//
//        bgView.addSubview(nameLabel)
//        bgView.addSubview(priceLabel)
//        cell.contentView.addSubview(bgView)
//
//        cell.backgroundColor = .clear
//        cell.contentView.backgroundColor = .clear
//        cell.selectionStyle = .none
//        return cell
        let crypto = cryptos[indexPath.row]
        let (cell, bgView) = makeBaseCell(tableView: tableView, height: 36)

        let nameLabel = UILabel(frame: CGRect(x: 12, y: 8, width: 80, height: 20))
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nameLabel.text = crypto.name

        let priceLabel = UILabel(frame: CGRect(x: bgView.frame.width - 80 - 12, y: 8, width: 80, height: 20))
        priceLabel.font = UIFont.systemFont(ofSize: 16)
        priceLabel.text = String(format: "$%.2f", crypto.price)

        bgView.addSubview(nameLabel)
        bgView.addSubview(priceLabel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "BuySellCrypto") as! BuySellCrypto
        vc.crypto = cryptos[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //размер ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

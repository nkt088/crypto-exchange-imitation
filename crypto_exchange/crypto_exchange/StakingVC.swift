//
//  StakingTVC.swift
//  crypto_exchange
//
//  Created by Nikita Makhov on 02.06.2025.
//

import UIKit

struct Staking: Decodable {
    let id: Int
    let sum: Double
    let percent: Double
    let start: String
    let end: String
}

class StakingVC: UIViewController, UITableViewDataSource, UITableViewDelegate, ColorsThemed {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var stakings: [Staking] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        addButton.setTitle(nil, for: .normal)
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.layer.cornerRadius = 20
        addButton.backgroundColor = .systemYellow
        //fetchStakingData()
        applyTheme()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchStakingData()
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
    func fetchStakingData() {
        guard let userId = UserDefaults.standard.object(forKey: "user_id") as? Int else { return }
        guard let url = URL(string: "http://127.0.0.1:8000/staking/\(userId)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            if let decoded = try? JSONDecoder().decode([Staking].self, from: data) {
                DispatchQueue.main.async {
                    self.stakings = decoded
                    self.tableView.reloadData()
                }
            }
        }.resume()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stakings.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let staking = stakings[indexPath.row]
        let (cell, bgView) = makeBaseCell(tableView: tableView, height: 50)

        let titleLabel = UILabel(frame: CGRect(x: 12, y: 6, width: bgView.frame.width - 24, height: 20))
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.text = "$\(staking.sum)  •  \(staking.percent)%"

        let subtitleLabel = UILabel(frame: CGRect(x: 12, y: 26, width: bgView.frame.width - 24, height: 18))
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        subtitleLabel.text = "с \(staking.start) по \(staking.end)"

        bgView.addSubview(titleLabel)
        bgView.addSubview(subtitleLabel)
        return cell
        
//        let staking = stakings[indexPath.row]
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "StakingCell")
//        
//        // Основной текст: сумма и процент
//        cell.textLabel?.text = "$\(staking.sum)  •  \(staking.percent)%"
//        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
//        
//        // Подзаголовок: даты
//        cell.detailTextLabel?.text = "с \(staking.start) по \(staking.end)"
//        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
//        cell.detailTextLabel?.textColor = .gray
//        
//        return cell
    }
    
    
    @IBAction func addStakingTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddStakingVC") as! AddStakingVC
        navigationController?.pushViewController(vc, animated: true)
    }
    //размер ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

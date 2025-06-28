//
//  cellStyle.swift
//  crypto_exchange
//
//  Created by Nikita Makhov on 07.06.2025.
//

import Foundation
import UIKit
func makeBaseCell(tableView: UITableView, height: CGFloat) -> (UITableViewCell, UIView) {
    let cell = UITableViewCell(style: .default, reuseIdentifier: nil)

    for subview in cell.contentView.subviews {
        subview.removeFromSuperview()
    }

    let inset: CGFloat = 16
    let bgView = UIView(frame: CGRect(x: inset, y: 5, width: tableView.bounds.width - 2 * inset, height: height))
    bgView.backgroundColor = .white
    bgView.layer.cornerRadius = 12
    bgView.layer.masksToBounds = true

    cell.contentView.addSubview(bgView)
    cell.backgroundColor = .clear
    cell.contentView.backgroundColor = .clear
    cell.selectionStyle = .none

    return (cell, bgView)
}

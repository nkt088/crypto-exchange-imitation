import UIKit

// Протокол
protocol ColorsThemed {
    var TintColorDark: UIColor { get }
    var ButtonColor: UIColor { get }
    var SupportColor: UIColor { get }
    var BackGroundColor: UIColor { get }
    var TabBarColor: UIColor { get }
    var TintColorWhite: UIColor { get }

    func applyTheme()
}

// Реализация по умолчанию
extension ColorsThemed {
    var TintColorDark: UIColor { UIColor(hex: "#1E1F26") }   // Темный синий, текст
    var ButtonColor: UIColor { UIColor(hex: "#EFB509") }     // золотой, кнопка
    var SupportColor: UIColor { UIColor(hex: "#4D648D") }    // синий
    var BackGroundColor: UIColor { UIColor(hex: "#1A3E66") } // Тёмно-синий, фон //283655
    var TabBarColor: UIColor { UIColor(hex: "#16253D") }     // Глубокий синий, таббар
    var TintColorWhite: UIColor { UIColor(hex: "#D0E1F9") }  // Белый текст на тёмном фоне FBE8A6
    var TintTitleColor: UIColor { UIColor(hex: "#FBE8A6") }
}

// Hex инициализатор
extension UIColor {
    convenience init(hex: String) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hex.hasPrefix("#") { hex.removeFirst() }

        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

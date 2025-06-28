import UIKit

class CustomTabBarViewController: UITabBarController, ColorsThemed {
    func applyTheme() {
        //tabBar.barTintColor = ButtonColor
        tabBar.backgroundColor = TabBarColor
        tabBar.tintColor = ButtonColor
        tabBar.unselectedItemTintColor = TintColorWhite // цвет неактивных вкладок
        UITabBar.appearance().isTranslucent = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
//        viewControllers?.forEach { vc in
//            vc.view.backgroundColor = BackGroundColor
//        }
        viewControllers?.forEach { vc in
            if let nav = vc as? UINavigationController,
               let root = nav.viewControllers.first {
                root.view.backgroundColor = BackGroundColor
            } else {
                vc.view.backgroundColor = BackGroundColor
            }
        }
    }
}

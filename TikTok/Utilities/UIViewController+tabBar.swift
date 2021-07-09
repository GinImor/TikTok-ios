//
//  UIViewController+tabBar.swift
//  TikTok
//
//  Created by Gin Imor on 7/10/21.
//  
//

import UIKit

extension UIViewController {
  
  func wrapInNav(title: String) -> UINavigationController {
    let nav = UINavigationController(rootViewController: self)
    navigationItem.title = title
    return nav
  }
  
  func forTab(imageName: String) -> Self {
    tabBarItem.image = UIImage(systemName: imageName)
    view.backgroundColor = .systemBackground
    return self
  }
}

//
//  TabBarController.swift
//  TikTok
//
//  Created by Gin Imor on 7/9/21.
//  
//

import UIKit

class TabBarController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupChildren()
  }
  
  private func setupChildren() {
    setViewControllers([
      HomeViewController().wrapInNav(title: "Home").forTab(imageName: "house"),
      ExploreController().wrapInNav(title: "Explore").forTab(imageName: "magnifyingglass"),
      CameraController().forTab(imageName: "camera"),
      NotificationsController().wrapInNav(title: "Notifications").forTab(imageName: "bell"),
      ProfileController().wrapInNav(title: "Profile").forTab(imageName: "person.circle")
      ], animated: false)
  }
  
}

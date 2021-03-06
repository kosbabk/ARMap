//
//  BaseNavigationController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit

class BaseNavigationController : UINavigationController, PresentableController {
  
  // MARK: - PresentableController
  
  var presentedMode: PresentationMode = .modal(.formSheet, .coverVertical)
  var presentationManager: UIViewControllerTransitioningDelegate? = nil
  var currentFlowInitialController: PresentableController? = nil
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationBar.prefersLargeTitles = true
  }
  
  // MARK: - NavigationBarStyle
  
  enum NavigationBarStyle {
    case standard, transparent, transparentBlack
    
    var isTranslucent: Bool {
      switch self {
      case .standard:
        return false
      case .transparent, .transparentBlack:
        return true
      }
    }
    
    var barTintColor: UIColor {
      switch self {
      case .standard:
        return .white
      case .transparent, .transparentBlack:
        return .clear
      }
    }
    
    var tintColor: UIColor {
      switch self {
      case .standard:
        return .kozBlue
      case .transparent:
        return .white
      case .transparentBlack:
        return .black
      }
    }
    
    var titleTextAttributes: [NSAttributedStringKey : Any]? {
      switch self {
      case .standard:
        return [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: .regular), NSAttributedStringKey.foregroundColor: UIColor.black ]
      case .transparent:
        return [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: .regular), NSAttributedStringKey.foregroundColor: UIColor.white ]
      case .transparentBlack:
        return [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: .regular), NSAttributedStringKey.foregroundColor: UIColor.black ]
      }
    }
    
    var largeTitleTextAttributes: [NSAttributedStringKey : Any]? {
      switch self {
      case .standard:
        return [ NSAttributedStringKey.foregroundColor: UIColor.black ]
      case .transparent:
        return [ NSAttributedStringKey.foregroundColor: UIColor.white ]
      case .transparentBlack:
        return [ NSAttributedStringKey.foregroundColor: UIColor.black ]
      }
    }
    
    var backIndicator: UIImage? {
      switch self {
      default:
        return nil
      }
    }
    
    var backItemTitle: String {
      switch self {
      default:
        return ""
      }
    }
  }
  
  convenience init(navigationBarStyle: NavigationBarStyle) {
    self.init()
    
    self.navigationBarStyle = navigationBarStyle
  }
  
  var navigationBarStyle: NavigationBarStyle = .standard {
    didSet {
      if self.navigationBarStyle != oldValue {
        self.applyNavigationBarStyles()
      }
    }
  }
  
  private func applyNavigationBarStyles() {
    
    // Title and tint
    self.navigationBar.barTintColor = self.navigationBarStyle.barTintColor
    self.navigationBar.tintColor = self.navigationBarStyle.tintColor
    self.navigationBar.titleTextAttributes = self.navigationBarStyle.titleTextAttributes
    self.navigationBar.largeTitleTextAttributes = self.navigationBarStyle.largeTitleTextAttributes
    self.navigationBar.isTranslucent = self.navigationBarStyle.isTranslucent
    
    switch self.navigationBarStyle {
    case .transparent:
      self.navigationBar.setBackgroundImage(UIImage(), for: .default)
      self.navigationBar.shadowImage = UIImage()
      self.navigationBar.backgroundColor = .clear
    default: break
    }
    
    // Update the status bar
    self.setNeedsStatusBarAppearanceUpdate()
  }
  
  // MARK: - Status Bar Style
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    switch self.navigationBarStyle {
    case .standard, .transparentBlack:
      if UIDevice.current.isPhone {
        return .default
      } else {
        switch self.presentedMode {
        case .modal(.fullScreen, _), .modal(.overFullScreen, _):
          return .default
        default:
          return .lightContent
        }
      }
    case .transparent:
      return .lightContent
    }
  }
}

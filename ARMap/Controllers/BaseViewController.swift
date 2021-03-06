//
//  BaseViewController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit

class BaseViewController : UIViewController, PresentableController {
  
  // MARK: - PresentableController
  
  var presentedMode: PresentationMode = .modal(.formSheet, .coverVertical)
  var presentationManager: UIViewControllerTransitioningDelegate? = nil
  var currentFlowInitialController: PresentableController? = nil
}

extension BaseViewController {
  
  var baseNavigationController: BaseNavigationController? {
    return self.navigationController as? BaseNavigationController
  }
}

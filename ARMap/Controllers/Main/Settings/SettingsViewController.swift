//
//  SettingsViewController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit

class SettingsViewController : BaseViewController, DesiredContentHeightDelegate, DismissInteractable {
  
  // MARK: - Static Accessors
  
  static func newViewController() -> SettingsViewController {
    let viewController = self.newViewController(fromStoryboardWithName: "Settings")
    viewController.preferredContentSize.height = viewController.desiredContentHeight
    return viewController
  }
  
  // MARK: - DesiredContentHeightDelegate
  
  var desiredContentHeight: CGFloat {
    return 250
  }
  
  // MARK: - DismissInteractable
  
  var dismissInteractiveViews: [UIView] {
    var views: [UIView] = []
    if let view = self.view {
      views.append(view)
    }
    return views
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var settingsLabel: UILabel!
  @IBOutlet weak var unitLabel: UILabel!
  @IBOutlet weak var unitTypeControl: UISegmentedControl!
  @IBOutlet weak var versionLabel: UILabel!
  @IBOutlet weak var companyLabel: UILabel!
  @IBOutlet weak var showAxisSwitch: UISwitch!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Settings"
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(self.closeButtonSelected))
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Reload content
    self.reloadContent()
  }
  
  // MARK: - Status Bar
  
  override var prefersStatusBarHidden: Bool {
    return UIDevice.current.isPhone
  }
  
  override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    return .slide
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: - Content
  
  func reloadContent() {
    
    // Settings label
    self.settingsLabel.isHidden = !UIDevice.current.isPhone
    
    // Unit type
    self.unitTypeControl.selectedSegmentIndex = Defaults.shared.unitType.rawValue
    
    // Show axis on start
    self.showAxisSwitch.isOn = Defaults.shared.showAxis
    
    // Version
    self.versionLabel.text = "Version \(UIApplication.shared.versionString ?? "N/A")"
    
    // Company
    self.companyLabel.text = BuildManager.shared.buildTarget.companyName
  }
  
  // MARK: - Actions
  
  @objc func closeButtonSelected() {
    self.dismissController()
  }
  
  @IBAction func segmentedControlValueChanged(_ control: UISegmentedControl) {
    switch control {
    case self.unitTypeControl:
      if let unitType = UnitType(rawValue: control.selectedSegmentIndex) {
        Defaults.shared.unitType = unitType
        MyDataManager.shared.saveMainContext()
      }
    default: break
    }
  }
  
  @IBAction func showAxisSwitchValueChanged(_ sender: UISwitch) {
    Defaults.shared.showAxis = sender.isOn
  }
}

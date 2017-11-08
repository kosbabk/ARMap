//
//  AddLocationViewController.swift
//  TackARLocation
//
//  Created by Kelvin Kosbab on 10/30/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import UIKit
import CoreLocation

protocol AddLocationViewControllerDelegate : class {
  func didSave(savedLocation: SavedLocation)
}

class AddLocationViewController : BaseViewController {
  
  // MARK: - Static Accessors
  
  private static func newViewController() -> AddLocationViewController {
    return self.newViewController(fromStoryboardWithName: "Main")
  }
  
  static func newViewController(location: CLLocation?, delegate: AddLocationViewControllerDelegate?) -> AddLocationViewController {
    let viewController = self.newViewController()
    viewController.location = location
    viewController.delegate = delegate
    return viewController
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addLocationButton: UIButton!
  @IBOutlet weak var colorChooserContainer: UIView!
  
  var locationColor: UIColor = UIColor.kozRed
  let preferredContentHeight: CGFloat = 238
  weak var delegate: AddLocationViewControllerDelegate? = nil
  weak var colorChooserController: InlineColorChooserViewController? = nil
  
  var location: CLLocation? = nil {
    didSet {
      if self.isViewLoaded {
        self.reloadContent()
      }
    }
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.nameTextField.delegate = self
    
    // Add color chooser
    let colorChooserController = InlineColorChooserViewController.newViewController(delegate: self)
    colorChooserController.view.backgroundColor = .clear
    self.add(childViewController: colorChooserController, intoContainerView: self.colorChooserContainer)
    self.colorChooserController = colorChooserController
    self.locationColor = colorChooserController.selectedColor
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Style button
    self.addLocationButton.layer.cornerRadius = 5
    self.addLocationButton.layer.masksToBounds = true
    self.addLocationButton.clipsToBounds = true
    
    // MARK: - Content
    self.reloadContent()
  }
  
  // MARK: - Content
  
  func reloadContent() {
    
    // Check if there is a location to populate
    guard let location = self.location else {
      self.addLocationButton.isUserInteractionEnabled = false
      self.addLocationButton.alpha = 0.5
      self.latitudeLabel.text = "NA"
      self.longitudeLabel.text = "NA"
      return
    }
    
    // Update the current location
    self.addLocationButton.isUserInteractionEnabled = true
    self.addLocationButton.alpha = 1
    let coordinate = location.coordinate
    let roundedLatitude = Double(round(coordinate.latitude*1000)/1000)
    let roundedLongitude = Double(round(coordinate.longitude*1000)/1000)
    self.latitudeLabel.text = "\(roundedLatitude)"
    self.longitudeLabel.text = "\(roundedLongitude)"
  }
  
  // MARK: - Actions
  
  @IBAction func addLocationButtonSelected() {
    self.saveLocation()
  }
  
  func saveLocation() {
    
    // Check for valid location
    guard let location = self.location else {
      return
    }
    
    // Check for valid name
    guard let name = self.nameTextField.text else {
      return
    }
    
    // Dismiss the keyboard
    self.nameTextField.resignFirstResponder()
    
    // Color of the saved location
    let color = Color.create()
    color.color = self.locationColor
    
    // Save the location
    let savedLocation = SavedLocation.create(name: name, location: location, color: color)
    MyDataManager.shared.saveMainContext()
    self.delegate?.didSave(savedLocation: savedLocation)
  }
}

// MARK: - InlineColorChooserViewControllerDelegate

extension AddLocationViewController : InlineColorChooserViewControllerDelegate {
  
  func didSelect(color: UIColor) {
    self.locationColor = color
  }
}

// MARK: - UITextFieldDelegate

extension AddLocationViewController : UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if let _ = textField.text {
      return true
    }
    return false
  }
}

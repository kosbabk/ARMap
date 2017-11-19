//
//  InlineColorChooserViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/6/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import UIKit

protocol InlineColorChooserViewControllerDelegate : class {
  func didSelect(color: UIColor)
}

class InlineColorChooserViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  // MARK: - Static Accessors
  
  static func newViewController() -> InlineColorChooserViewController {
    return self.newViewController(fromStoryboardWithName: "AddLocation")
  }
  
  static func newViewController(delegate: InlineColorChooserViewControllerDelegate) -> InlineColorChooserViewController {
    let viewController = self.newViewController()
    viewController.delegate = delegate
    return viewController
  }
  
  // MARK: - Properties
  
  weak var delegate: InlineColorChooserViewControllerDelegate? = nil
  let colors: [UIColor] = [ .kozRed, .kozOrange, .kozYellow, .kozGreen, .kozBlue, .kozPurple ]
  private var selectedIndexPath: IndexPath? = nil
  
  var selectedColor: UIColor? {
    get {
      if let selectedIndexPath = self.selectedIndexPath {
        return self.colors[selectedIndexPath.row]
      }
      return nil
    }
    set {
      if let selectedIndexPath = newValue, let index = self.colors.index(of: selectedIndexPath) {
        
        // Deselect the old indexPath
        if let oldSelectedIndexPath = self.selectedIndexPath {
          self.collectionView?.deselectItem(at: oldSelectedIndexPath, animated: self.isViewLoaded)
        } else {
          self.collectionView?.reloadData()
        }
        
        // New selected color
        let indexPath = IndexPath(row: index, section: 0)
        self.selectedIndexPath = indexPath
        self.collectionView?.selectItem(at: indexPath, animated: self.isViewLoaded, scrollPosition: .centeredVertically)
      } else {
        self.selectedIndexPath = nil
        self.collectionView?.reloadData()
      }
    }
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.collectionView?.delegate = self
    self.collectionView?.dataSource = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let selectedIndexPath = self.selectedIndexPath {
      self.collectionView?.reloadItems(at: [ selectedIndexPath ])
    }
  }
  
  // MARK: - UICollectionView
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.colors.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InlineColorChooserCollectionViewCell", for: indexPath) as! InlineColorChooserCollectionViewCell
    let color = self.colors[indexPath.row]
    cell.colorView.backgroundColor = color
    cell.update(isSelected: self.selectedIndexPath == indexPath, animated: false)
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    // Selected color
    let color = self.colors[indexPath.row]
    self.selectedIndexPath = indexPath
    
    // Select the new color
    if let cell = self.collectionView?.cellForItem(at: indexPath) as? InlineColorChooserCollectionViewCell {
      cell.update(isSelected: true, animated: true)
    }
    
    // Notify the delegate
    self.delegate?.didSelect(color: color)
  }
  
  override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    
    // De-select the old color
    if let cell = self.collectionView?.cellForItem(at: indexPath) as? InlineColorChooserCollectionViewCell {
      cell.update(isSelected: false, animated: true)
    }
  }
  
  // MARK: - UICollectionViewDelegateFlowLayout
  
  var adjustedTotalViewWidth: CGFloat {
    return self.view.bounds.width - 20
  }
  
  var cellDimension: CGFloat {
    let desiredWidth = self.adjustedTotalViewWidth / CGFloat(self.colors.count)
    return min(desiredWidth, self.view.bounds.height)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let cellDimension = self.cellDimension
    return CGSize(width: cellDimension, height: cellDimension)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    // Asks the delegate for the spacing between successive rows or columns of a section.
    let cellDimension = self.cellDimension
    let totalCellWidth = cellDimension * CGFloat(self.colors.count)
    let remainingWidth = self.adjustedTotalViewWidth - totalCellWidth
    let desiredSpacing = remainingWidth / CGFloat(self.colors.count - 1)
    return desiredSpacing
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    // Asks the delegate for the spacing between successive items in the rows or columns of a section.
    return 0
  }
}

// MARK: - InlineColorChooserCollectionViewCell

class InlineColorChooserCollectionViewCell : UICollectionViewCell {
  @IBOutlet weak var colorView: UIView!
  @IBOutlet weak var selectedCircleView: UIImageView!
  @IBOutlet weak var selectedCircleViewHeight: NSLayoutConstraint!
  @IBOutlet weak var selectedCircleViewWidth: NSLayoutConstraint!
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.colorView.layer.cornerRadius = self.colorView.layer.bounds.height / 2
    self.colorView.layer.masksToBounds = true
    self.colorView.clipsToBounds = true
  }
  
  func update(isSelected: Bool, animated: Bool) {
    self.isSelected = isSelected
    let toDimension: CGFloat = isSelected ? 20 : 0
    let toAlpha: CGFloat = isSelected ? 0.75 : 0
    if animated {
      UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
        self?.selectedCircleView.alpha = toAlpha
        self?.selectedCircleViewHeight.constant = toDimension
        self?.selectedCircleViewWidth.constant = toDimension
      }, completion: nil)
    } else {
      self.selectedCircleView.alpha = toAlpha
      self.selectedCircleViewHeight.constant = toDimension
      self.selectedCircleViewWidth.constant = toDimension
      self.layoutSubviews()
    }
  }
}

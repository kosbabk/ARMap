//
//  AddLocationContainerViewController.swift
//  KozMap
//
//  Created by Kelvin Kosbab on 11/12/17.
//  Copyright © 2017 Tack Mobile. All rights reserved.
//

import UIKit
import CoreLocation

class AddLocationContainerViewController : BaseViewController, DesiredContentHeightDelegate, DismissInteractable, KeyboardFrameRespondable {
  
  // MARK: - Static Accessors
  
  private static func newViewController() -> AddLocationContainerViewController {
    let viewController = self.newViewController(fromStoryboardWithName: "AddLocation")
    viewController.preferredContentSize.height = viewController.desiredContentHeight
    return viewController
  }
  
  static func newViewController(locationDetailDelegate: AddLocationViewControllerDelegate?, searchDelegate: SearchViewControllerDelegate?) -> AddLocationContainerViewController {
    let viewController = self.newViewController()
    viewController.locationDetailDelegate = locationDetailDelegate
    viewController.searchDelegate = searchDelegate
    return viewController
  }
  
  // MARK: - DesiredContentHeightDelegate
  
  var desiredContentHeight: CGFloat {
    return 378
  }
  
  // MARK: - DismissInteractable
  
  var dismissInteractiveViews: [UIView] {
    var views: [UIView] = []
    if let view = self.view {
      views.append(view)
    }
    for viewController in self.orderedViewControllers {
      if let dismissInteractable = viewController as? DismissInteractable {
        views += dismissInteractable.dismissInteractiveViews
      }
    }
    return views
  }
  
  // MARK: - Properties
  
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  
  private(set) var pageViewController: UIPageViewController? = nil
  weak var locationDetailDelegate: AddLocationViewControllerDelegate? = nil
  weak var searchDelegate: SearchViewControllerDelegate? = nil
  
  private(set) lazy var orderedViewControllers: [UIViewController] = {
    let currentLocationViewController = AddLocationViewController.newViewController(delegate: self.locationDetailDelegate)
    let searchViewController = SearchViewController.newViewController(delegate: self.searchDelegate)
    return [ currentLocationViewController, searchViewController ]
  }()
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Add Placemark"
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(self.closeButtonSelected))
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    guard let identifier = segue.identifier else {
      return
    }
    
    switch identifier {
    case "EmbedPageController":
      if let pageViewController = segue.destination as? UIPageViewController {
        self.pageViewController = pageViewController
        pageViewController.dataSource = self
        pageViewController.delegate = self
        if let firstViewController = self.orderedViewControllers.first {
          pageViewController.setViewControllers([ firstViewController ], direction: .forward, animated: true, completion: nil)
        }
      }
    default: break
    }
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
  
  var currentSelectedIndex: Int {
    if let _ = self.pageViewController?.viewControllers?.first as? AddLocationViewController {
      return 0
    } else {
      return 1
    }
  }
  
  func reloadContent() {
    self.segmentedControl.selectedSegmentIndex = self.currentSelectedIndex
  }
  
  // MARK: - Actions
  
  @objc func closeButtonSelected() {
    self.dismissController()
  }
  
  @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0:
      if self.currentSelectedIndex != 0 {
        let viewController = self.orderedViewControllers[0]
        self.pageViewController?.setViewControllers([ viewController ], direction: .reverse, animated: true, completion: nil)
      }
    default:
      if self.currentSelectedIndex != 1 {
        let viewController = self.orderedViewControllers[1]
        self.pageViewController?.setViewControllers([ viewController ], direction: .forward, animated: true, completion: nil)
      }
    }
  }
}

// MARK: - UIPageViewControllerDataSource

extension AddLocationContainerViewController : UIPageViewControllerDataSource {
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    
    guard let viewControllerIndex = self.orderedViewControllers.index(of: viewController) else {
      return nil
    }
    
    let previousIndex = viewControllerIndex - 1
    
    guard previousIndex >= 0 else {
      return nil
    }
    
    guard self.orderedViewControllers.count > previousIndex else {
      return nil
    }
    
    return self.orderedViewControllers[previousIndex]
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    
    guard let viewControllerIndex = self.orderedViewControllers.index(of: viewController) else {
      return nil
    }
    
    let nextIndex = viewControllerIndex + 1
    let orderedViewControllersCount = self.orderedViewControllers.count
    
    guard orderedViewControllersCount != nextIndex else {
      return nil
    }
    
    guard orderedViewControllersCount > nextIndex else {
      return nil
    }
    
    return self.orderedViewControllers[nextIndex]
  }
}

// MARK: - UIPageViewControllerDelegate

extension AddLocationContainerViewController : UIPageViewControllerDelegate {
  
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    self.reloadContent()
  }
}

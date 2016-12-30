//
//  PublishNetServiceSearchViewController.swift
//  iDiscover
//
//  Created by Kelvin Kosbab on 12/29/16.
//  Copyright © 2016 Kozinga. All rights reserved.
//

import Foundation
import UIKit

class PublishNetServiceCell: UITableViewCell {
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var typeLabel: UILabel!
}

class PublishNetServiceSearchViewController: MyTableViewController, UISearchResultsUpdating, UISearchBarDelegate {
  
  // MARK: - Class Accessors
  
  static func newController() -> PublishNetServiceSearchViewController {
    return self.newController(fromStoryboard: "Main", withIdentifier: self.name) as! PublishNetServiceSearchViewController
  }
  
  // MARK: - Properties
  
  var existingServices: [MyServiceType] = []
  var filteredServices: [MyServiceType] = []
  let searchController = UISearchController(searchResultsController: nil)
  var publishDetailBaseController: PublishDetailBaseViewController? = nil
  
  private var isFiltered: Bool {
    if self.searchController.isActive, let text = self.searchController.searchBar.text, !text.isEmpty {
      return true
    }
    return false
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Publish a Service"
    
    // Setup the Search Controller
    self.searchController.searchResultsUpdater = self
    self.searchController.searchBar.delegate = self
    self.definesPresentationContext = true
    self.searchController.dimsBackgroundDuringPresentation = false
    self.tableView.tableHeaderView = self.searchController.searchBar
    
    self.existingServices = MyServiceType.allServiceTypes.sorted { (serviceType1: MyServiceType, serviceType2: MyServiceType) -> Bool in
      return serviceType1.name < serviceType2.name
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if !UIDevice.isPhone {
      self.publishDetailBaseController = PublishDetailBaseViewController.newController()
      self.publishDetailBaseController?.presentControllerIn(self, forMode: .splitDetail)
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    self.publishDetailBaseController?.dismissController()
  }
  
  // MARK: - Actions
  
  @objc private func closeButtonSelected(_ sender: UIBarButtonItem) {
    self.dismissController()
  }
  
  // MARK: - Search Controller
  
  func filterContent(forSearchText searchText: String? = nil) {
    if let text = searchText {
      self.filteredServices = self.existingServices.filter({ (serviceType: MyServiceType) -> Bool in
        let isInName = serviceType.name.containsIgnoreCase(text)
        let isInType = serviceType.fullType.containsIgnoreCase(text)
        var isInDetail = false
        if let detail = serviceType.detail {
          isInDetail = detail.containsIgnoreCase(text)
        }
        return isInName || isInType || isInDetail
      })
    } else {
      self.searchController.searchBar.text = ""
    }
    self.tableView.reloadData()
  }
  
  // MARK: - UISearchResultsUpdating
  
  func updateSearchResults(for searchController: UISearchController) {
    if let text = searchController.searchBar.text, !text.isEmpty {
      self.filterContent(forSearchText: text)
    }
  }
  
  // MARK: - UISearchBarDelegate
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.isEmpty {
      self.filterContent()
    }
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    self.filterContent()
  }
  
  // MARK: - UITableView
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if self.isFiltered {
      return self.filteredServices.count
    }
    return self.existingServices.count
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let service = self.isFiltered ? self.filteredServices[indexPath.row] : self.existingServices[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: PublishNetServiceCell.name, for: indexPath) as! PublishNetServiceCell
    cell.nameLabel.text = service.name
    cell.typeLabel.text = service.fullType
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let service = self.isFiltered ? self.filteredServices[indexPath.row] : self.existingServices[indexPath.row]
    print("\(self.className) : Selected service \(service)")
  }
}
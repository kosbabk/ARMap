//
//  BluetoothViewController.swift
//  KozBon
//
//  Created by Kelvin Kosbab on 1/17/17.
//  Copyright © 2017 Kozinga. All rights reserved.
//

import Foundation
import UIKit

class BluetoothViewController : MyTableViewController {
  
  // MARK: - Class Accessors
  
  static func newViewController() -> BluetoothViewController {
    return self.newViewController(fromStoryboard: .main)
  }
  
  // MARK: - Properties
  
  var loadingActivityIndicator: UIActivityIndicatorView? = nil
  
  var bluetoothManager: MyBluetoothManager {
    return MyBluetoothManager.shared
  }
  
  internal var devices: [MyBluetoothDevice] = [] {
    didSet {
      if self.isViewLoaded {
        self.tableView.reloadData()
      }
    }
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Bluetooth"
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.tableView.reloadData()
    MyBluetoothManager.shared.delegate = self
    MyBluetoothManager.shared.startScan()
    self.updateLoading()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    self.bluetoothManager.stopScan()
  }
  
  // MARK: - Loading
  
  func updateLoading() {
    if MyBluetoothManager.shared.state.isScanning {
      self.loadingActivityIndicator?.startAnimating()
      self.loadingActivityIndicator?.isHidden = false
    } else {
      self.loadingActivityIndicator?.stopAnimating()
      self.loadingActivityIndicator?.isHidden = true
    }
  }
  
  // MARK: - UITableView
  
  let bluetoothDevicesSection: Int = 0
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if section == self.bluetoothDevicesSection && MyBluetoothManager.shared.state != .unsupported {
      let cell = tableView.dequeueReusableCell(withIdentifier: NetServicesTableHeaderCell.name) as! NetServicesTableHeaderCell
      cell.titleLabel.text = "Scanning".uppercased()
      cell.loadingActivityIndicator.startAnimating()
      self.loadingActivityIndicator = cell.loadingActivityIndicator
      cell.loadingActivityIndicator.isHidden = false
      cell.reloadButton.isHidden = true
      cell.reloadButton.isUserInteractionEnabled = false
      return cell.contentView
    }
    return super.tableView(tableView, viewForHeaderInSection: section)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == self.bluetoothDevicesSection {
      if self.bluetoothManager.state == .unsupported {
        return 1
      }
      return MyBluetoothManager.shared.devices.count
    }
    return 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    switch indexPath.section {
    case self.bluetoothDevicesSection:
      
      if self.bluetoothManager.state == .unsupported {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyBasicCenterLabelCell.name, for: indexPath) as! MyBasicCenterLabelCell
        cell.titleLabel.text = "Bluetooth is Unsupported"
        return cell
      }
      
      // Device
      let cell = tableView.dequeueReusableCell(withIdentifier: BluetoothDeviceCell.name, for: indexPath) as! BluetoothDeviceCell
      let device = self.devices[indexPath.row]
      cell.configure(device: device)
      return cell
      
    default:
      return UITableViewCell()
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    if indexPath.section == self.bluetoothDevicesSection && self.bluetoothManager.state != .unsupported {
      _ = self.devices[indexPath.row]
    }
  }
}

// MARK: - MyBluetoothManagerDelegate

extension BluetoothViewController : MyBluetoothManagerDelegate {
  
  func didStartScan(_ manager: MyBluetoothManager) {
    self.updateLoading()
  }
  
  func didUpdateDevices(_ manager: MyBluetoothManager) {
    self.devices = manager.devices.typeSorted
  }
  
  func didStopScan(_ manager: MyBluetoothManager) {
    self.updateLoading()
  }
}

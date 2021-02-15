//
//  LoginViewController.swift
//  autofill
//
//  Created by Роман Митюков on 14.02.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import UIKit
import AuthenticationServices

class ResourcesListController : UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  
  let cellReusableIdentifier = "ResourcesListCell"
  private var resources: [Resource]?
  
  var presenter: ResourcesListPresenterInput?
  
  override func viewDidLoad() {
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.searchBar.delegate = self
    
    if self.presenter == nil {
      self.presenter = ResourcesDI.providePresenter(presenterOutput: self)
    }
    
    self.navigationController?.navigationBar.isHidden = true
    
    presenter?.getResources()
  }
  @IBAction func cancel(_ sender: Any) {
    (self.extensionContext as? ASCredentialProviderExtensionContext)?.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userCanceled.rawValue))
  }
}

extension ResourcesListController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    print(searchText)
    self.presenter?.search(text: searchText)
  }
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    self.searchBar.showsCancelButton = true
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    self.searchBar.showsCancelButton = false
    self.searchBar.text = ""
    self.searchBar.resignFirstResponder()
    self.presenter?.search(text: "")
  }
}

extension ResourcesListController: ResourcesListPresenterOutput {
  func didChangeState(state: ResourcesState) {
    self.hideAwaitingView()
    switch state{
    case .error(let message):
      self.showErrorAlert(message: message)
    case .secret(let user, let secret):
      (self.extensionContext as? ASCredentialProviderExtensionContext)?.completeRequest(withSelectedCredential: ASPasswordCredential(user: user, password: secret), completionHandler: nil)
    case .resources(let resources):
      self.resources = resources
      self.tableView.reloadData()
    case .pending:
      self.showAwaitingView()
    }
  }
}

extension ResourcesListController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.resources?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: self.cellReusableIdentifier) as? ResourcesListCell
    
    if let dataSource = self.resources {
      let resource = dataSource[indexPath.row]
      
      if let resourcesListCell = cell {
        resourcesListCell.resourceName.text = resource.name
        resourcesListCell.userName.text = resource.username
        resourcesListCell.uri.text = resource.uri
      }
    }
    
    return cell!
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let dataSource = self.resources {
      let resource = dataSource[indexPath.row]
      self.presenter?.getSecret(resource: resource)
    }
  }
}

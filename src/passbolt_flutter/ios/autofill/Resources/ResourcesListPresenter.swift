//
//  ResourcesListPresenter.swift
//  autofill
//
//  Created by Роман Митюков on 21.02.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation

protocol ResourcesListPresenterInput {
  func getResources()
  func getSecret(resource:Resource)
  func search(text: String)
}

protocol ResourcesListPresenterOutput {
  func didChangeState(state: ResourcesState)
}

class ResourcesListPresenter: ResourcesListPresenterInput {
  var presenterOutput: ResourcesListPresenterOutput?
  var interactorInput: ResourcesListInteractorInput?
  private var rawResources: [Resource] = []
  
  init(presenterOutput: ResourcesListPresenterOutput) {
    self.presenterOutput = presenterOutput
  }
  
  func getResources() {
    self.presenterOutput?.didChangeState(state: .pending)
    self.interactorInput?.getResources()
  }
  
  func getSecret(resource: Resource) {
    self.presenterOutput?.didChangeState(state: .pending)
    self.interactorInput?.getSecret(resource: resource)
  }
  
  func search(text: String) {
    if text.isEmpty {
      self.presenterOutput?.didChangeState(state: .resources(self.rawResources))
      return
    }
    
    var filteredResources = self.rawResources.sorted(
      by: {(resourceA: Resource, resourceB: Resource) -> Bool in
        return resourceA.name.compare(resourceB.name).rawValue == -1
    })
    filteredResources.removeAll(where: {(resource: Resource) -> Bool in
      let inputLowerCase = text.lowercased()
      return !resource.name.lowercased().contains(inputLowerCase) &&
        !resource.username.lowercased().contains(inputLowerCase) &&
        !resource.uri.lowercased().contains(inputLowerCase) &&
        !resource.description.lowercased().contains(inputLowerCase)
    })
    self.presenterOutput?.didChangeState(state: .resources(filteredResources))
  }
}

extension ResourcesListPresenter: ResourcesListInteractorOutput {
  func didReceive(resources: [Resource]) {
    self.rawResources = resources
    self.presenterOutput?.didChangeState(state: .resources(resources))
  }
  
  func didReceive(username: String, secret: String) {
    self.presenterOutput?.didChangeState(state: .secret(username, secret))
  }
  
  func didFail(with error: String) {
    self.presenterOutput?.didChangeState(state: .error(error))
  }
}

enum ResourcesState {
  case resources([Resource]), error(String), secret(String, String), pending
}

struct Resource {
  let name: String
  let username: String
  let uri: String
  let description: String
  let resourceId: String
}

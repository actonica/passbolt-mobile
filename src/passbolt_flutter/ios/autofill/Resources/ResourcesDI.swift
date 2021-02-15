//
//  ResourcesDI.swift
//  autofill
//
//  Created by Роман Митюков on 21.02.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation

class ResourcesDI {
  static func providePresenter(presenterOutput: ResourcesListPresenterOutput) -> ResourcesListPresenterInput {
    let presenter = ResourcesListPresenter(presenterOutput: presenterOutput)
    let interactor = ResourcesListInteractor(
      interactorOutput: presenter,
      cookiesProvider: ExtensionDI.cookiesProviderInput,
      selectedResourceProvider: ExtensionDI.selectedResourceProvider,
      secretProvider: ExtensionDI.secretProvider,
      passphraseProvider: ExtensionDI.passphraseProvider
    )
    presenter.interactorInput = interactor
    return presenter
  }
}

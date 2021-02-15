//
//  CredentialProviderDI.swift
//  autofill
//
//  Created by Роман Митюков on 20.02.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation

class LoginDI {  
  static func providePresenter(presenterOutput: LoginPresenterOutput) -> LoginPresenterInput {
    let presenter = LoginPresenter(presenterOutput: presenterOutput)
    let interactor = LoginInteractor(interactorOutput: presenter,
                                     cookiesProvider: ExtensionDI.cookiesProviderInput,
                                     selectedResourceProvider: ExtensionDI.selectedResourceProvider,
                                     secretProvider: ExtensionDI.secretProvider,
                                     passphraseProvider: ExtensionDI.passphraseProvider
    )
    presenter.interactorInput = interactor
    
    return presenter
  }
}

//
//  ExtensionDI.swift
//  autofill
//
//  Created by Роман Митюков on 21.02.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation

class ExtensionDI {
  static let cookiesProviderInput = CookiesProvider()
  static let selectedResourceProvider = SelectedResourceProvider()
  static let secretProvider = SecretProvider(cookiesProvider: cookiesProviderInput)
  static let passphraseProvider = PassphraseProvider()
}

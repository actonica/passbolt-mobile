//
//  PassphraseProvider.swift
//  autofill
//
//  Created by Роман Митюков on 21.02.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation

protocol PassphraseProviderInput {
  var passhphrase: String? {get set}
}

class PassphraseProvider: PassphraseProviderInput {
  var passhphrase: String?
}

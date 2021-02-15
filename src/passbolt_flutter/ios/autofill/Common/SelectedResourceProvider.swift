//
//  SelectedCredentialProvider.swift
//  autofill
//
//  Created by Роман Митюков on 20.02.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation

protocol SelectedResourceProviderInput {
  var user: String? {get set}
  var resourceId: String? {get set}
}

class SelectedResourceProvider: SelectedResourceProviderInput {
  var user: String?
  var resourceId: String?
}

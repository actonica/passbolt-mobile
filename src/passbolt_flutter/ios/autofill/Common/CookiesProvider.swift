//
//  CookiesProvider.swift
//  autofill
//
//  Created by Роман Митюков on 20.02.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation

protocol CookiesProviderInput {
  var cakePHP: String? { get set }
}

class CookiesProvider: CookiesProviderInput {
  var cakePHP: String?
}

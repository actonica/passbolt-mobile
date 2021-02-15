//
//  RootViewController.swift
//  autofill
//
//  Created by Роман Митюков on 25.02.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import Foundation
import AuthenticationServices

class RootViewController : ASCredentialProviderViewController {
  /*
   Prepare your UI to list available credentials for the user to choose from. The items in
   'serviceIdentifiers' describe the service the user is logging in to, so your extension can
   prioritize the most relevant credentials in the list.
   */
  override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
    // noop
    print("prepareCredentialList")
  }
  
  /*
   Implement this method if your extension supports showing credentials in the QuickType bar.
   When the user selects a credential from your app, this method will be called with the
   ASPasswordCredentialIdentity your app has previously saved to the ASCredentialIdentityStore.
   Provide the password by completing the extension request with the associated ASPasswordCredential.
   If using the credential would require showing custom UI for authenticating the user, cancel
   the request with error code ASExtensionError.userInteractionRequired.
   */
  override func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity) {
    ExtensionDI.selectedResourceProvider.resourceId = credentialIdentity.recordIdentifier
    ExtensionDI.selectedResourceProvider.user = credentialIdentity.user
    self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code:ASExtensionError.userInteractionRequired.rawValue))
  }
  
  /*
   Implement this method if provideCredentialWithoutUserInteraction(for:) can fail with
   ASExtensionError.userInteractionRequired. In this case, the system may present your extension's
   UI and call this method. Show appropriate UI for authenticating the user then provide the password
   by completing the extension request with the associated ASPasswordCredential.
   */
  override func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity) {
    // noop
    print("prepareInterfaceToProvideCredential")
  }
}

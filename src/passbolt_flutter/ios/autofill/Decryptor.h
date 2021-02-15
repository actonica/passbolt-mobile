//
//  Decryptor.h
//  autofill
//
//  Created by BuildUser on 05.08.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//
#import <Foundation/Foundation.h>
#ifndef Decryptor_h
#define Decryptor_h
@interface Decryptor : NSObject
- (void)setup;

- (NSString*)decrypt:(NSString *)message privateKey: (NSString *)privateKey passphrase: (NSString *)passphrase;
@end

#endif /* Decryptor_h */

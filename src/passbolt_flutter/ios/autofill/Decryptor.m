//
//  Decryptor.m
//  autofill
//
//  Created by BuildUser on 05.08.2020.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import "Decryptor.h"

#import <Foundation/Foundation.h>
#if __has_include(<Openpgp/Openpgp.h>)
#import <Openpgp/Openpgp.h>
#else
@import Openpgp;
#endif

@implementation Decryptor{
  dispatch_queue_t queue;
    OpenpgpFastOpenPGP *instance;
}

- (void)setup
{
  queue = dispatch_queue_create("fast-openpgp", DISPATCH_QUEUE_SERIAL);
    instance = OpenpgpNewFastOpenPGP();
}

- (NSString*)decrypt:(NSString *)message privateKey: (NSString *)privateKey passphrase: (NSString *)passphrase {
    @try {
        NSError *error;
        NSString * output = [self->instance decrypt:message privateKey:privateKey passphrase:passphrase error:&error];

        if(error!=nil){
            return @"error";
        }else{
            return output;
        }
    }
    @catch (NSException * e) {
        return @"error";
    }
}

@end

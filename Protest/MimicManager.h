//
//  MimicManager.h
//  Protest
//
//  Created by jack on 7/18/14.
//  Copyright (c) 2014 John Rogers. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MimicManager : NSObject 

- (id)initAndSendMimicWithConnectionManager:(id)manager andPeer:(id)peer;
- (id)initWithConnectionManager:(id)manager andPeer:(id)peer;
- (void)recievedMimic;

@end

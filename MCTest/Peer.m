//
//
//  Created by John Rogers on 4/12/14.
//  Copyright (c) 2014 John Rogers. All rights reserved.
//

#import "Peer.h"

@implementation Peer

- (void)resetAge {
    _age = CFAbsoluteTimeGetCurrent();
}

- (CFAbsoluteTime)getAgeSinceReset {
    return CFAbsoluteTimeGetCurrent() - _age;
}

- (id)initWithSession:(MCSession*)session {
    self = [super init];
    _session = session;
    _peers = [NSMutableArray array];
    _age = CFAbsoluteTimeGetCurrent();
    return self;
}


@end

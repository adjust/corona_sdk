//
//  TestLibCommandExecutor.mm
//  Plugin
//
//  Created by Srdjan Tubin on August 2018.
//  Copyright (c) 2017-2018 Adjust GmbH. All rights reserved.
//

#import "TestLibCommandExecutor.h"

@interface TestLibCommandExecutor ()

@property (nonatomic, copy) NSString *basePath;
@property (nonatomic, copy) NSString *gdprPath;

@end

@implementation TestLibCommandExecutor

- (id)init {
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    self.basePath = nil;
    self.gdprPath = nil;
    
    return self;
}

- (void)executeCommand:(NSString *)className
            methodName:(NSString *)methodName
            parameters:(NSDictionary *)parameters {
    NSLog(@"executeCommand className: %@, methodName: %@, parameters: %@", className, methodName, parameters);
    
    
}

@end

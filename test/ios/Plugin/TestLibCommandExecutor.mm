//
//  TestLibCommandExecutor.mm
//  Adjust Test Library Plugin
//
//  Created by Srdjan Tubin (@2beens) on August 2018.
//  Copyright (c) 2018-2019 Adjust GmbH. All rights reserved.
//

#import "TestLibCommandExecutor.h"

@interface TestLibCommandExecutor ()

@property (nonatomic) PluginLibrary *pluginLibrary;

@end

@implementation TestLibCommandExecutor

- (id)initWithPluginLibrary:(PluginLibrary *)pluginLibrary {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.pluginLibrary = pluginLibrary;
    return self;
}

- (void)executeCommandRawJson:(NSString *)json {
    self.pluginLibrary->dispachExecuteCommand(json);
}

@end

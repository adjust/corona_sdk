//
//  TestLibCommandExecutor.h
//  Plugin
//
//  Created by Srdjan Tubin on August 2018.
//  Copyright (c) 2017-2018 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATLTestLibrary.h"
#import "PluginLibrary.h"

@interface TestLibCommandExecutor : NSObject<AdjustCommandDelegate>

- (id)initWithPluginLibrary:(PluginLibrary *)pluginLibrary;

@end
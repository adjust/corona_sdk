//
//  TestLibCommandExecutor.h
//  Adjust SDK Test
//
//  Created by Srdjan Tubin on 14th August 2018.
//  Copyright (c) 2018 Adjust GmbH. All rights reserved.
//

#import "PluginLibrary.h"
#import "ATLTestLibrary.h"
#import <Foundation/Foundation.h>

@interface TestLibCommandExecutor : NSObject<AdjustCommandDelegate>

- (id)initWithPluginLibrary:(PluginLibrary *)pluginLibrary;

@end

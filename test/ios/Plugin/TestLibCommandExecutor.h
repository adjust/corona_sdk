//
//  TestLibCommandExecutor.h
//  Adjust Test Library Plugin
//
//  Created by Srdjan Tubin (@2beens) on August 2018.
//  Copyright (c) 2018-2019 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATLTestLibrary.h"
#import "PluginLibrary.h"

@interface TestLibCommandExecutor : NSObject<AdjustCommandDelegate>

- (id)initWithPluginLibrary:(PluginLibrary *)pluginLibrary;

@end

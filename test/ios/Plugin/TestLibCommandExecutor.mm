//
//  TestLibCommandExecutor.mm
//  Adjust Test Library Plugin
//
//  Created by Srdjan Tubin (@2beens) on August 2018.
//  Copyright (c) 2018-2022 Adjust GmbH. All rights reserved.
//

#import "TestLibCommandExecutor.h"

@interface TestLibCommandExecutor ()

@property (nonatomic) PluginLibrary *pluginLibrary;

@end

@implementation TestLibCommandExecutor

- (id)initWithPluginLibrary:(PluginLibrary *)pluginLibrary {
    self = [super init];
    if (self == nil) {
        NSLog(@"plugin library is null");
        return nil;
    }

    self.pluginLibrary = pluginLibrary;
    NSLog(@"Plugi libarary is not NULL");
    return self;
}

- (void)executeCommandRawJson:(NSString *)json {
    NSLog(@"comman raw json is = %@", json);
    self.pluginLibrary->dispachExecuteCommand(json);
}

//- (void)executeCommand:(NSString *)className
//            methodName:(NSString *)methodName
//            parameters:(NSString *)jsonParameters {
//    NSLog(@"executeCommand className: %@, methodName: %@, parameters: %@", className, methodName, jsonParameters);
////    NSMutableDictionary *methodParams = [[NSMutableDictionary alloc] init];
////    [methodParams setObject:className forKey:@"className"];
////    [methodParams setObject:methodName forKey:@"methodName"];
////    [methodParams setObject:jsonParameters forKey:@"jsonParameters"];
//    self.pluginLibrary->dispachExecuteCommand(jsonParameters);
//}

@end

//
//  GLPeripheralService.h
//  GLLibDemo-iMac
//
//  Created by huanggulong on 2019/7/5.
//  Copyright © 2019 历山大亚. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GLPeripheralService;
@protocol GLPeripheralServiceDelegate <NSObject>

@optional
- (void)gl_peripheralService:(GLPeripheralService *)peripheralService didRecieveWriteDate:(NSData *)writeData;

@end

//外设服务
@interface GLPeripheralService : NSObject

@property(nonatomic , assign)id<GLPeripheralServiceDelegate> delegate;

@property(nonatomic , copy)NSString *  peripheralIdentifier;

- (instancetype)initWithServiceId:(NSString *)serviceId characteristicId:(NSString *)characteristicId;

- (void)startService;

- (void)stopService;

- (void)notifySubscribeData:(NSData *)data;

@end

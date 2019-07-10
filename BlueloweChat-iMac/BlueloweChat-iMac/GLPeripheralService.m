//
//  GLPeripheralService.m
//  GLLibDemo-iMac
//
//  Created by huanggulong on 2019/7/5.
//  Copyright © 2019 历山大亚. All rights reserved.
//

#import "GLPeripheralService.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface GLPeripheralService ()<CBPeripheralManagerDelegate>
{
    NSString * _serviceId;
    NSString * _characteristicId;
}

@property(nonatomic , strong)CBPeripheralManager *  peripheralManager;


@property (nonatomic, strong) CBService * service;

@property (nonatomic, strong) CBMutableCharacteristic * characteristic;

@end

@implementation GLPeripheralService

- (instancetype)initWithServiceId:(NSString *)serviceId characteristicId:(NSString *)characteristicId{
    if (self = [super init]) {
        _serviceId = serviceId;
        _characteristicId = characteristicId;
    }
    return self;
}

#pragma mark - CBPeripheralManagerDelegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    if (peripheral.state == CBManagerStatePoweredOn) {
        [self config];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    if (service == self.service) {
        [self startService];
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    NSLog(@"%s",__FUNCTION__);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
    //订阅了数据
    NSLog(@"%s",__FUNCTION__);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{
    //取消了订阅
    NSLog(@"%s",__FUNCTION__);
}

//读characteristics请求
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
    if (request.characteristic.properties & CBCharacteristicPropertyRead) {
        [peripheral respondToRequest:request withResult:(CBATTErrorSuccess)];
    }else{
        [peripheral respondToRequest:request withResult:(CBATTErrorReadNotPermitted)];
    }
}

//写characteristics请求
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests{
    CBATTRequest * request = requests.firstObject;
    if (request.characteristic.properties & CBCharacteristicPropertyWrite) {
        [peripheral respondToRequest:request withResult:(CBATTErrorSuccess)];
//        self.characteristic.value = request.characteristic.value;
        if ([self.delegate respondsToSelector:@selector(gl_peripheralService:didRecieveWriteDate:)]) {
            [self.delegate gl_peripheralService:self didRecieveWriteDate:request.value];
        }
    }else{
        [peripheral respondToRequest:request withResult:(CBATTErrorWriteNotPermitted)];
    }
}

#pragma mark - private
- (void)config{
    //    CBUUID *uuid2 = [CBUUID UUIDWithString:CBUUIDCharacteristicUserDescriptionString];
    //
    //    CBMutableDescriptor * d2 = [[CBMutableDescriptor alloc] initWithType:uuid2 value:@"60"];
    //
    //    CBMutableCharacteristic * characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_1_UUID] properties:(CBCharacteristicPropertyRead) value:nil permissions:(CBAttributePermissionsReadable)];
    //    characteristic.descriptors = @[d2];
    
    _characteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:_characteristicId] properties:CBCharacteristicPropertyNotify|CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];
    CBMutableService * transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:_serviceId] primary:YES];
    _service = transferService;
    transferService.characteristics = @[_characteristic];
    [self.peripheralManager addService:transferService];
}

#pragma mark - public
- (void)startService{
    if (_peripheralManager == nil) {
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }else{
        if ((self.peripheralManager.state == CBManagerStatePoweredOn) && (!self.peripheralManager.isAdvertising)) {
            [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:[CBUUID UUIDWithString:_serviceId],CBAdvertisementDataLocalNameKey:@"MMMM"}];
        }else{
            NSLog(@"startService 存在故障");
        }
    }
}

- (void)stopService{
    [self.peripheralManager stopAdvertising];
}

- (void)notifySubscribeData:(NSData *)data{
    BOOL flag = [self.peripheralManager updateValue:data forCharacteristic:self.characteristic onSubscribedCentrals:nil];
    if (flag) {
        NSLog(@"send success");
    }
}

@end

//
//  ViewController.m
//  BlueloweChat-iOS
//
//  Created by admin on 2019/7/10.
//  Copyright © 2019 历山大亚. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "GULONG_Define.h"
#import "GLPerson.h"
@interface ViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager * centralManager;

@property (nonatomic, strong) CBPeripheral * peripheral;

@property (nonatomic, strong) CBCharacteristic * characteristics;

@property (nonatomic, strong) NSMutableArray * dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"连接" style:(UIBarButtonItemStylePlain) target:self action:@selector(leftClick:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:(UIBarButtonItemStylePlain) target:self action:@selector(rightClick:)];
    
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    NSString * localName = advertisementData[CBAdvertisementDataLocalNameKey];
    if ([localName isEqualToString:@"MMMM"] && _peripheral == nil) {
        self.peripheral = peripheral;
        [central connectPeripheral:peripheral options:nil];
        [self.centralManager stopScan];
    }
//    NSLog(@"%@",peripheral);
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    
    peripheral.delegate = self;
    [peripheral discoverServices:@[[CBUUID UUIDWithString:SERVICE_UUID]]];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    for (CBService * service in peripheral.services) {
        NSLog(@"%@",service);
    }
    CBService * service = peripheral.services.firstObject;
    if (service) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:CHARACTERISTIC_UUID]] forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices{
    //重新连接看看
    [peripheral discoverServices:@[[CBUUID UUIDWithString:SERVICE_UUID]]];
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    self.characteristics = service.characteristics.firstObject;
    [peripheral setNotifyValue:YES forCharacteristic:self.characteristics];
//    [peripheral readValueForCharacteristic:self.characteristics];
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
//    [peripheral readValueForCharacteristic:characteristic];
    NSString * text = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    GLPerson * person = [[GLPerson alloc] init];
    person.name = @"iMac";
    person.content = text;
    [self.dataArray addObject:person];
    [self.tableView reloadData];
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error{
    NSLog(@"%s %@",__FUNCTION__,[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]);
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"cell"];
        cell.textLabel.numberOfLines = 0;
    }
    GLPerson * person = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ say:%@",person.name,person.content];
    return cell;
}

#pragma mark - event
- (IBAction)leftClick:(id)sender{
    if (self.centralManager.state == CBManagerStatePoweredOn) {
//        [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SERVICE_UUID]] options:nil];
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }else{
        UIAlertController * vc = [UIAlertController alertControllerWithTitle:@"提示" message:@"请确保蓝牙可用" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"前往设置" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        }];
        [vc addAction:action];
        [vc addAction:action2];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (IBAction)rightClick:(id)sender{
    UIAlertController * vc = [UIAlertController alertControllerWithTitle:@"" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"发送" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        NSString * text = vc.textFields.firstObject.text;
        [self sendDataText:text];
    }];
    
    [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入文字";
    }];
    
    [vc addAction:action];
    [vc addAction:action2];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - private
- (void)sendDataText:(NSString *)text{
//    if(characteristic.properties & CBCharacteristicPropertyWrite){
    
    GLPerson * person = [[GLPerson alloc] init];
    person.name = @"iPhone";
    person.content = text;
    [self.dataArray addObject:person];
    [self.tableView reloadData];
    NSData * data = [text dataUsingEncoding:NSUTF8StringEncoding];
    [self.peripheral writeValue:data forCharacteristic:self.characteristics type:(CBCharacteristicWriteWithResponse)];
}

- (NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end

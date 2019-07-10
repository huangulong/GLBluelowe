//
//  ViewController.m
//  BlueloweChat-iMac
//
//  Created by admin on 2019/7/10.
//  Copyright © 2019 历山大亚. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "GULONG_Define.h"
#import "GLPerson.h"
#import "GLPeripheralService.h"
@interface ViewController()<NSTableViewDelegate,NSTableViewDataSource,GLPeripheralServiceDelegate>

@property (weak) IBOutlet NSTableView *tableView;

@property (weak) IBOutlet NSTextField *textField;

@property (nonatomic, strong) NSMutableArray * dataArray;


@property (nonatomic, strong) GLPeripheralService * peripheralService;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _peripheralService = [[GLPeripheralService alloc] initWithServiceId:SERVICE_UUID characteristicId:CHARACTERISTIC_UUID];
    _peripheralService.delegate = self;
    [_peripheralService startService];
}

#pragma mark - GLPeripheralServiceDelegate
- (void)gl_peripheralService:(GLPeripheralService *)peripheralService didRecieveWriteDate:(NSData *)writeData{
    GLPerson * person = [[GLPerson alloc] init];
    person.name = @"iPhone";
    person.content = [[NSString alloc] initWithData:writeData encoding:NSUTF8StringEncoding];
    [self.dataArray addObject:person];
    [self.tableView reloadData];
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.dataArray.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSString * identifier = tableColumn.identifier;
    NSTableCellView * view = [tableView makeViewWithIdentifier:identifier owner:self];
    GLPerson * person = [self.dataArray objectAtIndex:row];
    view.textField.stringValue = [NSString stringWithFormat:@"%@ say: %@",person.name,person.content];
    return view;
}

- (IBAction)sendClick:(id)sender {
    NSString * text = self.textField.stringValue;
    [self.peripheralService notifySubscribeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
    GLPerson * person = [[GLPerson alloc] init];
    person.name = @"iMac";
    person.content = text;
    [self.dataArray addObject:person];
    [self.tableView reloadData];
}

- (NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end

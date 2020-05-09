//
//  CaseInfoPickerViewController.m
//  GDRMMobile
//
//  Created by yu hongwu on 12-6-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PricePickerViewController.h"

@interface PricePickerViewController ()
@end

@implementation PricePickerViewController
@synthesize pickerPopover = _pickerPopover;
@synthesize data = _data;
@synthesize delegate = _delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setData:nil];
    [self setPickerPopover:nil];
    [self setDelegate:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text=[_data objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *myCell = [tableView cellForRowAtIndexPath:indexPath];
    [_delegate setPrice:myCell.textLabel.text];
    [_pickerPopover dismissPopoverAnimated:YES];
}

@end

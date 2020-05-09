//
//  CaseInfoPickerViewController.h
//  GDRMMobile
//
//  Created by yu hongwu on 12-6-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Systype.h"

@protocol PriceHandler <NSObject>

@optional
-(void)setPrice:(NSString *)price;
@end



@interface PricePickerViewController : UITableViewController
@property (nonatomic,weak) id<PriceHandler> delegate;
@property (weak,nonatomic) UIPopoverController *pickerPopover;
@property (retain,nonatomic) NSArray *data;
@end

//
//  PartyPickerViewController.h
//  GDXERHMMobile
//
//  Created by yu hongwu on 14-8-26.
//
//

#import <UIKit/UIKit.h>
@protocol PartyPickerDelegate;
@interface PartyPickerViewController : UITableViewController
@property (weak, nonatomic) UIPopoverController *pickerPopover;
@property (weak, nonatomic) id<PartyPickerDelegate> delegate;
- (id)initWithStyle:(UITableViewStyle)style  caseId:(NSString*)caseId;
@end

@protocol PartyPickerDelegate <NSObject>
@optional
- (void)setParty:(NSString *)party;
@end
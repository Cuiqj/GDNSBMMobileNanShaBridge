//
//  AnswererPickerViewController.m
//  GDRMMobile
//
//  Created by yu hongwu on 12-6-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AnswererPickerViewController.h"
#import "InquireAskSentence.h"
#import "CaseProveInfo.h"
#import "CaseDeformation.h"
#import "InquireAnswerSentence.h"
#import "AppConstant.h"
@interface AnswererPickerViewController ()
@property (nonatomic,retain) NSArray *dataArray;
+ (NSString*)generateNoticeAskSentence:(NSString*)caseId citizen:(Citizen*)citizen;
+ (NSString*)generateDeforms:(NSString*)caseId citizen:(Citizen*)citizen;
@end

@implementation AnswererPickerViewController
@synthesize delegate=_delegate;
@synthesize pickerPopover=_pickerPopover;
@synthesize dataArray=_dataArray;

//弹出列表类型，0为被询问人类型，1为被询问人姓名，2为常见问题，3为常见答案
@synthesize pickerType=_pickerType;


-(void)viewWillAppear:(BOOL)animated{
    switch (self.pickerType) {
        case 0:{
            NSString *caseID=[self.delegate getCaseIDDelegate];
            NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
            NSEntityDescription *entity=[NSEntityDescription entityForName:@"Citizen" inManagedObjectContext:context];
            NSPredicate *predicate=[NSPredicate predicateWithFormat:@"proveinfo_id==%@",caseID];
            NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
            [fetchRequest setEntity:entity];
            [fetchRequest setPredicate:predicate];
            NSArray *tempArray=[context executeFetchRequest:fetchRequest error:nil];
            self.dataArray=[tempArray valueForKeyPath:@"@distinctUnionOfObjects.nexus"];
        }
            break;
        case 1:{           
            NSString *caseID=[self.delegate getCaseIDDelegate];
            NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
            NSEntityDescription *entity=[NSEntityDescription entityForName:@"Citizen" inManagedObjectContext:context];
            NSString *nexusString=[self.delegate getNexusDelegate];
            NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
            if (![nexusString isEmpty]) {
                NSPredicate *predicate=[NSPredicate predicateWithFormat:@"(proveinfo_id==%@) && (nexus==%@)",caseID,nexusString];
                [fetchRequest setEntity:entity];
                [fetchRequest setPredicate:predicate];
                self.dataArray=[context executeFetchRequest:fetchRequest error:nil];
            } else {
                self.dataArray=nil;
            }   
        }
            break;
        case 2:{
            //初始化常用问题
            NSString *str = [NSString stringWithFormat: @"%d", ((unsigned int)(~0))>>1];    
            NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
            [InquireAskSentence deleteInsertRecord:str];
            NSEntityDescription *entity=[NSEntityDescription entityForName:@"InquireAskSentence" inManagedObjectContext:context];
            NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
            [fetchRequest setEntity:entity];
            [fetchRequest setPredicate:nil];
            NSSortDescriptor *sortDescriptor=[NSSortDescriptor sortDescriptorWithKey:@"the_index.integerValue" ascending:YES];
            self.dataArray=[context executeFetchRequest:fetchRequest error:nil];
            self.dataArray=[self.dataArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            
            InquireAskSentence *inquireAskSentence = [InquireAskSentence newDataObjectWithEntityName:@"InquireAskSentence"];
               
            if ([inquireAskSentence respondsToSelector:@selector(setThe_index:)]) {
                [inquireAskSentence setValue:str forKey:@"the_index"];
            }
            if ([inquireAskSentence respondsToSelector:@selector(setMyid:)]) {
                [inquireAskSentence setValue:str forKey:@"myid"];
            }
            if ([inquireAskSentence respondsToSelector:@selector(setSentence:)]) {
                [inquireAskSentence setValue:[AnswererPickerViewController generateNoticeAskSentence:[self.delegate getCaseIDDelegate] citizen:[self.delegate getCitizen]] forKey:@"sentence"];
            }
            
            self.dataArray = [self.dataArray arrayByAddingObject:inquireAskSentence];
            
        }
            break;
        case 3:{
            //根据选中的问题，载入常用答案
            NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
            NSString *askID=[self.delegate getAskIDDelegate];
            NSString *str = [NSString stringWithFormat: @"%d", ((unsigned int)(~0))>>1];
            
            NSEntityDescription *askEntity=[NSEntityDescription entityForName:@"InquireAnswerSentence" inManagedObjectContext:context];
            NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
            if ([askID isEmpty]) {
                [fetchRequest setPredicate:nil];
            } else {
                NSPredicate *predicate=[NSPredicate predicateWithFormat:@"ask_id==%@",askID];
                [fetchRequest setPredicate:predicate];
            }
            [fetchRequest setEntity:askEntity];
            self.dataArray=[context executeFetchRequest:fetchRequest error:nil];
            
            if ([self.dataArray count] <= 0 && [str isEqual:askID]) {
                InquireAnswerSentence *inquireAnswerSentence = nil;
                inquireAnswerSentence = [InquireAnswerSentence newDataObjectWithEntityName:@"InquireAnswerSentence"];
                if ([inquireAnswerSentence respondsToSelector:@selector(setAsk_id:)]) {
                    [inquireAnswerSentence setValue:askID forKey:@"ask_id"];
                }
                if ([inquireAnswerSentence respondsToSelector:@selector(setSentence:)]) {
                    [inquireAnswerSentence setValue:@"答：无异议。" forKey:@"sentence"];
                }
                self.dataArray = [self.dataArray arrayByAddingObject:inquireAnswerSentence];
                inquireAnswerSentence = [InquireAnswerSentence newDataObjectWithEntityName:@"InquireAnswerSentence"];
                if ([inquireAnswerSentence respondsToSelector:@selector(setAsk_id:)]) {
                    [inquireAnswerSentence setValue:askID forKey:@"ask_id"];
                }
                if ([inquireAnswerSentence respondsToSelector:@selector(setSentence:)]) {
                    [inquireAnswerSentence setValue:@"答：有异议。" forKey:@"sentence"];
                }
                self.dataArray = [self.dataArray arrayByAddingObject:inquireAnswerSentence];
            }
            
        }
            break;
        default:
            break;
    }

    
}

-(void)viewDidUnload{
    [self setDelegate:nil];
    [self setPickerPopover:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]; 
    }
    // Configure the cell...
    switch (self.pickerType) {
        case 0:
            cell.textLabel.text=[self.dataArray objectAtIndex:indexPath.row];
            break;
        case 1:
            cell.textLabel.text=[[self.dataArray objectAtIndex:indexPath.row] valueForKey:@"party"];
            break;
        case 2:
        case 3:{
            cell.textLabel.lineBreakMode=UILineBreakModeWordWrap;
            cell.textLabel.numberOfLines=0;
            cell.textLabel.font=[UIFont systemFontOfSize:17];
            cell.textLabel.text=[[self.dataArray objectAtIndex:indexPath.row] valueForKey:@"sentence"];
        }
            break;
        default:
            break;
    }    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    switch (self.pickerType) {
        case 0:
            [self.delegate setNexusDelegate:cell.textLabel.text];
            break;
        case 1:
            [self.delegate  setAnswererDelegate:cell.textLabel.text];
            break;
        case 2:
            [self.delegate setAskSentence:cell.textLabel.text withAskID:[[self.dataArray objectAtIndex:indexPath.row] valueForKey:@"myid"]];
            break;
        case 3:
            [self.delegate setAnswerSentence:cell.textLabel.text];
            break;
        default:
            break;
    }
    [self.pickerPopover dismissPopoverAnimated:YES];    
}



+ (NSString*)generateNoticeAskSentence:(NSString*)caseId citizen:(Citizen*)citizen{
    CaseProveInfo *proveInfo = [CaseProveInfo proveInfoForCase:caseId citizenName:citizen.automobile_number];

    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MatchLaw" ofType:@"plist"];
    NSDictionary *matchLaws = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    if (matchLaws) {
        NSString *breakStr = @"";
        NSString *matchStr = @"";
        NSString *payStr = @"";
        
        
        NSMutableArray *breakArray = nil;
        NSMutableArray *matchArray = [[NSMutableArray alloc]init];
        NSMutableArray *payArray = [[NSMutableArray alloc]init];
        for(NSString *case_desc_id in [proveInfo.case_desc_id componentsSeparatedByString:@"#"]){
            NSDictionary *matchInfo = [[matchLaws objectForKey:@"case_desc_match_law"] objectForKey:case_desc_id];
            if (matchInfo) {
                if ([matchInfo objectForKey:@"breakLaw"]) {
                    NSArray *tempArray = (NSArray *)[matchInfo objectForKey:@"breakLaw"] ;
                    if([breakArray count] > 0){
                        for(NSString *temp in tempArray){
                            BOOL flag = FALSE;
                            for(NSString *temp2 in breakArray){
                                if([temp isEqual:temp2]){
                                    flag = TRUE;
                                }
                            }
                            if(!flag){
                                [breakArray addObject:temp];
                            }
                        }
                    }else{
                        breakArray = [[NSMutableArray alloc]initWithArray:tempArray];
                    }
                    
                }
                if ([matchInfo objectForKey:@"matchLaw"]) {
                    NSArray *tempArray = (NSArray *)[matchInfo objectForKey:@"matchLaw"] ;
                    if([matchArray count] > 0){
                        for(NSString *temp in tempArray){
                            BOOL flag = FALSE;
                            for(NSString *temp2 in matchArray){
                                if([temp isEqual:temp2]){
                                    flag = TRUE;
                                }
                            }
                            if(!flag){
                                [matchArray addObject:temp];
                            }
                        }
                    }else{
                        matchArray = [[NSMutableArray alloc]initWithArray:tempArray];
                    }
                }
                if ([matchInfo objectForKey:@"payLaw"]) {
                    NSArray *tempArray = (NSArray *)[matchInfo objectForKey:@"payLaw"] ;
                    if([payArray count] > 0){
                        for(NSString *temp in tempArray){
                            BOOL flag = FALSE;
                            for(NSString *temp2 in payArray){
                                if([temp isEqual:temp2]){
                                    flag = TRUE;
                                }
                            }
                            if(!flag){
                                [payArray addObject:temp];
                            }
                        }
                    }else{
                        payArray = [[NSMutableArray alloc]initWithArray:tempArray];
                    }
                }
            }
        }
        if(breakArray != nil && [breakArray count] > 0){
            if([breakArray count] >= 2 ){
                breakStr = BREAK_TWO_RULES;
            }else{
                breakStr = [breakStr stringByAppendingString:[breakArray componentsJoinedByString:@"、"]];
            }
        }
        if(matchArray != nil && [matchArray count] > 0){
            matchStr = [matchStr stringByAppendingString:[matchArray componentsJoinedByString:@"、"]];
        }
        if(payArray != nil && [payArray count] > 0){
            payStr = [payStr stringByAppendingString:[payArray componentsJoinedByString:@"、"]];
        }
        return [NSString stringWithFormat:@"问：经勘验，本次事故造成路产损坏清单如下：%@，根据%@的规定、并依照%@，你损坏公路路产，应照价赔偿路产损失，你有无异议？",[self generateDeforms:caseId citizen:citizen ], matchStr, payStr];
        
    }
    return nil;
}

+ (NSString*)generateDeforms:(NSString*)caseId citizen:(Citizen*)citizen {
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSEntityDescription *deformEntity=[NSEntityDescription entityForName:@"CaseDeformation" inManagedObjectContext:context];
    NSPredicate *deformPredicate=[NSPredicate predicateWithFormat:@"proveinfo_id ==%@ && (citizen_name==%@ || citizen_name==%@)",caseId,citizen.automobile_number,@"共同"];
    [fetchRequest setEntity:deformEntity];
    [fetchRequest setPredicate:deformPredicate];
    NSArray *deformArray=[context executeFetchRequest:fetchRequest error:nil];
    if (deformArray.count>0) {
        NSString *deformsString=@"";
        for (CaseDeformation *deform in deformArray) {
            NSString *roadSizeString=[deform.rasset_size stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([roadSizeString isEmpty]) {
                roadSizeString=@"";
            } else {
                roadSizeString=[NSString stringWithFormat:@"（%@）",roadSizeString];
            }
            NSString *remarkString=[deform.remark stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([remarkString isEmpty]) {
                remarkString=@"";
            } else {
                remarkString=[NSString stringWithFormat:@"（%@）",remarkString];
            }
            NSString *quantity=[[NSString alloc] initWithFormat:@"%.2f",deform.quantity.floatValue];
//            NSCharacterSet *zeroSet=[NSCharacterSet characterSetWithCharactersInString:@".0"];
//            quantity=[quantity stringByTrimmingTrailingCharactersInSet:zeroSet];
            quantity = [quantity stringDeleteZeroByfloatstring:quantity];
            deformsString=[deformsString stringByAppendingFormat:@"%@%@%@%@%@、",deform.roadasset_name,roadSizeString,quantity,deform.unit,remarkString];
        }
        NSCharacterSet *charSet=[NSCharacterSet characterSetWithCharactersInString:@"、"];
        return [deformsString stringByTrimmingCharactersInSet:charSet];
    }
    return @"";
}
@end

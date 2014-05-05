//
//  WeedDetailControlTableViewCell.h
//  WeedaForiPhone
//
//  Created by Chaoqing LV on 4/27/14.
//  Copyright (c) 2014 Weeda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeedDetailControlTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *waterCount;
@property (weak, nonatomic) IBOutlet UIButton *seedCount;
@property (nonatomic, weak) IBOutlet UIButton *seed;
@property (nonatomic, weak) IBOutlet UIButton *waterDrop;
@property (nonatomic, weak) IBOutlet UIButton *light;
@property (nonatomic, weak) IBOutlet UIButton *lightCount;
@property (nonatomic, weak) IBOutlet UITableView *lights;

@end

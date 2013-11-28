//
//  LineLabel.h
//  hurrysubway
//
//  Created by Wang Yuqiu on 13-7-7.
//  Copyright (c) 2013年 Wang Yuqiu. All rights reserved.
//

#import <UIKit/UIKit.h>

//放在 pickview 上的label
@interface LineLabel : UILabel {
}

- (void)setLineNo:(int)lineNo withFlag:(BOOL)isLongName;

@end


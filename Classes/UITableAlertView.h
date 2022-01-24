/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <UIKit/UIAlertView.h>
#import <UIKit/UITableView.h>

@protocol UITableAlertViewDelegate

- (void) didCancel;
- (void) didSelectItem: (id) key;

@end

@interface UITableAlertView : UIAlertView <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
@private
  UITableView* m_Table;
  NSMutableArray* m_Rows;
  NSMutableArray* m_Keys;
  id <UITableAlertViewDelegate> m_Delegate;
  BOOL m_WasCancelled;
}

- (void) clearItems;
- (void) addItem: (NSString*) text: (id) key;
- (void) refresh;

@property (nonatomic, retain) UITableView* table;
@property (nonatomic, retain) NSMutableArray* rows;
@property (nonatomic, retain) NSMutableArray* keys;
@property (nonatomic, assign) id <UITableAlertViewDelegate> delegate;

@end
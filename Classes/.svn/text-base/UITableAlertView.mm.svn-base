/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import "UITableAlertView.h"
#import "Constants.h"

@implementation UITableAlertView

@synthesize table = m_Table, rows = m_Rows, keys = m_Keys, delegate = m_Delegate;

- (id) init
{
  [super init];
    
  m_WasCancelled = YES;
  
  self.title = @STR_SELECT_GAME;
  self.message = @"\n\n\n\n\n\n";
  [super setDelegate: self];
    
  self.table = [[UITableView alloc] initWithFrame: CGRectMake(12, 50, 260, 125) style: UITableViewStylePlain];
  [self.table setDataSource: self];
  [self addSubview: self.table];
  [self.table setDelegate: self];
  
  [self addButtonWithTitle: @STR_CANCEL];
  
  self.rows = [NSMutableArray arrayWithCapacity: 5];
  self.keys = [NSMutableArray arrayWithCapacity: 5];
  
  return self;
}

- (void) dealloc
{
  [self.table release];
  
  [super dealloc];
}

- (void) clearItems
{
  [self.rows removeAllObjects];
  [self.keys removeAllObjects];
}

- (void) addItem: (NSString*) text: (id) key
{
  [self.rows addObject: text];
  [self.keys addObject: key];
}

- (void) refresh
{
  [self.table reloadData];
}

#pragma mark UIAlertViewDelegate Methods

- (void) alertView: (UIAlertView*) alertView didDismissWithButtonIndex: (NSInteger) buttonIndex
{
  if (m_WasCancelled)
    [self.delegate didCancel];
}

#pragma mark UITableViewDataSource Methods

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
  UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"id"];
  if (cell == nil) 
  {
    cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: @"id"];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
  }
  cell.textLabel.text = [self.rows objectAtIndex: indexPath.row];
  
  return cell;
}

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
  return [self.rows count];
}

#pragma mark UITableViewDelegate Methods

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
  m_WasCancelled = NO;
  [self dismissWithClickedButtonIndex: 0 animated: YES];
  [self.delegate didSelectItem: [self.keys objectAtIndex: indexPath.row]];
}

@end
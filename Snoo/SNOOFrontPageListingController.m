//
//  SNOOFrontPageListingController.m
//  Snoo
//
//  Created by Mike Manzano on 6/5/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

#import "SNOOFrontPageListingController.h"
#import "SNOORedditCommandFetchFrontPage.h"
#import "SNOOPagedAccess.h"
#import "SNOOPostTableViewCell.h"
#import "SNOOPost.h"
#import "SNOOPagedAccess.h"

#define SNOO_UI_CONTEXT_FRONT_PAGE_PAGER_DEFAULTS_KEY @"SNOO_UI_CONTEXT_FRONT_PAGE_PAGER_DEFAULTS_KEY"

@interface SNOOFrontPageListingController ()
@property( nonatomic, strong ) SNOORedditCommandFetchFrontPage *fetchCommand ;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fetchNextPageButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshFromTopButton;
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController ;
@end

@implementation SNOOFrontPageListingController
	{
	NSFetchedResultsController *_fetchedResultsController ;
	}

#pragma mark - View lifecycle

- (void) viewDidLoad
	{
	[super viewDidLoad] ;
	
	// Register cell classes
	[self.tableView registerNib:[UINib nibWithNibName:@"SNOOPostTableViewCell" bundle:nil] forCellReuseIdentifier:SNOO_POST_TABLEVIEW_CELL_ID] ;
	
	__weak SNOOFrontPageListingController *weakSelf = self ;
	
	// Create a fetch command
	self.fetchCommand = [SNOORedditCommandFetchFrontPage new] ;
	self.fetchCommand.finishedBlock = ^(NSError *error)
		{
		__strong SNOOFrontPageListingController *strongSelf = weakSelf ;

		strongSelf.fetchNextPageButton.enabled = strongSelf.fetchCommand.pager.hasNextPage ;
		strongSelf.refreshFromTopButton.enabled = YES ;

		if( error )
			NSLog(@"%@", error.localizedDescription) ;
		else
			NSLog(@"Command successful!") ;
		
		// Save paging
		NSData *encodedPaging = [NSKeyedArchiver archivedDataWithRootObject:strongSelf.fetchCommand.pager] ;
		[[NSUserDefaults standardUserDefaults] setObject:encodedPaging forKey:SNOO_UI_CONTEXT_FRONT_PAGE_PAGER_DEFAULTS_KEY] ;
		[[NSUserDefaults standardUserDefaults] synchronize] ;
		} ;
	
	// Restore paging
	NSData *encodedPaging = [[NSUserDefaults standardUserDefaults] dataForKey:SNOO_UI_CONTEXT_FRONT_PAGE_PAGER_DEFAULTS_KEY] ;
	id <SNOOPagedAccess> pager = [NSKeyedUnarchiver unarchiveObjectWithData:encodedPaging] ;
	self.fetchCommand.pager = pager ;
	self.fetchNextPageButton.enabled = self.fetchCommand.pager.hasNextPage ;
	}

#pragma mark - Display

- (void) configureCell: (SNOOPostTableViewCell *) cell atIndexPath: (NSIndexPath *) indexPath
	{
    SNOOPost *post = [self.fetchedResultsController objectAtIndexPath:indexPath] ;
	cell.textLabel.text = post.title ;
	cell.detailTextLabel.text = post.service_order.stringValue ;
	}

#pragma mark - UITableView datasource and delegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
	{
	return self.fetchedResultsController.sections.count ;
	}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
	{
    if( self.fetchedResultsController.sections.count > 0 )
		{
        id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section] ;
        return [sectionInfo numberOfObjects];
		}
	else
        return 0;
	}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
	{
	SNOOPostTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:SNOO_POST_TABLEVIEW_CELL_ID] ;
	[self configureCell:cell atIndexPath:indexPath] ;
	return cell ;
	}

#pragma mark - NSFetchedResultsController

@dynamic fetchedResultsController ;
- (NSFetchedResultsController *) fetchedResultsController
	{
	if( _fetchedResultsController )
		return _fetchedResultsController ;
	
	NSManagedObjectContext *context = [UIApplication snooAppDelegate].managedObjectContext ;
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:SNOO_POST_ENTITY_NAME] ;
	
	// Only fetch items from this context
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"ui_context == %@" , SNOO_UI_CONTEXT_FRONT_PAGE] ;
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"service_order" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	_fetchedResultsController = [[NSFetchedResultsController alloc]
								 initWithFetchRequest:fetchRequest
								 managedObjectContext:context
								 sectionNameKeyPath:nil
								 cacheName:SNOO_UI_CONTEXT_FRONT_PAGE] ;
	
	_fetchedResultsController.delegate = self ;
	
	NSError *error = nil ;
	[_fetchedResultsController performFetch:&error];
	
	return _fetchedResultsController ;
	}

#pragma mark - Actions

- (IBAction)refreshTapped:(UIBarButtonItem *)sender
	{
	self.fetchNextPageButton.enabled = NO ;
	self.refreshFromTopButton.enabled = NO ;
	[self.fetchCommand performFromFirstPage] ;
	}

- (IBAction)nextPageTapped:(UIBarButtonItem *)sender
	{
	self.fetchNextPageButton.enabled = NO ;
	self.refreshFromTopButton.enabled = NO ;
	[self.fetchCommand perform] ;
	}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
	{
    [self.tableView beginUpdates];
	}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
	{
	
    switch(type)
		{
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
						  withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
						  withRowAnimation:UITableViewRowAnimationFade];
            break;
		}
	}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
	{
	
    UITableView *tableView = self.tableView;
	
    switch(type)
		{
			
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(SNOOPostTableViewCell *)[tableView cellForRowAtIndexPath:indexPath]
					atIndexPath:indexPath];
            break;
			
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
            break;
		}
	}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
	{
    [self.tableView endUpdates];
	}


@end

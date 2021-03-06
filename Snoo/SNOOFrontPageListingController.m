//
//  SNOOFrontPageListingController.m
//  Snoo
//
//  Created by Mike Manzano on 6/5/14.
//  Copyright (c) 2014 ivm. All rights reserved.
//

@import QuartzCore ;

#import "SNOOFrontPageListingController.h"
#import "SNOORedditCommandFetchFrontPage.h"
#import "SNOOPagedAccess.h"
#import "SNOOPostTableViewCell.h"
#import "_SNOOPost.h"
#import "SNOOPagedAccess.h"
#import "NSDate(FriendlyDate).h"
#import "SNOOSelfTextController.h"
#import "SNOOWebBrowserController.h"
#import "AsyncImageFetcher.h"
#import "UIImageView+ImageFitting.h"

#define SNOO_UI_CONTEXT_FRONT_PAGE_PAGER_DEFAULTS_KEY @"SNOO_UI_CONTEXT_FRONT_PAGE_PAGER_DEFAULTS_KEY"

@interface SNOOFrontPageListingController ()
@property( nonatomic, strong ) SNOORedditCommandFetchFrontPage *fetchCommand ;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fetchNextPageButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshFromTopButton;
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController ;
@property (nonatomic, strong) UIButton *loadMoreButton ;
@property (nonatomic, strong) UIView *loadMoreFooterView ;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator ;

@property( nonatomic, assign ) BOOL reloadEnabled ;
@property( nonatomic, assign ) BOOL loadMoreEnabled ;
@end

@implementation SNOOFrontPageListingController
	{
	NSFetchedResultsController *_fetchedResultsController ;
	BOOL _ignoreScroll ;
	CGFloat _lastRecordedContentOffsetYPosition ;
	CGFloat _headerHeight ; // Records the height of the header
	
	// Spacing views
	UIView *_topSpacer ;
	
	// A queue to process thumbnails
	dispatch_queue_t _thumbnailQueue ;
	}

#pragma mark - Properties

- (void) setReloadEnabled:(BOOL)reloadEnabled
	{
	_reloadEnabled = reloadEnabled ;
	
	self.refreshFromTopButton.enabled = reloadEnabled ;
	}

- (void) setLoadMoreEnabled:(BOOL)loadMoreEnabled
	{
	_loadMoreEnabled = loadMoreEnabled ;
	
	[self enableLoadMoreIndicator:loadMoreEnabled] ;
	}

#pragma mark - View lifecycle

- (void) viewDidLoad
	{
	[super viewDidLoad] ;
	
	// Thumbnail queue
	_thumbnailQueue = dispatch_queue_create("com.ivm.snoo.frontpage.thumbnailRenderingQueue", DISPATCH_QUEUE_CONCURRENT) ;
	
	// Tableview
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone ;

	// Match colors
	self.navigationItem.rightBarButtonItem.tintColor = [SNOOPostTableViewCell exemplar].backgroundColor ;
	
	// Load more button
#define LOAD_MORE_PADDING (10)
	self.loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom] ;
	self.loadMoreButton.titleLabel.textAlignment = NSTextAlignmentCenter ;
	[self.loadMoreButton setTitle:@"No more items" forState:UIControlStateNormal] ;
	[self.loadMoreButton setTitleColor:[SNOOPostTableViewCell exemplar].backgroundColor forState:UIControlStateNormal] ;
	[self.loadMoreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted] ;
	[self.loadMoreButton sizeToFit] ;
	self.loadMoreFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.loadMoreButton.frame.size.height + LOAD_MORE_PADDING * 2.0)] ;
//	self.loadMoreButton.frame = CGRectMake((self.loadMoreFooterView.bounds.size.width - self.loadMoreButton.frame.size.width)/2.0, LOAD_MORE_PADDING, self.loadMoreButton.frame.size.width, self.loadMoreButton.frame.size.height) ;
	[self.loadMoreFooterView addSubview:self.loadMoreButton] ;
	[self.loadMoreButton addTarget:self action:@selector(nextPageTapped:) forControlEvents:UIControlEventTouchUpInside] ;
	self.tableView.tableFooterView = self.loadMoreFooterView ;
	self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] ;
	self.activityIndicator.hidesWhenStopped = YES ;
	self.activityIndicator.color = [SNOOPostTableViewCell exemplar].backgroundColor ;
//	self.activityIndicator.frame = CGRectMake((self.loadMoreFooterView.bounds.size.width - self.activityIndicator.frame.size.width)/2.0, (self.loadMoreFooterView.bounds.size.height - self.activityIndicator.frame.size.height)/2.0, self.activityIndicator.frame.size.width, self.activityIndicator.frame.size.height) ;
	[self.loadMoreFooterView addSubview:self.activityIndicator] ;
	
	self.loadMoreButton.translatesAutoresizingMaskIntoConstraints = NO ;
	self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO ;
	
	[self.loadMoreFooterView addConstraints:@[
		[NSLayoutConstraint constraintWithItem:self.loadMoreButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.loadMoreFooterView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0] ,
		[NSLayoutConstraint constraintWithItem:self.loadMoreButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.loadMoreFooterView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0] ,
		[NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.loadMoreFooterView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0] ,
		[NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.loadMoreFooterView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]
		]] ;
	
	// Top spacer for table view
	_topSpacer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 20)] ;
	_topSpacer.backgroundColor = [SNOOPostTableViewCell exemplar].backgroundColor ;
	self.tableView.tableHeaderView = _topSpacer ;
	
	// Register cell classes
	[self.tableView registerNib:[UINib nibWithNibName:@"SNOOPostTableViewCell" bundle:nil] forCellReuseIdentifier:SNOO_POST_TABLEVIEW_CELL_ID] ;
	
	self.reloadEnabled = YES ;
	
	// Create a fetch command
	__weak SNOOFrontPageListingController *weakSelf = self ;
	self.fetchCommand = [SNOORedditCommandFetchFrontPage new] ;
	self.fetchCommand.finishedBlock = ^(NSError *error)
		{
		__strong SNOOFrontPageListingController *strongSelf = weakSelf ;

		strongSelf.loadMoreEnabled = strongSelf.fetchCommand.pager.hasNextPage ;
		strongSelf.reloadEnabled = YES ;

		if( error )
			{
			NSLog(@"%@", error.localizedDescription) ;
			[[[UIAlertView alloc] initWithTitle:@"Couldn't load items" message:@"Please try again in a bit" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show] ;
			}
		else
			NSLog(@"Command successful!") ;
		
		// Save paging
		NSData *encodedPaging = [NSKeyedArchiver archivedDataWithRootObject:strongSelf.fetchCommand.pager] ;
		[[NSUserDefaults standardUserDefaults] setObject:encodedPaging forKey:SNOO_UI_CONTEXT_FRONT_PAGE_PAGER_DEFAULTS_KEY] ;
		[[NSUserDefaults standardUserDefaults] synchronize] ;
		
		[strongSelf indicateLoading:NO] ;
		} ;

	// Restore paging
	NSData *encodedPaging = [[NSUserDefaults standardUserDefaults] dataForKey:SNOO_UI_CONTEXT_FRONT_PAGE_PAGER_DEFAULTS_KEY] ;
	id <SNOOPagedAccess> pager = [NSKeyedUnarchiver unarchiveObjectWithData:encodedPaging] ;
	self.fetchCommand.pager = pager ;
	self.loadMoreEnabled = self.fetchCommand.pager.hasNextPage ;
	
	// If there aren't any objects, load some
	if( self.fetchedResultsController.fetchedObjects.count == 0 )
		[self.fetchCommand perform] ;
	
	// Auto inset adjustment is off in the nib, so we calculate it manually here
	CGFloat statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height ;
	CGFloat navigationHeight = self.navigationController.navigationBar.frame.size.height ;
	_headerHeight = statusHeight + navigationHeight ;
	self.tableView.contentInset = UIEdgeInsetsMake(_headerHeight, 0, 0, 0) ;
	self.tableView.contentOffset = CGPointMake(0, -_headerHeight) ;
	}

#pragma mark - UIView events

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
	{
	[self.tableView beginUpdates] ;
	[self.tableView endUpdates] ;
	}


#pragma mark - UIViewController

- (BOOL)prefersStatusBarHidden
	{
	return ![UIApplication snooAppDelegate].shouldShowStatusBar ;
	}

#pragma mark - Display

- (void) configureCell: (SNOOPostTableViewCell *) cell atIndexPath: (NSIndexPath *) indexPath
	{
    _SNOOPost *post = [self.fetchedResultsController objectAtIndexPath:indexPath] ;

	// Easy stuff
	cell.postLabel.text = post.title ;
	cell.dateLabel.text = [post.created_date friendlyDateWithEndDate:nil] ;
	cell.commentsLabel.text = [NSString stringWithFormat:@"%@" , post.num_comments] ;
	
	// Post type
	cell.postTypeIndicator.text = nil ;
	if( post.is_self.boolValue && post.selftext.length > 0 )
		cell.postTypeIndicator.text = @"(read more)" ;
	else if( post.url.length > 0 )
		cell.postTypeIndicator.text = @"(link)" ;
	
	// Score
	UIFontDescriptor *labelFontDescriptor = cell.scoreLabel.font.fontDescriptor ;
	UIFont *boldFont = [UIFont fontWithDescriptor:[labelFontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:0] ;
	NSAttributedString *scoreAttrString = [[NSAttributedString alloc] initWithString:post.score.stringValue attributes:@{NSFontAttributeName:boldFont}] ;
	cell.scoreLabel.attributedText = scoreAttrString ;
	
	// Background image
	cell.backgroundImageView.image = nil ;
	NSURL *thumbnailURL = [NSURL URLWithString:post.thumbnail] ;
	if( thumbnailURL )
		{
		[[AsyncImageFetcher sharedImageFetcher] fetchImageAtURL:thumbnailURL cache:YES andPerform:^(UIImage *image, BOOL usingCached)
			{
			if( image )
				{
				SNOOPostTableViewCell *cellOnWhichToSetImage = cell ;
				if( !usingCached) // if not using cached then this cell may no longer be the target cell, so we ask the tableview for the new cell at indexPath. If we are using cached, we don't ask the tableview for it since it hasn't had a chance to show up on the screen yet so -cellForRowAtIndexPath: will return nil.
					{
					// This shouldn't be dangerous to do because if usingCached is YES, the cell we are asking for here should already have been created and put on the screen
					cellOnWhichToSetImage = (SNOOPostTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath] ;
					}
				if( cellOnWhichToSetImage )
					{
					cellOnWhichToSetImage.backgroundImageView.image = image ;
					[cellOnWhichToSetImage.backgroundImageView invalidateIntrinsicContentSize] ;
					}
				} // if image
			}] ;
		} // if thumbnailURL
	
//	cell.postLabel.layer.borderColor = [UIColor yellowColor].CGColor ;
//	cell.postLabel.layer.borderWidth = 1 ;
	}

- (void) enableLoadMoreIndicator: (BOOL) show // Shouldn't normally call this manually, instead set self.loadMoreEnabled
	{
	self.fetchNextPageButton.enabled = show ;
	self.loadMoreButton.enabled = show ;
	[self.loadMoreButton setTitle:show?@"Load more…":@"No more items" forState:UIControlStateNormal] ;
	}

- (void) indicateLoading: (BOOL) isLoading
	{
	if( isLoading )
		{
		self.loadMoreButton.hidden = YES ;
		[self.activityIndicator startAnimating] ;
		}
	else
		{
		// Do this after a beat so it doesn't flash immediately back
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
			{
			self.loadMoreButton.hidden = NO ;
			}) ;
		[self.activityIndicator stopAnimating] ;
		}
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

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
	{
	_SNOOPost *post = [self.fetchedResultsController objectAtIndexPath:indexPath] ;


	CGFloat height = [SNOOPostTableViewCell heightWithPostText:post.title hasImage:post.thumbnail.length > 0 tableWidth:self.tableView.bounds.size.width] ;
	
	return height ;
	}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
	{
	// Support auto load more
	if( indexPath.row == self.fetchedResultsController.fetchedObjects.count-1 && self.fetchCommand.pager.hasNextPage )
		[self nextPageTapped:self.navigationItem.rightBarButtonItem] ; // lies
	}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
	{
	_SNOOPost *post = [self.fetchedResultsController objectAtIndexPath:indexPath] ;
	
	if( post.is_self.boolValue && post.selftext.length > 0)
		{
		SNOOSelfTextController *stc = [self.storyboard instantiateViewControllerWithIdentifier:SNOO_SELF_TEXT_CONTROLLER_ID] ;
		stc.initialText = post.selftext ;
		[self.navigationController pushViewController:stc animated:YES] ;
		}
	else if( post.url.length > 0 )
		{
		UIStoryboard *webStoryboard = [UIStoryboard storyboardWithName:@"Web" bundle:nil] ;
		SNOOWebBrowserController *webController = [webStoryboard instantiateInitialViewController] ;
		NSURL *url = [NSURL URLWithString:post.url] ;
		if( !url )
			{
			[[[UIAlertView alloc] initWithTitle:@"Could not load web page" message:@"The URL is invalid" delegate:nil cancelButtonTitle:@"Darn" otherButtonTitles:nil] show] ;
			[self.tableView deselectRowAtIndexPath:indexPath animated:YES] ;
			}
		else
			{
			UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:webController] ;
			[self presentViewController:navC animated:YES completion:^
				{
				[webController.webView loadRequest:[NSURLRequest requestWithURL:url]] ;
				}] ;
			}
		}
	else
		{
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES] ;
		}
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
	self.reloadEnabled = NO ;
	self.loadMoreEnabled = NO ;
	[self indicateLoading:YES] ;
	[self.fetchCommand performFromFirstPage] ;
	[self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top) animated:YES] ;
	}

- (IBAction)nextPageTapped:(UIBarButtonItem *)sender
	{
	self.reloadEnabled = NO ;
	self.loadMoreEnabled = NO ;
	
	[self indicateLoading:YES] ;
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

#pragma mark - UIScrollViewDelegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
	{
	if( _ignoreScroll )
		return ;

	if( scrollView.contentOffset.y <= 0 && ![UIApplication snooAppDelegate].shouldShowStatusBar )
		{
		NSLog(@"case1") ;
		[UIApplication snooAppDelegate].shouldShowStatusBar = YES ;
		[UIView animateWithDuration:0.25 animations:^
			{
			[self setNeedsStatusBarAppearanceUpdate] ;
			[self.navigationController setNavigationBarHidden:NO animated:YES] ;
			}
		completion:^(BOOL finished)
			{
			}] ;
		}
	else if( scrollView.contentOffset.y - _lastRecordedContentOffsetYPosition > 1 && [UIApplication snooAppDelegate].shouldShowStatusBar && scrollView.contentOffset.y > _headerHeight)
		{
		NSLog(@"case2") ;
		
		[UIApplication snooAppDelegate].shouldShowStatusBar = NO ;
		[UIView animateWithDuration:0.25 animations:^
			{
			[self setNeedsStatusBarAppearanceUpdate] ;
			[self.navigationController setNavigationBarHidden:YES animated:YES] ;
			}
		completion:^(BOOL finished)
			{
			}] ;
		}
	else if( scrollView.contentOffset.y - _lastRecordedContentOffsetYPosition < -1 && scrollView.contentOffset.y - _lastRecordedContentOffsetYPosition > -10 && ![UIApplication snooAppDelegate].shouldShowStatusBar )
		{
		NSLog(@"case3") ;
		[UIApplication snooAppDelegate].shouldShowStatusBar = YES ;
		[UIView animateWithDuration:0.25 animations:^
			{
			[self setNeedsStatusBarAppearanceUpdate] ;
			[self.navigationController setNavigationBarHidden:NO animated:YES] ;
			}
		completion:^(BOOL finished)
			{
			}] ;
		}

	_lastRecordedContentOffsetYPosition = scrollView.contentOffset.y ;
	}

@end


//
//  OHMOhmletViewController.m
//  ohmage_ios
//
//  Created by Charles Forkish on 4/2/14.
//  Copyright (c) 2014 VPD. All rights reserved.
//

#import "OHMSurveysViewController.h"
#import "OHMSurveyTableViewCell.h"
#import "OHMClient.h"
#import "OHMOhmlet.h"
#import "OHMSurvey.h"
#import "OHMSurveyDetailViewController.h"
#import "OHMSurveyItemViewController.h"
#import "OHMUserViewController.h"

@interface OHMSurveysViewController () <OHMClientDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) OHMClient *client;
@property (nonatomic, strong) OHMOhmlet *ohmlet;
@property (nonatomic) NSInteger ohmletIndex;

@property (nonatomic, weak) UIPageControl *pageControl;
@property (nonatomic, weak) UILabel *ohmletNameLabel;
@property (nonatomic, weak) UILabel *ohmletDescriptionLabel;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation OHMSurveysViewController

- (instancetype)initWithOhmletIndex:(NSInteger)ohmletIndex
{
    // Call the superclass's designated initializer
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.ohmletIndex = ohmletIndex;
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:nil
                                                                      action:nil];
    self.navigationItem.backBarButtonItem = backButtonItem;
    
    self.navigationItem.title = @"Ohmage";
    
//    self.tableView.separatorInset = UIEdgeInsetsZero;
//    self.tableView.separatorColor = [UIColor blackColor];
    
    UIBarButtonItem *ohmButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ohmage_toolbar"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(userButtonPressed:)];
    self.navigationItem.leftBarButtonItem = ohmButton;
    
    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"help_icon"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(helpButtonPressed:)];
    self.navigationItem.rightBarButtonItem = helpButton;
    
    NSSortDescriptor *dueDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"isDue" ascending:NO];
    NSSortDescriptor *indexDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ohmlet == %@ AND isLoaded == YES", self.ohmlet];
    self.fetchedResultsController = [[OHMClient sharedClient] fetchedResultsControllerWithEntityName:[OHMSurvey entityName]
                                                                                            sortDescriptors:@[dueDescriptor, indexDescriptor]
                                                                                           predicate:predicate
                                                                                  sectionNameKeyPath:@"isDue"
                                                                                           cacheName:nil];
    self.fetchedResultsController.delegate = self;
    
    self.client = [OHMClient sharedClient];
    self.client.delegate = self;
    [self updateOhmletAnimated:NO];
    
    [self.tableView registerClass:[OHMSurveyTableViewCell class]
           forCellReuseIdentifier:@"OHMSurveyTableViewCell"];
    
    
    
    [self setupHeader];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                      NSFontAttributeName : [UIFont boldSystemFontOfSize:22]}];
    self.navigationController.navigationBar.barTintColor = [OHMAppConstants ohmageColor];
    [self updateFetchedResultsController];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"did appear nav bounds: %@", NSStringFromCGRect(self.navigationController.navigationBar.bounds));
//    [self updateFetchedResultsController];
}

- (void)userButtonPressed:(id)sender
{
    OHMUserViewController *vc = [[OHMUserViewController alloc] init];
    UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navCon animated:YES completion:nil];
}

- (void)helpButtonPressed:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://ohmage.org/"];
    [[UIApplication sharedApplication] openURL:url];
}


- (void)setupHeader
{
    if (self.client.ohmlets.count < 2) return; // only show header if needed for switching ohmlets
    
    NSString *nameText = nil;
    NSString *descriptionText = nil;
    if (self.ohmlet) {
        nameText = self.ohmlet.ohmletName ? self.ohmlet.ohmletName : self.ohmlet.ohmID;
        descriptionText = self.ohmlet.ohmletDescription ? self.ohmlet.ohmletDescription : @"...";
    }
    else {
        nameText = @"Loading Data";
        descriptionText = @"...";
    }
    
    CGFloat contentWidth = self.tableView.bounds.size.width - 2 * kUIViewHorizontalMargin;
    
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = MAX([self.client.ohmlets count], 1);
    pageControl.currentPage = self.ohmletIndex;
    pageControl.hidesForSinglePage = YES;
    pageControl.pageIndicatorTintColor = [OHMAppConstants lightOhmageColor];
    pageControl.currentPageIndicatorTintColor = [OHMAppConstants ohmageColor];
    [pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [pageControl constrainSize:CGSizeMake(contentWidth, 20)];
    self.pageControl = pageControl;
    
    UILabel *nameLabel = [OHMUserInterface headerTitleLabelWithText:nameText width:contentWidth];
    self.ohmletNameLabel = nameLabel;
    
    UILabel *descriptionLabel = [OHMUserInterface headerDescriptionLabelWithText:descriptionText width:contentWidth];
    self.ohmletDescriptionLabel = descriptionLabel;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, [self headerHeight])];
//    headerView.backgroundColor = [OHMAppConstants lightOhmageColor];
    
    [headerView addSubview:nameLabel];
    [headerView addSubview:descriptionLabel];
    [headerView addSubview:pageControl];
    
    [nameLabel centerHorizontallyInView:headerView];
    [descriptionLabel centerHorizontallyInView:headerView];
    [pageControl centerHorizontallyInView:headerView];
    
    [pageControl constrainToTopInParentWithMargin:kUIViewSmallTextMargin];
    [nameLabel positionBelowElement:pageControl margin:kUIViewSmallTextMargin];
    [descriptionLabel positionBelowElement:nameLabel margin:kUIViewSmallTextMargin];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(headerDidSwipeRight:)];
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(headerDidSwipeLeft:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [headerView addGestureRecognizer:rightSwipe];
    [headerView addGestureRecognizer:leftSwipe];
    
    self.tableView.tableHeaderView = headerView;
}

- (void)updateOhmletAnimated:(BOOL)animated
{
    if (self.client.ohmlets.count > 0) {
        self.ohmletIndex = MAX(self.ohmletIndex, MIN(self.client.ohmlets.count - 1, 0) );
        self.ohmlet = self.client.ohmlets[self.ohmletIndex];
        __weak __typeof(self) weakSelf = self;
        self.ohmlet.ohmletUpdatedBlock = ^{
//            [weakSelf updateHeaderAnimated:YES];
            [weakSelf setupHeader];
        };
    }
    else {
        self.ohmletIndex = 0;
        self.ohmlet = nil;
    }
        
    [self updateFetchedResultsController];
//    [self updateHeaderAnimated:animated];
    [self setupHeader];
    
//    if (animated && self.fetchedResultsController.sections.count > 0) {
//        for (int i = 0; i < self.fetchedResultsController.sections.count; i++ ) {
//            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationFade];
//        }
//    }
//    else
    {
        [self.tableView reloadData];
    }
}

- (void)updateHeaderAnimated:(BOOL)animated
{
    if (self.tableView.tableHeaderView == nil) return;
    
    self.pageControl.numberOfPages = [self.client.ohmlets count];
    self.ohmletNameLabel.text = self.ohmlet.ohmletName;
    self.ohmletDescriptionLabel.text = self.ohmlet.ohmletDescription;
    
//    CGFloat contentWidth = self.tableView.bounds.size.width - 2 * kUIViewHorizontalMargin;
//    CGFloat nameHeight = [OHMUserInterface heightForText:self.ohmletNameLabel.text withWidth:contentWidth font:self.ohmletNameLabel.font];
//    CGFloat descriptionHeight = [OHMUserInterface heightForText:self.ohmletDescriptionLabel.text withWidth:contentWidth font:self.ohmletDescriptionLabel.font];
//    [self.ohmletNameLabel constrainSize:CGSizeMake(contentWidth, nameHeight)];
//    [self.ohmletNameLabel constrainSize:CGSizeMake(contentWidth, descriptionHeight)];
//    
//    CGFloat newHeight = [self headerHeight];
//    
//    if (self.tableView.tableHeaderView.frame.size.height != newHeight) {
//        CGRect newFrame = self.tableView.tableHeaderView.frame;
//        newFrame.size.height = newHeight;
//        
//        if (animated) {
//            [UIView animateWithDuration:0.35 animations:^{
//                self.tableView.tableHeaderView.frame = newFrame;
//            }];
//        }
//        else {
//            self.tableView.tableHeaderView.frame = newFrame;
//        }
//    }
}

- (CGFloat)headerHeight
{
    CGFloat contentHeight = kUIViewVerticalMargin;
    contentHeight += self.pageControl.frame.size.height + kUIViewSmallTextMargin;
    contentHeight += self.ohmletNameLabel.frame.size.height + kUIViewSmallTextMargin;
    contentHeight += self.ohmletDescriptionLabel.frame.size.height + kUIViewSmallTextMargin;
    return contentHeight;
}

- (void)pageControlValueChanged:(id)sender
{
//    NSInteger oldIndex = self.ohmletIndex;
    self.ohmletIndex = self.pageControl.currentPage;
    [self OHMClientDidUpdate:[OHMClient sharedClient]];
//    UITableViewRowAnimation animation = (oldIndex < self.ohmletIndex ? UITableViewRowAnimationLeft : UITableViewRowAnimationRight);
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:animation];
}

- (void)headerDidSwipeRight:(id)sender
{
    if (self.pageControl.currentPage > 0) {
        self.pageControl.currentPage -= 1;
        [self pageControlValueChanged:self.pageControl];
    }
}

- (void)headerDidSwipeLeft:(id)sender
{
    if (self.pageControl.currentPage < self.pageControl.numberOfPages) {
        self.pageControl.currentPage += 1;
        [self pageControlValueChanged:self.pageControl];
    }
}

- (void)updateFetchedResultsController
{
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ohmlet == %@ AND isLoaded == YES", self.ohmlet];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ohmlet == %@", self.ohmlet];
    self.fetchedResultsController.fetchRequest.predicate = predicate;
//    NSLog(@"update fetched results controller, predicate: %@", self.fetchedResultsController.fetchRequest.predicate);
    
    NSError *error;
    BOOL success = [self.fetchedResultsController performFetch:&error];
    if (!success) {
        NSLog(@"Error fetching surveys for ohmlet. Error: %@, Ohmlet: %@", [error localizedDescription], self.ohmlet);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return MAX([[self.fetchedResultsController sections] count], 1);
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        return 1;
    }
    
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        cell = [OHMUserInterface cellWithDefaultStyleFromTableView:tableView];
        cell.textLabel.text = @"No Surveys";
    }
    else {
        cell = [OHMUserInterface cellWithSubtitleStyleFromTableView:tableView];
        [self configureCell:cell atIndexPath:indexPath];
    }
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row >= [[self.fetchedResultsController fetchedObjects] count]) {
        NSLog(@"no survey for row: %ld", (long)indexPath.row);
        return;
    }
    
    OHMSurvey *survey = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    cell.backgroundColor = [OHMAppConstants lightColorForSurveyIndex:survey.indexValue];
    cell.tintColor = [UIColor darkTextColor];
    
    if (survey.isLoaded) {
        cell.textLabel.text = survey.surveyName;
    }
    
    survey.surveyUpdatedBlock = ^{
//        NSLog(@"executing update block for survey: %@, row: %ld", weakSurvey.surveyName, (long)indexPath.row);
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    };
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    OHMSurvey *survey = [self.fetchedResultsController objectAtIndexPath:indexPath];
////    NSLog(@"will display survey: %@, at row: %ld", survey.surveyName, indexPath.row);
//    survey.index = indexPath.row;
//    cell.backgroundColor = [OHMAppConstants lightColorForSurveyIndex:indexPath.row];
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OHMSurvey *survey = [self.fetchedResultsController objectAtIndexPath:indexPath];
    OHMSurveyResponse *newResponse = [[OHMClient sharedClient] buildResponseForSurvey:survey];
    OHMSurveyItemViewController *vc = [[OHMSurveyItemViewController alloc] initWithSurveyResponse:newResponse atQuestionIndex:0];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    OHMSurvey *survey = [self.fetchedResultsController objectAtIndexPath:indexPath];
    OHMSurveyDetailViewController *vc = [[OHMSurveyDetailViewController alloc] initWithSurvey:survey];
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        return tableView.rowHeight;
    }
    
    OHMSurvey *survey = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return [OHMUserInterface heightForSubtitleCellWithTitle:survey.surveyName
                                                   subtitle:nil//survey.surveyDescription
                                              accessoryType:UITableViewCellAccessoryDetailDisclosureButton
                                              fromTableView:tableView];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.fetchedResultsController.sections.count > 1) {
        if (section == 0) {
            return @"Due:";
        }
        else {
            return @"Available:";
        }
    }
    return nil;
}


#pragma mark - Client Delegate

- (void)OHMClientDidUpdate:(OHMClient *)client
{
    [self updateOhmletAnimated:YES];
}


#pragma mark - NSFetchedResultsController Delegate

- (void)controllerWillChangeContent:
(NSFetchedResultsController *)controller
{
//    NSLog(@"controller will change content");
//    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:
(NSFetchedResultsController *)controller
{
//    NSLog(@"controller did change content");
//    [self.tableView endUpdates];
    [self.tableView reloadData];
}

//- (void)controller:(NSFetchedResultsController *)controller
//  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
//           atIndex:(NSUInteger)sectionIndex
//     forChangeType:(NSFetchedResultsChangeType)type
//{
////    NSLog(@"controller did change section info type: %lu", (unsigned long)type);
//    switch(type)
//    {
//        case NSFetchedResultsChangeInsert:
//            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
//                          withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
//                          withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
//    OHMSurvey *survey = (OHMSurvey *)anObject;
//    NSLog(@"controller did change survey: %@, type: %lu, indexRow: %lu, newRow: %lu", survey.surveyName, (unsigned long)type, indexPath.row, newIndexPath.row);
//    UITableView *tableView = self.tableView;
    
    [self.tableView reloadData];
    
//    for (int i = 0; i < self.fetchedResultsController.sections.count; i++ ) {
//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationFade];
//    }
//    [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
//    switch(type)
//    {
//        case NSFetchedResultsChangeInsert:
//            [tableView insertRowsAtIndexPaths:@[newIndexPath]
//                             withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
//                             withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
//                    atIndexPath:indexPath];
//            break;
//            
//        case NSFetchedResultsChangeMove:
//            [tableView
//             deleteRowsAtIndexPaths:@[indexPath]
//             withRowAnimation:UITableViewRowAnimationFade];
//            
//            [tableView
//             insertRowsAtIndexPaths:@[newIndexPath]
//             withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
}

@end

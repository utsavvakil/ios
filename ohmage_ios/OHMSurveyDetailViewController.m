//
//  OHMSurveyDetailViewController.m
//  ohmage_ios
//
//  Created by Charles Forkish on 4/8/14.
//  Copyright (c) 2014 VPD. All rights reserved.
//

#import "OHMSurveyDetailViewController.h"
#import "OHMSurvey.h"

@interface OHMSurveyDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *promptCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *takeSurveyButton;

@property (nonatomic, strong) OHMSurvey *survey;

@end

@implementation OHMSurveyDetailViewController

- (id)initWithSurvey:(OHMSurvey *)survey
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.survey = survey;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.nameLabel.text = self.survey.surveyName;
    self.descriptionLabel.text = self.survey.surveyDescription;
    self.promptCountLabel.text = [NSString stringWithFormat:@"%lu Prompts", (unsigned long)[self.survey.surveyItems count]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takeSurvey:(id)sender {
    
}

@end
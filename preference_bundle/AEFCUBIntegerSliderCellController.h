#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
//#import <Preferences/PSSliderCell.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSliderTableCell.h>

#import <sys/types.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#include <unistd.h>

@interface PSSegmentableSlider : UISlider {
	UIColor *_trackMarkersColor;
	BOOL _segmented;
	BOOL _locksToSegment;
	BOOL _snapsToSegment;
	unsigned long long _segmentCount;
	UISelectionFeedbackGenerator *_feedbackGenerator;
}
@property (nonatomic, retain) UISelectionFeedbackGenerator *feedbackGenerator;             //@synthesize feedbackGenerator=_feedbackGenerator - In the implementation block
@property (assign, getter=isSegmented, nonatomic) BOOL segmented;                          //@synthesize segmented=_segmented - In the implementation block
@property (assign, nonatomic) BOOL locksToSegment;                                         //@synthesize locksToSegment=_locksToSegment - In the implementation block
@property (assign, nonatomic) BOOL snapsToSegment;                                         //@synthesize snapsToSegment=_snapsToSegment - In the implementation block
@property (assign, nonatomic) unsigned long long segmentCount;                             //@synthesize segmentCount=_segmentCount - In the implementation block
- (UISelectionFeedbackGenerator *)feedbackGenerator;
- (void)setFeedbackGenerator:(UISelectionFeedbackGenerator *)arg1;
- (unsigned long long)segmentCount;
- (BOOL)locksToSegment;
- (void)sliderTapped:(id)arg1;
- (BOOL)snapsToSegment;
- (void)setLocksToSegment:(BOOL)arg1;
- (void)setSnapsToSegment:(BOOL)arg1;
- (unsigned long long)numberOfTicks;
- (id)initWithFrame:(CGRect)arg1;
- (void)controlInteractionBegan:(id)arg1;
- (void)setSegmentCount:(unsigned long long)arg1;
- (void)controlInteractionEnded:(id)arg1;
- (float)offsetBetweenTicksForNumberOfTicks:(unsigned long long)arg1;
- (CGRect)thumbRectForBounds:(CGRect)arg1 trackRect:(CGRect)arg2 value:(float)arg3;
- (void)setValue:(float)arg1 animated:(BOOL)arg2;
- (BOOL)isSegmented;
- (void)drawRect:(CGRect)arg1;
- (void)setSegmented:(BOOL)arg1;
@end

@interface UITableViewCellContentView : UIView
@property (nonatomic, retain) NSArray *subviews;
@end

@interface _UISlideriOSVisualElement : UIView
@property (nonatomic, retain) NSArray *subviews;
@end

@interface AEFCUBIntegerSliderCellController : PSSliderTableCell
- (void)controlChanged:(id)arg1;
@end
/*
 * Copyright (c) 09/10/2012 Mario Negro (@emenegro)
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "MNMToast.h"
#import <QuartzCore/QuartzCore.h>

/*
 * Constants
 */
static CGFloat const kFontSize = 14.0f; // Font size of the text.
static CGFloat const kFadeAnimationDuration = 0.3f; // Duration of the animation to show/hide.
static CGFloat const kAutohidingTime = 3.0f; // Time (in seconds) in which the toast will be visible if shown with autohiding.
static CGFloat const kHorizontalMargin = 20.0f; // Left and right margin between the border of the toast's superviewview and the toast view.
static CGFloat const kBottomMargin = 25.0f; // Margin between the bottom of the toast's superview and the toast view.
static CGFloat const kTextInset = 5.0f; // Text inset, that is, the margin between the text its container view.

/*
 * The Toast view itself.
 */
@interface MNMToastView : UIView

/*
 * The value to show.
 */
@property (nonatomic, readwrite, strong) MNMToastValue *value;

/*
 * Text label.
 */
@property (nonatomic, readwrite, strong) UILabel *textLabel;

/*
 * The view in which the toast will be added.
 */
@property (nonatomic, readwrite, strong) UIView *toastSuperview;

@end

@implementation MNMToastView

@synthesize value = value_;
@synthesize textLabel = textLabel_;
@synthesize toastSuperview = toastSuperview_;

/*
 * Initializes and returns a newly allocated view object with the specified frame rectangle.
 */
- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        UIColor *borderColor = [UIColor colorWithRed:0.25f green:0.0f blue:0.0f alpha:0.5f];
        UIColor *backgroundColor = [UIColor colorWithRed:0.5f green:0.0f blue:0.0f alpha:0.5f];
        
        [self setBackgroundColor:backgroundColor];
        [self setAlpha:0.0f];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        [[self layer] setCornerRadius:6];
        [[self layer] setBorderColor:[borderColor CGColor]];
        [[self layer] setBorderWidth:1.0f];

        textLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(kTextInset, kTextInset, CGRectGetWidth(frame) - kTextInset * 2.0f, CGRectGetHeight(frame) - kTextInset * 2.0f)];
        [textLabel_ setFont:[UIFont systemFontOfSize:kFontSize]];
        [textLabel_ setTextAlignment:NSTextAlignmentCenter];
        [textLabel_ setBackgroundColor:[UIColor clearColor]];
        [textLabel_ setTextColor:[UIColor whiteColor]];
        [textLabel_ setShadowColor:borderColor];
        [textLabel_ setShadowOffset:CGSizeMake(1.0f, 1.0f)];
        [textLabel_ setLineBreakMode:NSLineBreakByWordWrapping];
        [textLabel_ setNumberOfLines:0];
        [textLabel_ setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        
        [self addSubview:textLabel_];
    }
    
    return self;
}

/*
 * Layout subviews
 */
- (void)layoutSubviews {
    [super layoutSubviews];
 
    CGFloat width = CGRectGetWidth([toastSuperview_ bounds]) - kHorizontalMargin * 2.0f;
    CGFloat height = [[value_ text] sizeWithFont:[UIFont systemFontOfSize:kFontSize] constrainedToSize:CGSizeMake(width - kTextInset * 2.0f, CGFLOAT_MAX)].height + (kTextInset * 2.0f);
    CGFloat y = CGRectGetHeight([toastSuperview_ bounds]) - height - kBottomMargin;
    
    [textLabel_ setText:[value_ text]];
    [self setFrame:CGRectMake(kHorizontalMargin, y, width, height)];
}

@end

#pragma mark -
#pragma mark -

@implementation MNMToastValue

@synthesize text;
@synthesize autoHide;
@synthesize completionHandler;

/*
 * Returns a Boolean value that indicates whether the receiver and a given object are equal
 */
- (BOOL)isEqual:(id)object {
    
    MNMToastValue *another = (MNMToastValue *)object;    
    return [[self text] isEqualToString:[another text]];
}

@end

#pragma mark -
#pragma mark -

@interface MNMToast()

/*
 * The toast view.
 */
@property (nonatomic, readwrite, strong) MNMToastView *toastView;

/*
 * Queue of toast entities.
 */
@property (nonatomic, readwrite, strong) NSMutableArray *queue;

/*
 * Shows a toast.
 *
 * @param text The text to show.
 * @param autoHide YES to autohide.
 * @param completionHandler The handler to invoke on completion.
 */
- (void)showWithText:(NSString *)text
         autoHidding:(BOOL)autoHide
   completionHandler:(MNMToastCompletionHandler)completionHandler;

/*
 * Hides the current visible toast.
 */
- (void)hide;

/*
 * Show next toast.
 */
- (void)showNextToast;

/*
 * Toast tapped
 */
- (void)toastTapped;

@end

@implementation MNMToast

@synthesize toastView = toastView_;
@synthesize queue = queue_;
@dynamic isToastVisible;

#pragma mark -
#pragma mark Singleton

/*
 * Returns the singleton only instance.
 */
+ (MNMToast *)getInstance {
    
    static dispatch_once_t once;
    static MNMToast *sharedInstance;
    
    dispatch_once(&once, ^{
        
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Initialization

/*
 * Designated initalizer
 */
- (id)init {
    
    if (self = [super init]) {
        
        queue_ = [[NSMutableArray alloc] init];
        toastView_ = [[MNMToastView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 50.0f)];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toastTapped)];
        [tapGestureRecognizer setNumberOfTapsRequired:1];
        [toastView_ addGestureRecognizer:tapGestureRecognizer];
    }
    
    return self;
}

#pragma mark - Class methods

/*
 * Shows a toast.
 */
+ (void)showWithText:(NSString *)text
         autoHidding:(BOOL)autoHide
   completionHandler:(MNMToastCompletionHandler)completionHandler {
    
    [[MNMToast getInstance] showWithText:text
                             autoHidding:autoHide
                       completionHandler:completionHandler];
}

/*
 * Hides the current visible toast.
 */
+ (void)hide {
    
    [[MNMToast getInstance] hide];
}

#pragma mark - Showing

/*
 * Shows a toast.
 */
- (void)showWithText:(NSString *)text
         autoHidding:(BOOL)autoHide
   completionHandler:(MNMToastCompletionHandler)completionHandler {
    
    if ([text length] > 0) {
        
        MNMToastValue *value = [[MNMToastValue alloc] init];
        
        [value setText:text];
        [value setAutoHide:autoHide];
        [value setCompletionHandler:completionHandler];
        
        if (![queue_ containsObject:value]) {
            
            [queue_ addObject:value];
            
            [self showNextToast];
        }
    }
}

/*
 * Show next toast
 */
- (void)showNextToast {
    
    if ([self isToastVisible]) {
        
        [self hide];
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(hide)
                                                   object:nil];
        
    } else if ([queue_ count] > 0) {
        
        MNMToastValue *value = [queue_ objectAtIndex:0];
        UIViewController *controller = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        
        if ([controller isKindOfClass:[UITabBarController class]]) {
            
            controller = [(UITabBarController *)controller selectedViewController];
            
        } else if ([controller isKindOfClass:[UINavigationController class]]) {
            
            controller = [(UINavigationController *)controller visibleViewController];
        }
        
        [toastView_ setToastSuperview:[controller view]];
        [toastView_ setValue:value];
        [[controller view] addSubview:toastView_];
        [toastView_ setNeedsLayout];
        
        [UIView animateWithDuration:kFadeAnimationDuration animations:^{
            
            [toastView_ setAlpha:1.0f];
            
        } completion:^(BOOL finished) {
            
            if ([value autoHide]) {
                
                [self performSelector:@selector(hide)
                           withObject:nil
                           afterDelay:kAutohidingTime];
            }
        }];
    }
}

#pragma mark - Hiding

/*
 * Hides the toast
 */
- (void)hide {
    
    [UIView animateWithDuration:kFadeAnimationDuration animations:^{
        
        [toastView_ setAlpha:0.0f];
        
    } completion:^(BOOL finished) {
        
        if ([queue_ count] > 0) {
            
            [toastView_ removeFromSuperview];
            
            MNMToastValue *value = [queue_ objectAtIndex:0];
            MNMToastCompletionHandler completionHandler = [value completionHandler];
            
            if (completionHandler != nil) {
                
                completionHandler(value, YES, NO);
            }
            
            [queue_ removeObjectAtIndex:0];
        }
        
        [self showNextToast];
    }];
}

#pragma mark - Properties

/*
 * Returns the visibility
 */
- (BOOL)isToastVisible {
    
    return [toastView_ alpha] != 0.0f;
}

#pragma mark - Tap

/*
 * Toast tapped
 */
- (void)toastTapped {
    
    if ([queue_ count] > 0) {
        
        MNMToastValue *value = [queue_ objectAtIndex:0];
        MNMToastCompletionHandler completionHandler = [value completionHandler];
        
        if (completionHandler != nil) {
            
            completionHandler(value, NO, YES);
        }
    }
}

@end

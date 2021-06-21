//
//  Created by Remi Santos on 13/04/16.
//  Copyrights by Facebook, Remi Santos, and Kevin Cooper.
//

#import "RNSnackBarView.h"
#import <React/RCTConvert.h>

typedef NS_ENUM(NSInteger, RNSnackBarViewState) {
    RNSnackBarViewStateDisplayed,
    RNSnackBarViewStatePresenting,
    RNSnackBarViewStateDismissing,
    RNSnackBarViewStateDismissed
};

static NSDictionary *DEFAULT_DURATIONS;
static const NSTimeInterval ANIMATION_DURATION = 0.250;

@interface RNSnackBarView () {
    UILabel *textLabel;
    UIButton *actionButton;
    NSArray *horizontalLayoutConstraints;
    NSTimer *dismissTimer;
}

@property(nonatomic) RNSnackBarViewState state;
@property(nonatomic, strong) NSDictionary *pendingOptions;
@property(nonatomic, strong) NSString *text;
@property(nonatomic, strong) UIColor *textColor;
@property(nonatomic, strong) NSString *actionText;
@property(nonatomic, strong) UIColor *actionTextColor;
@property(nonatomic, strong) NSNumber *marginBottom;
@property(nonatomic, strong) NSArray<NSLayoutConstraint *> *verticalPaddingConstraints;
@property(nonatomic, strong) void (^pendingCallback)();
@property(nonatomic, strong) void (^callback)();

@end

@implementation RNSnackBarView

+ (void)initialize {
    DEFAULT_DURATIONS = @{@"-1" : @1500, @"-2" : @2750, @"0" : @INT_MAX};
}

+ (id)sharedSnackBar {
    static RNSnackBarView *sharedSnackBar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      sharedSnackBar = [[self alloc] init];
    });
    return sharedSnackBar;
}

+ (void)showWithOptions:(NSDictionary *)options andCallback:(void (^)())callback {
    RNSnackBarView *snackBar = [RNSnackBarView sharedSnackBar];
    snackBar.pendingOptions = options;
    snackBar.pendingCallback = callback;
    [snackBar show];
}

+ (void)dismiss {
    RNSnackBarView *snackBar = [RNSnackBarView sharedSnackBar];
    [snackBar dismiss];
}

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 48,
                                           [UIScreen mainScreen].bounds.size.width, 48)];
    if (self) {
        [self buildView];
    }
    return self;
}

- (void)buildView {
    self.backgroundColor = [UIColor colorWithRed:0.196078F
                                           green:0.196078F
                                            blue:0.196078F
                                           alpha:1.0F];
    self.accessibilityIdentifier = @"snackbar";

    textLabel = [UILabel new];
    textLabel.text = _text;
    textLabel.numberOfLines = 2;
    textLabel.textColor = _textColor;
    textLabel.font = [UIFont boldSystemFontOfSize:14];
    [textLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:textLabel];

    actionButton = [UIButton new];
    actionButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [actionButton setTitle:@"" forState:UIControlStateNormal];
    [actionButton addTarget:self
                     action:@selector(actionPressed:)
           forControlEvents:UIControlEventTouchUpInside];
    [actionButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:actionButton];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:actionButton
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:textLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
    [textLabel setContentCompressionResistancePriority:250
                                                forAxis:UILayoutConstraintAxisHorizontal];
    [textLabel setContentHuggingPriority:250 forAxis:UILayoutConstraintAxisHorizontal];
    [actionButton setContentCompressionResistancePriority:750
                                                  forAxis:UILayoutConstraintAxisHorizontal];
    [actionButton setContentHuggingPriority:750 forAxis:UILayoutConstraintAxisHorizontal];

    self.actionHidden = YES;
}

- (void)setText:(NSString *)text {
    textLabel.text = text;
}

- (void)setActionHidden:(BOOL)hidden {
    if (actionButton.hidden != hidden || horizontalLayoutConstraints == nil) {
        actionButton.hidden = hidden;
        if (horizontalLayoutConstraints != nil) {
            [self removeConstraints:horizontalLayoutConstraints];
        }
        if (hidden) {
            horizontalLayoutConstraints =
                [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-24-[textLabel]-24-|"
                                                        options:0
                                                        metrics:nil
                                                          views:@{@"textLabel" : textLabel}];
        } else {
            horizontalLayoutConstraints = [NSLayoutConstraint
                constraintsWithVisualFormat:@"H:|-24-[textLabel]-24-[actionButton]-24-|"
                                    options:0
                                    metrics:nil
                                      views:@{
                                          @"textLabel" : textLabel,
                                          @"actionButton" : actionButton
                                      }];
        }
        [self addConstraints:horizontalLayoutConstraints];
    }
}

- (void)setTextColor:(UIColor *)textColor {
    textLabel.textColor = textColor;
}

- (void)setNumberOfLines:(int *)numberOfLines {
    textLabel.numberOfLines = numberOfLines;
}

- (void)setActionText:(NSString *)actionText {
    [actionButton setTitle:actionText forState:UIControlStateNormal];
}

- (void)setActionTextColor:(UIColor *)actionTextColor {
    [actionButton setTitleColor:actionTextColor forState:UIControlStateNormal];
}

- (void)actionPressed:(UIButton *)sender {
    [self dismiss];
    self.callback();
}

- (void)presentWithDuration:(NSNumber *)duration {
    _pendingOptions = nil;
    _pendingCallback = nil;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    [self setTranslatesAutoresizingMaskIntoConstraints:false];
    
    // Set vertical padding
    CGFloat topPadding = 14;
    CGFloat bottomPadding = topPadding;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;

        // If no bottom margin, increase bottom padding to size of safe area inset
        if ([self.marginBottom integerValue] == 0 && window.safeAreaInsets.bottom > bottomPadding)
            bottomPadding = window.safeAreaInsets.bottom;
    }
    NSLog([NSString stringWithFormat:@"V:|-%f-[textLabel]-%f-|", topPadding,
           bottomPadding]);
    if (self.verticalPaddingConstraints) // Remove old constraints
        [self removeConstraints:self.verticalPaddingConstraints];
    self.verticalPaddingConstraints = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[textLabel]-%f-|", topPadding,
                                                                     bottomPadding]
                                                                            options:0
                                                                            metrics:nil
                                                                              views:@{@"textLabel" : textLabel}];
    [self addConstraints:self.verticalPaddingConstraints];

    // Set margins
    [keyWindow addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[self(>=48)]-%@-|", self.marginBottom]
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"self" : self}]];
    [keyWindow addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[self]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"self" : self}]];

    // Snackbar will slide up from bottom, unless a bottom margin is set in which case we use a fade animation
    self.transform = CGAffineTransformMakeTranslation(0, [self.marginBottom integerValue] == 0 ? self.bounds.size.height : 0);
    textLabel.alpha = 0;
    actionButton.alpha = 0;
    if ([self.marginBottom integerValue] == 0) {
        self.alpha = 0;
    }
    self.state = RNSnackBarViewStatePresenting;
    [UIView animateWithDuration:ANIMATION_DURATION
        animations:^{
          self.transform = CGAffineTransformIdentity;
          textLabel.alpha = 1;
          actionButton.alpha = 1;
          self.alpha = 1;
        }
        completion:^(BOOL finished) {
          self.state = RNSnackBarViewStateDisplayed;
          NSTimeInterval interval;
          if ([duration doubleValue] <= 0) {
              NSString *durationString = [duration stringValue];
              interval = [(NSNumber *)DEFAULT_DURATIONS[durationString] floatValue] / 1000;
          } else {
              interval = [duration doubleValue] / 1000;
          }
          dismissTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                          target:self
                                                        selector:@selector(dismiss)
                                                        userInfo:nil
                                                         repeats:FALSE];
        }];
}

- (void)dismiss {
    [self.layer removeAllAnimations];
    [dismissTimer invalidate];
    self.state = RNSnackBarViewStateDismissing;
    [UIView animateWithDuration:ANIMATION_DURATION
        animations:^{
          self.transform = CGAffineTransformMakeTranslation(0, [self.marginBottom integerValue] == 0 ? self.bounds.size.height : 0);
          self.alpha = 0;
        }
        completion:^(BOOL finished) {
          self.state = RNSnackBarViewStateDismissed;
          [self removeFromSuperview];
          if (_pendingOptions) {
              [self show];
          }
        }];
}

- (void)show {
    if (self.state == RNSnackBarViewStateDisplayed || self.state == RNSnackBarViewStatePresenting) {
        [self dismiss];
        return;
    }
    if (self.state == RNSnackBarViewStateDismissing) {
        return;
    }
    if (!_pendingOptions) {
        return;
    }

    NSNumber *numberOfLines = _pendingOptions[@"numberOfLines"];
    self.numberOfLines = [RCTConvert int:numberOfLines] ? [RCTConvert int:numberOfLines] : 2;
    
    self.marginBottom = _pendingOptions[@"marginBottom"] ? _pendingOptions[@"marginBottom"] : @(0);
    
    id backgroundColor = _pendingOptions[@"backgroundColor"];
    self.backgroundColor = backgroundColor ? [RCTConvert UIColor:backgroundColor]
                                           : [UIColor colorWithRed:0.196078F
                                                             green:0.196078F
                                                              blue:0.196078F
                                                             alpha:1.0F];

    id textColor = _pendingOptions[@"textColor"];
    self.textColor = textColor ? [RCTConvert UIColor:textColor] : [UIColor whiteColor];

    self.text = _pendingOptions[@"text"];
    self.callback = _pendingCallback;

    NSDictionary *action = _pendingOptions[@"action"];
    if (action) {
        self.actionText = _pendingOptions[@"action"][@"text"];
        self.actionHidden = _pendingOptions[@"action"][@"text"] ? NO : YES;
        NSNumber *color = _pendingOptions[@"action"][@"textColor"];
        self.actionTextColor = [RCTConvert UIColor:color];
    } else {
        self.actionText = @"";
        self.actionHidden = YES;
    }

    NSNumber *duration =
        _pendingOptions[@"duration"] ? (NSNumber *)_pendingOptions[@"duration"] : @(-1);

    [self presentWithDuration:duration];
}

@end

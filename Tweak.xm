//
//  Tweak.mm
//  TranslucentMessages
//
//  Copyright (c) 2017 Dynastic Development
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "Common/DDTMCommon.h"
#import "Headers/UIBackgroundStyle.h"
#import "Headers/SMSHeaders.h"
#import "Headers/SMSCategories.h"

static BOOL isEnabled = YES;
static BOOL shouldBlur = YES;
static BOOL hasPromptedAboutReduceTransparency = NO;
CFStringRef kPrefsAppID = CFSTR("tk.ethanrdoesmc.translucency");

static void loadSettings() {
    NSDictionary *settings = nil;
    CFPreferencesAppSynchronize(kPrefsAppID);
    CFArrayRef keyList = CFPreferencesCopyKeyList(kPrefsAppID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (keyList) {
        settings = (NSDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, kPrefsAppID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
        CFRelease(keyList);
    }
    if (settings && settings[@"Enabled"]) {
        isEnabled = [settings[@"Enabled"] boolValue];
    }
    if (settings && settings[@"BlurWallpaper"]) {
        shouldBlur = [settings[@"BlurWallpaper"] boolValue];
    }
    if (settings && settings[@"ReduceTransparencyPrompted"]) {
        hasPromptedAboutReduceTransparency = [settings[@"ReduceTransparencyPrompted"] boolValue];
    }
}

static void settingsChanged(CFNotificationCenterRef center,
                            void *observer,
                            CFStringRef name,
                            const void *object,
                            CFDictionaryRef userInfo) {
    [[UIApplication sharedApplication] terminateWithSuccess];
}

%group Tweak

// MARK: - Main Application

%hook UIApplication

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL result = %orig;
    [application _setBackgroundStyle:UIBackgroundStyleDefault];
    UIWindow *window = MSHookIvar<UIWindow *>(application, "_window");
    [window setBackgroundColor:[UIColor clearColor]];
    [window setOpaque:NO];
    return result;
}

-(void)_setBackgroundStyle:(UIBackgroundStyle)style {
    if(shouldBlur) {
        %orig([NSClassFromString(@"UIBehavior") hasDarkTheme] ? [DDTMColours darkBlurStyle] : [DDTMColours blurStyle]);
    } else {
        %orig([DDTMColours transparentStyle]);
    }
}

%end

// MARK: - Make navigation bar more translucent

%hook UINavigationBar

-(void)_commonNavBarInit {
    %orig;
    _UIBarBackground *barBackgroundView = MSHookIvar<_UIBarBackground *>(self, "_barBackgroundView");
    [barBackgroundView setDDIsInNavigationBar:YES];
}

%end

%hook _UIBarBackground

%property (nonatomic, assign) BOOL DDIsInNavigationBar;

-(id)_blurWithStyle:(long long)arg1 tint:(id)arg2 {
    if([self DDIsInNavigationBar] && arg1 == 0) {
        return [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    }
    return %orig;
}

%end
// copy and hook uitextfield or something instead - also worth noting that this is a vibrant view
%hook UITextField

-(id)initWithFrame:(CGRect)arg1 marginInsets:(UIEdgeInsets)arg2 shouldAllowImpact:(BOOL)arg3 shouldShowSendButton:(BOOL)arg4 shouldShowSubject:(BOOL)arg5 shouldShowPluginButtons:(BOOL)arg6 shouldShowCharacterCount:(BOOL)arg7 {
    self = %orig;
    [self DDInitialize];
    return self;
}

-(id)initForFullscreenAppViewWithFrame:(CGRect)arg1 marginInsets:(UIEdgeInsets)arg2 shouldAllowImpact:(BOOL)arg3 shouldShowSendButton:(BOOL)arg4 shouldShowSubject:(BOOL)arg5 shouldShowBrowserButton:(BOOL)arg6 shouldShowCharacterCount:(BOOL)arg7 {
    self = %orig;
    [self DDInitialize];
    return self;
}

-(id)initWithFrame:(CGRect)arg1 marginInsets:(UIEdgeInsets)arg2 shouldShowSendButton:(BOOL)arg3 shouldShowSubject:(BOOL)arg4 shouldShowPluginButtons:(BOOL)arg5 shouldShowCharacterCount:(BOOL)arg6 {
    self = %orig;
    [self DDInitialize];
    return self;
}

%new
-(void)DDInitialize {
    [[self backdropView] setDDIsMessageEntryView:YES];
    [self setDDSpecialEffectsActive:![self shouldConfigureForFullscreenAppView]];
}

%new
-(BOOL)DDSpecialEffectsActive {
    return [[self backdropView] DDSpecialEffectsActive];
}

%new
-(void)setDDSpecialEffectsActive:(BOOL)active {
    [self.backdropView setDDSpecialEffectsActive:active];
    [self.backdropView setBackgroundColor:(active ? [UIColor clearColor] : [UIColor colorWithWhite:0.3 alpha:0.8])];
}

%end

%hook _UIBackdropView
// also tweak headers for better sw compat.
%property (nonatomic, assign) BOOL DDSpecialEffectsActive;
%property (nonatomic, assign) BOOL DDIsMessageEntryView;

-(id)initWithFrame:(CGRect)arg1 {
    self = %orig;
    [self DDCommonInit];
    return self;
}

-(id)init {
    self = %orig;
    [self DDCommonInit];
    return self;
}

-(id)initWithFrame:(CGRect)arg1 style:(long long)arg2 {
    self = %orig;
    [self DDCommonInit];
    return self;
}

-(id)initWithStyle:(long long)arg1 {
    self = %orig;
    [self DDCommonInit];
    return self;
}

-(id)initWithPrivateStyle:(long long)arg1 {
    self = %orig;
    [self DDCommonInit];
    return self;
}

-(id)initWithSettings:(id)arg1 {
    self = %orig;
    [self DDCommonInit];
    return self;
}

-(id)initWithFrame:(CGRect)arg1 privateStyle:(long long)arg2 {
    self = %orig;
    [self DDCommonInit];
    return self;
}

-(id)initWithFrame:(CGRect)arg1 autosizesToFitSuperview:(BOOL)arg2 settings:(id)arg3 {
    self = %orig;
    [self DDCommonInit];
    return self;
}

-(id)initWithFrame:(CGRect)arg1 settings:(id)arg2 {
    self = %orig;
    [self DDCommonInit];
    return self;
}

%new
-(void)DDCommonInit {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DDAppBackgrounding:) name:@"UIApplicationWillResignActiveNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DDAppResumed:) name:@"UIApplicationDidBecomeActiveNotification" object:nil];
}
// auto notif handling - need to prevent this from running if ios < 10 (perhaps add compat for whatever that tweak is that emulates rich notifs)
%new
-(void)DDAppBackgrounding:(NSNotification *)notif {
    %log;
    [self DDRemovePreservationView];
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CALayer *imageLayer = [[CALayer alloc] init];
    imageLayer.frame = self.bounds;
    imageLayer.zPosition = MAXFLOAT;
    imageLayer.contents = (id) image.CGImage;
    imageLayer.name = @"BlurPreservation";
    [self.layer addSublayer:imageLayer];
}

%new
-(void)DDAppResumed:(NSNotification *)notif {
    %log;
    [self DDRemovePreservationView];
}

%new
-(void)DDRemovePreservationView {
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer.name isEqualToString:@"BlurPreservation"]) {
            [layer removeFromSuperlayer];
            break;
        }
    }
}

%end

// MARK: - Fix balloon mask
//id like to reimplement this in list cells and the like - it's a great effect
%hook UICellView

-(BOOL)canUseOpaqueMask {
    return NO;
}

-(void)setCanUseOpaqueMask:(BOOL)arg1 {
    %orig(NO);
}

%end

// MARK: - Nav Controller?
// no its a view controller silly
%hook UIViewController

-(UIView *)view {
    UIView *orig = %orig;
    [self handleBG:orig];
    return orig;
}

-(void)setView:(UIView *)orig {
    [self handleBG:orig];
    %orig;
}

-(void)setDDPreviewing:(BOOL)previewing {
    %orig;
    [self handleBG:self.view];
}

%new
-(void)handleBG:(UIView *)view {
    [view setOpaque:NO];
    if([self DDPreviewing]) {
        [view setBackgroundColor:([NSClassFromString(@"UIBehavior") hasDarkTheme] ? [DDTMColours darkViewPreviewingBackgroundColour] : [DDTMColours viewPreviewingBackgroundColour])];
    } else {
        [view setBackgroundColor:[UIColor clearColor]];
    }
}

%end

// MARK: - Conversation List
// hmm - perhaps options for different elements as well?
%hook UIListController

-(void)loadView {
    %orig;
    [self.searchController.searchBar setDDSearchBar:YES];
}

-(void)setSearchController:(UISearchController *)arg1 {
    [arg1.searchBar setDDSearchBar:YES];
    %orig;
}

-(UIViewController *)previewingContext:(id)previewingContext viewControllerForLocation:(CGPoint)location {
    UIViewController *vc = %orig;
    if(vc) {
        [vc setDDPreviewing:YES];
    }
    return vc;
}

-(void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
commitViewController:(UIViewController *)viewControllerToCommit {
    %orig;
    [viewControllerToCommit setDDPreviewing:NO];
}

-(void)searcherDidComplete:(id)arg1 {
    %orig;
    UITableView *tableView = MSHookIvar<UITableView *>(self, "_table");
    [tableView setHidden:YES];
}

-(void)willDismissSearchController:(UISearchController *)searchController {
    %orig;
    UITableView *tableView = MSHookIvar<UITableView *>(self, "_table");
    [tableView setHidden:NO];
}

%end
// the Chevron screams either apptray or top bar
%hook UIListCell

-(void)layoutSubviews {
    // Chevron
    UIImageView *chevronImageView = MSHookIvar<UIImageView *>(self, "_chevronImageView");
    [chevronImageView setImage:[chevronImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [chevronImageView setTintColor:[DDTMColours separatorColour]];
    
    // Selection Colour
    UIView *selectionView = [[UIView alloc] init];
    [selectionView setBackgroundColor:[DDTMColours selectionColour]];
    [self setSelectedBackgroundView:selectionView];
    
    %orig;
}

-(UIColor *)backgroundColor {
    return [UIColor clearColor];
}

-(void)setBackgroundColor:(UIColor *)color {
    %orig([UIColor clearColor]);
}

%end
// searchbar code is near ready-to-go for sw, if not done
%hook UISearchBar

%property (nonatomic, assign) BOOL DDConvoSearchBar;

%new
-(void)DDCommonInit {
    [self setBarTintColor:[self barTintColor]];
    if([self DDSearchBar]) {
        UITextField *searchField = MSHookIvar<UITextField *>(self, "_searchField");
        [searchField setBackgroundColor:[NSClassFromString(@"UIBehavior") hasDarkTheme] ? [DDTMColours darkSearchBarFieldTintColour] : [DDTMColours searchBarFieldTintColour]];
    }
}


-(UIColor *)barTintColor {
    if([self DDConvoSearchBar]) {
        return [NSClassFromString(@"UIBehavior") hasDarkTheme] ? [DDTMColours darkSearchBarTintColour] : [DDTMColours searchBarTintColour];
    }
    return %orig;
}

-(void)setBarTintColor:(UIColor *)barTintColor {
    %orig([self barTintColor]);
}

%end

%hook UITransitionView

-(void)setEntryView:(UITextField *)arg1 {
    [arg1 setDDSpecialEffectsActive:NO];
    %orig;
}

%end

// MARK: - Navigation animation & interaction

%hook UIViewController

%property (nonatomic, retain) DDCustomInteraction *interactionController;
%property (nonatomic, retain) DDCustomAnimator *pushAnimator;
%property (nonatomic, retain) DDCustomAnimator *popAnimator;
%property (nonatomic, retain) DDCustomAnimator *pushCurvedAnimator;
%property (nonatomic, retain) DDCustomAnimator *popCurvedAnimator;

-(void)viewDidLoad {
    %orig;

    if(!hasPromptedAboutReduceTransparency && UIAccessibilityIsReduceTransparencyEnabled()) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Translucency" message:@"We noticed that you have Reduce Transparency turned on in Settings (General > Accessibility > Increase Contrast). This may cause the transparency not to be applied to apps properly and we recommend that you disable it.\nWe won't tell you again." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:YES completion:nil];
            NSDictionary *dict = [NSDictionary dictionaryWithObject:@(YES) forKey:@"ReduceTransparencyPrompted"];
            CFPreferencesSetMultiple((__bridge CFDictionaryRef)dict, nil, kPrefsAppID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
            CFPreferencesAppSynchronize(kPrefsAppID);
        });
    }
    
    [[self conversationListNavigationController] setDelegate:(id<UINavigationControllerDelegate>)self];
    
    [self setInteractionController:[[DDCustomInteraction alloc] init]];
    [[self interactionController] wireToViewController:[self conversationListNavigationController]];
    [self setPushAnimator:[[DDCustomAnimator alloc] init]];
    [self setPopAnimator:[[DDCustomAnimator alloc] initWithReverse:YES]];
    [self setPushCurvedAnimator:[[DDCustomAnimator alloc] initWithCurved:YES]];
    [self setPopCurvedAnimator:[[DDCustomAnimator alloc] initWithReverse:YES andCurved:YES]];
    
    [self.view setBackgroundColor:[[NSClassFromString(@"UIBehavior") currentTheme] UIViewControllerBackgroundColor]];
}

%new
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    BOOL canDoIt = false;
    if([fromVC isKindOfClass:NSClassFromString(@"UINavigationController")]) {
        if([((CKNavigationController *)fromVC).visibleViewController isKindOfClass:NSClassFromString(@"CKCoreChatController")] || [((UINavigationController *)fromVC).visibleViewController isKindOfClass:NSClassFromString(@"UIListController")]) {
            canDoIt = true;
        }
    }
    if([fromVC isKindOfClass:NSClassFromString(@"UIListController")]) {
        canDoIt = true;
    }
    if(canDoIt) {
        if(operation == UINavigationControllerOperationPush) {
            return [self interactionController].interactionInProgress ? [self pushAnimator] : [self pushCurvedAnimator];
        } else if(operation == UINavigationControllerOperationPop) {
            return [self interactionController].interactionInProgress ? [self popAnimator] : [self popCurvedAnimator];
        }
    }
    return nil;
}

%new
- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    if((DDCustomAnimator *)animationController) {
        if(((DDCustomAnimator *)animationController).reverse) {
            return self.interactionController.interactionInProgress ? self.interactionController : nil;
        }
    }
    return nil;
}

%end

// MARK: - DDViewControllerPeekDetection Hooks

%hook UIViewController

%property (nonatomic, assign) BOOL DDPreviewing;

%end

// MARK: - GroupMe support
// whoa - why didn't this get added? the filter is still mobilesms - unless im missing something
%hook UIView

-(void)setLabel:(UILabel *)arg1 {
    [arg1 setTextColor:[UIColor whiteColor]];
    %orig;
}

-(void)setImageView:(UIImageView *)arg1 {
    [arg1 setTintColor:[UIColor whiteColor]];
    %orig;
}

-(UIColor *)backgroundColor {
    return [UIColor clearColor];
}

-(void)setBackgroundColor:(UIColor *)color {
    %orig([self backgroundColor]);
}

%end

// MARK: - Keyboard Changes

%hook UIKBRenderFactory

+ (NSInteger)_graphicsQuality {
    static NSInteger keyboardGraphicsQuality;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        keyboardGraphicsQuality = [[UIDevice currentDevice] _graphicsQuality];
    });
    return keyboardGraphicsQuality;
}

%end

%hook UIKBRenderConfig

- (NSInteger)backdropStyle {
    return [NSClassFromString(@"UIBehavior") hasDarkTheme] ? 2030 : 3900;
}

+(long long)backdropStyleForStyle:(long long)arg1 quality:(long long)arg2 {
    return %orig([NSClassFromString(@"UIBehavior") hasDarkTheme] ? 2030 : 3900, arg2);
}

%end

%hook UIKeyboardPredictionView

-(id)initWithFrame:(CGRect)arg1 {
    self = %orig;
    UIView *darkeningView = [[UIView alloc] initWithFrame:self.bounds];
    [darkeningView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.25]];
    [darkeningView setTag:49203];
    [self addSubview:darkeningView];
    return self;
}

-(void)layoutSubviews {
    %orig;
    UIView *darkeningView = [self viewWithTag:49203];
    if(darkeningView) {
        [darkeningView setFrame:self.bounds];
    }
}

%end

%hook UIBehavior

%new
+(UITheme *)currentTheme {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return [[NSClassFromString(@"UIBehaviorPad") sharedBehaviors] theme];
    } else {
        return [[NSClassFromString(@"UIBehaviorPhone") sharedBehaviors] theme];
    }
}

%new
+(BOOL)hasDarkTheme {
    CKUITheme *theme = [NSClassFromString(@"UIBehavior") currentTheme];
    if([theme isKindOfClass:NSClassFromString(@"UIThemeDark")]) {
        return YES;
    }
    return NO;
}

%end

// MARK: - Theme Changes
// need to figure out how to connect this to a standardized view - which can then be inserted in a CC page, NC widget, or anything that does a standard loadView
%hook UIThemeLight

-(UIColor *)UIViewControllerBackgroundColor {
    return [DDTMColours viewBackgroundColour];
}

-(UIColor *)UIListBackgroundColor {
    return [DDTMColours viewBackgroundColour];
}

-(UIColor *)conversationListCellColor {
    return [UIColor clearColor];
}

-(UIColor *)conversationListSenderColor {
    return [DDTMColours listTitleColour];
}

-(UIColor *)conversationListSummaryColor {
    return [DDTMColours listSubtitleColour];
}

-(UIColor *)conversationListDateColor {
    return [DDTMColours listSubtitleColour];
}

-(id)gray_balloonColors {
    return @[[UIColor colorWithWhite:1 alpha:0.65], [UIColor colorWithWhite:1 alpha:0.5]];
}

-(UIColor *)stickerDetailsSubheaderTextColor {
    return [DDTMColours insideChatViewLabelColour];
}

-(UIColor *)transcriptTextColor {
    return [DDTMColours insideChatViewLabelColour];
}

-(UIColor *)transcriptBigEmojiColor {
    return [DDTMColours insideChatViewLabelColour];
}

-(UIColor *)transcriptDeemphasizedTextColor {
    return [DDTMColours insideChatViewLabelSubtleColour];
}

-(UIColor *)entryFieldCoverFillColor {
    return [DDTMColours entryFieldCoverFillColour];
}

-(UIColor *)entryFieldCoverBorderColor {
    return [DDTMColours entryFieldCoverBorderColour];
}

-(UIKeyboardAppearance)keyboardAppearance {
    return UIKeyboardAppearanceDark;
}

-(UIColor *)UITextFieldBackgroundColor {
    return [UIColor clearColor];
}

-(UIColor *)UITextFieldTextColor {
    return [DDTMColours entryFieldTextColour];
}

-(UIColor *)UITextFieldGrayColor {
    return [DDTMColours entryFieldPlaceholderColour];
}

-(long long)toFieldBackdropStyle {
    return 10100;
}

-(_UIBackdropViewSettings *)UITextFieldBackdropSettings {
    return [_UIBackdropViewSettings settingsForStyle:2];
}

-(UIColor *)appTintColor {
    return [DDTMColours lightAppTintColour];
}

%end

%hook UIThemeDark

-(UIColor *)messagesControllerBackgroundColor {
    return shouldBlur ? [DDTMColours darkViewBackgroundColour] : [DDTMColours darkViewTransparentBackgroundColour];
}

-(UIColor *)conversationListBackgroundColor {
    return shouldBlur ? [DDTMColours darkViewBackgroundColour] : [DDTMColours darkViewTransparentBackgroundColour];
}

-(UIColor *)conversationListCellColor {
    return [UIColor clearColor];
}

-(UIColor *)conversationListSenderColor {
    return [DDTMColours listTitleColour];
}

-(UIColor *)conversationListSummaryColor {
    return [DDTMColours listSubtitleColour];
}

-(UIColor *)conversationListDateColor {
    return [DDTMColours listSubtitleColour];
}

-(id)gray_balloonColors {
    return @[[UIColor colorWithWhite:0.3 alpha:0.45], [UIColor colorWithWhite:0.3 alpha:0.3]];
}

-(UIColor *)stickerDetailsSubheaderTextColor {
    return [DDTMColours insideChatViewLabelColour];
}

-(UIColor *)transcriptTextColor {
    return [DDTMColours insideChatViewLabelColour];
}

-(UIColor *)transcriptBigEmojiColor {
    return [DDTMColours insideChatViewLabelColour];
}

-(UIColor *)transcriptDeemphasizedTextColor {
    return [DDTMColours insideChatViewLabelSubtleColour];
}

-(UIColor *)entryFieldCoverFillColor {
    return [DDTMColours darkEntryFieldCoverFillColour];
}

-(UIColor *)entryFieldCoverBorderColor {
    return [DDTMColours darkEntryFieldCoverBorderColour];
}

-(UIColor *)entryFieldBackgroundColor {
    return [UIColor clearColor];
}

-(UIColor *)entryFieldTextColor {
    return [DDTMColours entryFieldTextColour];
}

-(UIColor *)entryFieldGrayColor {
    return [DDTMColours entryFieldPlaceholderColour];
}

%end

%hook CKEntryViewButton

-(UIColor *)ckTintColor {
    UIColor *tintColor = %orig;
    if(([self.superview isKindOfClass:NSClassFromString(@"CKMessageEntryView")] || [self.superview.superview isKindOfClass:NSClassFromString(@"CKMessageEntryView")] || [self.superview.superview.superview isKindOfClass:NSClassFromString(@"CKMessageEntryView")]) && (tintColor != [[NSClassFromString(@"CKUIBehavior") currentTheme] entryFieldHighlightedButtonColor]) && [self entryViewButtonType] != 4) {
        return [DDTMColours entryFieldButtonColour];
    }
    return tintColor;
}

-(void)setCkTintColor:(UIColor *)tintColor {
    if(([self.superview isKindOfClass:NSClassFromString(@"CKMessageEntryView")] || [self.superview.superview isKindOfClass:NSClassFromString(@"CKMessageEntryView")] || [self.superview.superview.superview isKindOfClass:NSClassFromString(@"CKMessageEntryView")]) && (tintColor != [[NSClassFromString(@"CKUIBehavior") currentTheme] entryFieldHighlightedButtonColor]) && [self entryViewButtonType] != 4) {
        %orig([DDTMColours entryFieldButtonColour]);
    } else {
        %orig;
    }
}

%end

// MARK: - iMessage app fix

%hook UIViewController

-(void)chatInputControllerWillPresentModalBrowserViewController:(id)arg1 {
    %orig;
    [[self entryView] setDDSpecialEffectsActive:NO];
}

-(void)chatInputControllerWillDismissModalBrowserViewController:(id)arg1 {
    %orig;
    [[self entryView] setDDSpecialEffectsActive:YES];
}

%end

%hook UITableView

-(void)layoutSubviews {
    %orig;
    [self setSeparatorColor:[self separatorColor]];
}

-(UIColor *)separatorColor {
    return [DDTMColours separatorColour];
}

-(void)setSeparatorColor:(UIColor *)color {
    %orig([self separatorColor]);
}

-(UIColor *)backgroundColor {
    return [UIColor clearColor];
}

-(void)setBackgroundColor:(UIColor *)color {
    %orig([self backgroundColor]);
}

%end

%hook PRMonogramView

-(void)didMoveToWindow {
    %orig;
    if([NSStringFromClass([[[(UIView *)self superview] superview] class]) isEqualToString:@"CKAvatarView"]) {
        CAGradientLayer *gradientLayer = MSHookIvar<CAGradientLayer *>(self, "_circleGradientLayer");
        if(![NSClassFromString(@"UIBehavior") hasDarkTheme] && [NSStringFromClass([[[[[(UIView *)self superview] superview] superview] superview] class]) isEqualToString:@"CKAvatarCollectionViewCell"]) { // is light mode & in navbar
            gradientLayer.colors = @[(id)[UIColor colorWithWhite:0 alpha:0.15].CGColor, (id)[UIColor colorWithWhite:0 alpha:0.05].CGColor];
        } else {
            gradientLayer.colors = @[(id)[UIColor colorWithWhite:1 alpha:0.1].CGColor, (id)[UIColor colorWithWhite:1 alpha:0.25].CGColor];
        }
    }
}

%end

%hook CKAvatarCollectionViewCell

-(void)didMoveToWindow {
    %orig;
    for(UIView *subview in [(UIView *)self subviews]) {
        [subview setBackgroundColor:[UIColor clearColor]];
    }
}

%end

%end

// MARK: - Loading

%ctor {
    @autoreleasepool {
        loadSettings();
        
        dlopen("/System/Library/PrivateFrameworks/PersonaUI.framework/PersonaUI", RTLD_LAZY);
        if (isEnabled) %init(Tweak);
        
        // listen for notifications from settings | (ethanr) so it just requires a notif? just need to figure out plist-ing from inside a tweak
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        NULL,
                                        (CFNotificationCallback)settingsChanged,
                                        CFSTR("tk.ethanrdoesmc.translucency.changed"),
                                        NULL,
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
    }
}

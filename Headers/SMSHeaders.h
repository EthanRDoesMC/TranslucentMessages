//
//  SMSHeaders.h
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

@interface UIApplication {
    UIWindow* _window;
}
@property (nonatomic,retain) UIWindow * window;
@end

@interface UIViewController <UINavigationControllerDelegate>
-(void)handleBG:(UIView *)view;
@end

@interface UIScrollViewController : CKViewController
@end

@interface UINavigationController
@end

@interface UISplitViewController
@end

@interface UITableViewController
-(UISearchController *)searchController;
-(void)setSearchController:(UISearchController *)arg1;
@end

@interface UITableView
@end

@interface UITableViewCell
@end

@interface _UIBackdropViewSettings : NSObject
-(void)setGrayscaleTintAlpha:(double)arg1;
-(void)setFilterMaskAlpha:(double)arg1;
-(void)setDarkeningTintAlpha:(double)arg1;
-(void)setColorOffsetAlpha:(double)arg1;
-(void)setColorBurnTintAlpha:(double)arg1;
-(void)setFilterMaskAlpha:(double)arg1;
-(void)setColorTintMaskAlpha:(double)arg1;
-(void)setGrayscaleTintMaskAlpha:(double)arg1;
-(void)setColorTint:(UIColor *)arg1 ;
-(void)setColorTintAlpha:(double)arg1 ;
+(_UIBackdropViewSettings *)settingsForStyle:(long long)arg1 ;
@end

@interface UIVisualEffect (EffectSettings)
-(_UIBackdropViewSettings *)effectSettings;
@end

@interface UINavigationBar
@end

@interface _UIBackdropView : UIView
-(UIView *)colorTintView;
-(void)setColorTintView:(UIView *)arg1;
-(UIView *)colorBurnTintView;
-(void)setColorBurnTintView:(UIView *)arg1;
-(UIView *)grayscaleTintView;
-(void)setGrayscaleTintView:(UIView *)arg1;
-(void)setStyle:(long long)arg1 ;
@end

@interface UITextField : UIView {
    _UIBackdropView * _backdropView;
}
-(BOOL)shouldConfigureForFullscreenAppView;
-(_UIBackdropView *)backdropView;
@end

@interface _UIBackdropEffectView : UIView
@end

@interface _UIBarBackground : UIView
@end

@interface UITextField : UITextView
@end

@interface UITextField : UIScrollView
@end

@interface UIButton
-(void)setCkTintColor:(UIColor *)arg1;
-(UIColor *)ckTintColor;
-(long long)entryViewButtonType;
@end

@interface UITheme : NSObject
- (id)entryFieldHighlightedButtonColor;
-(UIColor *)viewControllerBackgroundColor;
@end

@interface UIBehavior : NSObject
+(id)sharedBehaviors;
+(UITheme *)currentTheme;
+(BOOL)hasDarkTheme;
-(UITheme *)theme;
@end

@interface UIBehaviorPhone : UIBehavior
@end

@interface UIBehaviorPad : UIBehavior
@end

@interface UIScrollViewController
-(UIScrollView *)scrollView;
@end

@interface UIApplication (Private)
- (void)terminateWithSuccess;
@end

@interface UIKeyboardPredictionView : UIView
@end

@interface UIDevice (GraphicsQuality)
-(long long)_graphicsQuality;
@end

// MARK: - GroupMe Support

// LET THERE BE BUGS

@interface UIView
-(void)setLabel:(UILabel *)arg1 ;
-(void)setImageView:(UIImageView *)arg1 ;
@end

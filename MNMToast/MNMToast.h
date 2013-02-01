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

#import <CoreFoundation/CoreFoundation.h>

@class MNMToastValue;

/**
 * Completion handler fired when the toast disappears or the user taps on it.
 *
 * @param toast The toast value.
 * @param hasBeenTapped YES if the toast did dissapear.
 * @param hasBeenTapped YES if the toast has been tapped.
 */
typedef void(^MNMToastCompletionHandler)(MNMToastValue *toast, BOOL didDissapear, BOOL hasBeenTapped);

/**
 * Toast value, an object that wraps information about a toast entity.
 */
@interface MNMToastValue : NSObject

/**
 * The text to be shown.
 */
@property (nonatomic, readwrite, copy) NSString *text;

/**
 * YES to autohide after a certain delay.
 */
@property (nonatomic, readwrite, assign) BOOL autoHide;

/**
 * The completion handler of this toast.
 */
@property (nonatomic, readwrite, copy) MNMToastCompletionHandler completionHandler;

@end

/**
 * Object that manages a queue of toast entities, showing a floating view with a text that will be shown at the bottom of the __current view of the application window's root view controller__.
 *
 * **_NOTE_:** if you show another toast before the previous one has been dismissed then the older one will be dismissed 
 * to allow the new one to become visible. This means the toasts does not being stacked one over another.
 */
@interface MNMToast : NSObject

/**
 * YES if a toast is visible.
 */
@property (nonatomic, readonly) BOOL isToastVisible;

/**
 * Shows a toast.
 *
 * @param text The text to show.
 * @param autoHide YES to autohide after the fixed delay.
 * @param completionHandler The handler fired when the toast disappears or the user taps on it.
 *
 * **typedef void(^MNMToastCompletionHandler)(MNMToastValue *toast, BOOL didDissapear, BOOL hasBeenTapped);**
 *
 * - toast: The toast value.
 * - hasBeenTapped: YES if the toast did dissapear.
 * - hasBeenTapped: YES if the toast has been tapped.
 */
+ (void)showWithText:(NSString *)text
         autoHidding:(BOOL)autoHide
   completionHandler:(MNMToastCompletionHandler)completionHandler;

/**
 * Hides the current visible toast.
 *
 * Can be called even if was shown with autohiding.
 * After being dismissed the completion handler passed when shown will be invoked.
 */
+ (void)hide;

@end

`MNMToast` is a way to show non-intrusive floating texts at the bottom of the current view. It manages a queue of toast entities, showing a floating view with a text that will be shown at the bottom of the _current view of the application window's root view controller_.

**NOTE:** if you show another toast before the previous one has been dismissed then the older one will be dismissed to allow the new one to become visible. This means the toasts does not being stacked one over another.

Installation instructions
=========================

*Dependencies*

- QuartzCore.

1. Import `MNMToast.h` into the desired classes of your project.
2. Tou can show a toast this way

		[MNMToast showWithText:textToShow
                   autoHidding:YES
             completionHandler:^(MNMToastValue *toast, BOOL didDissapear, BOOL hasBeenTapped) {
                     
                     if (didDissapear) {
                         
                         NSLog(@"Toast did dissapear");
                     }
                     
                     if (hasBeenTapped) {
                         
                         [MNMToast showWithText:@"Toast has been tapped"
                                    autoHidding:YES
                              completionHandler:nil];
                     }
                 }];

3. You can see some examples in `ViewController` class.

Documentation
=============

Execute `appledoc appledoc.plist` in the root of the project path to generate documentation. 
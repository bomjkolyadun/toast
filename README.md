`MNMToast` is a way to show non-intrusive floating texts at the bottom of the current view. It manages a queue of toast entities, showing a floating view with a text that will be shown at the bottom of the _current view of the application window's root view controller_.

There are two blocks to handle completion (called when hiding animation finishes) and tap (called when a tap over the toast occurs).

 **_NOTE_:** the toasts does not being stacked one over another if push one before the previous has been dismissed or you hide it manually. If you want to prioritize the showing of a toast give it Hight priority.

Installation instructions
=========================

*Dependencies*

- QuartzCore.

1. Add whole `MNMToast` directory into your project.
2. You can show a toast this way

            [MNMToast showWithText:[textView_ text]
                       autoHidding:[autohidingSwitch_ isOn]
                          priority:MNMToastPriorityNormal
                 completionHandler:^(MNMToastValue *toast) {
                     
                     NSLog(@"Toast did dissapear");
                     
                 } tapHandler:^(MNMToastValue *toast) {
                     
                     [MNMToast hide];
                     [MNMToast showWithText:@"Toast has been tapped"
                          completionHandler:nil
                                 tapHandler:nil];
                 }];

3. You can see some examples in `ViewController` class.

Documentation
=============

Execute `appledoc appledoc.plist` in the root of the project path to generate documentation. 
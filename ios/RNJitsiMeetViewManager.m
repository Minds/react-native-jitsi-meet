#import "RNJitsiMeetViewManager.h"
#import "RNJitsiMeetView.h"

@implementation RNJitsiMeetViewManager{
    RNJitsiMeetView *jitsiMeetView;
}

RCT_EXPORT_MODULE(RNJitsiMeetView)
RCT_EXPORT_VIEW_PROPERTY(onConferenceJoined, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onConferenceTerminated, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onConferenceWillJoin, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onEnteredPip, RCTBubblingEventBlock)

- (UIView *)view
{
  jitsiMeetView = [[RNJitsiMeetView alloc] init];
  jitsiMeetView.delegate = self;
  return jitsiMeetView;
}

RCT_EXPORT_METHOD(initialize)
{
    RCTLogInfo(@"Initialize is deprecated in v2");
}

RCT_EXPORT_METHOD(call:(NSString *)urlString)
{
    RCTLogInfo(@"Load URL %@", urlString);
    dispatch_sync(dispatch_get_main_queue(), ^{
        JitsiMeetConferenceOptions *options = [JitsiMeetConferenceOptions fromBuilder:^(JitsiMeetConferenceOptionsBuilder *builder) {
            builder.room = urlString;
        }];
        [jitsiMeetView join:options];
    });
}

RCT_EXPORT_METHOD(callWithUserInfo:(NSString *)urlString :(NSString *)avatar :(NSString *)username :(NSString *)title)
{
    RCTLogInfo(@"Load URL %@", urlString);
    dispatch_sync(dispatch_get_main_queue(), ^{
        JitsiMeetUserInfo *info = [[JitsiMeetUserInfo alloc] initWithDisplayName:username andEmail:nil andAvatar:[NSURL URLWithString:avatar]];
        JitsiMeetConferenceOptions *options = [JitsiMeetConferenceOptions fromBuilder:^(JitsiMeetConferenceOptionsBuilder *builder) {
            builder.room = urlString;
            builder.subject = title;
            builder.userInfo = info;
            [builder setFeatureFlag:@"chat.enabled" withBoolean:NO]; // we disable the jitsi internal chat
        }];

        [jitsiMeetView join:options];
    });
}

RCT_EXPORT_METHOD(audioCall:(NSString *)urlString)
{
    RCTLogInfo(@"Load Audio only URL %@", urlString);
    dispatch_sync(dispatch_get_main_queue(), ^{
        JitsiMeetConferenceOptions *options = [JitsiMeetConferenceOptions fromBuilder:^(JitsiMeetConferenceOptionsBuilder *builder) {
            builder.room = urlString;
            builder.audioOnly = YES;
        }];
        [jitsiMeetView join:options];
    });
}

RCT_EXPORT_METHOD(endCall)
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [jitsiMeetView leave];
    });
}

#pragma mark JitsiMeetViewDelegate

- (void)conferenceJoined:(NSDictionary *)data {
    RCTLogInfo(@"Conference joined");
    if (!jitsiMeetView.onConferenceJoined) {
        return;
    }

    jitsiMeetView.onConferenceJoined(data);
}

- (void)conferenceTerminated:(NSDictionary *)data {
    RCTLogInfo(@"Conference terminated");
    if (!jitsiMeetView.onConferenceTerminated) {
        return;
    }

    jitsiMeetView.onConferenceTerminated(data);
}

- (void)conferenceWillJoin:(NSDictionary *)data {
    RCTLogInfo(@"Conference will join");
    if (!jitsiMeetView.onConferenceWillJoin) {
        return;
    }

    jitsiMeetView.onConferenceWillJoin(data);
}

- (void)enterPictureInPicture:(NSDictionary *)data {
    RCTLogInfo(@"Enter Picture in Picture");
    if (!jitsiMeetView.onEnteredPip) {
        return;
    }

    jitsiMeetView.onEnteredPip(data);
}

@end

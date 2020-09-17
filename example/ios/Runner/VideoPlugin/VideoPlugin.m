//
//  VideoPlugin.m
//  Runner
//
//  Created by 杜全中 on 2020/7/27.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import "VideoPlugin.h"
#import <AVFoundation/AVFoundation.h>
@implementation VideoPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel =
    [FlutterMethodChannel methodChannelWithName:@"com.luojigou.app/video"
                                binaryMessenger:[registrar messenger]];
    VideoPlugin* instance = [[VideoPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([call.method isEqualToString:@"compress"]) {
        NSURL *url = [NSURL fileURLWithPath:call.arguments];
        
        [self converVideoWithURL:url videodata:^(NSString *videoURL, NSData *videodata) {
            if (videoURL == nil) {
                NSDate *imageData = [self getImage:call.arguments];
                result(@[call.arguments, imageData]);
                return;
            }
            NSDate *imageData = [self getImage:videoURL];
            result(@[videoURL, imageData]);
        }];
    } else if ([call.method isEqualToString:@"getVideoImage"]) {
        NSDate *imageData = [self getImage:call.arguments];
        result(imageData);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

-(NSDate *)getImage:(NSString *)videoURL

{

    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil];

    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];

    gen.appliesPreferredTrackTransform = YES;

    CMTime time = CMTimeMakeWithSeconds(0.0, 600);

    NSError *error = nil;

    CMTime actualTime;

    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];

    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
   
    CGImageRelease(image);
    
    NSDate *imageData = UIImagePNGRepresentation(thumb);

    return imageData;


}

//  输出视频大小
- (CGFloat)fileSize:(NSURL *)path{
    return [[NSData dataWithContentsOfURL:path] length]/1024.00 /1024.00;
}
//  唯一标识码
- (NSString *)createCUID {
    
    NSString *result;
    
    CFUUIDRef uuid;
    
    CFStringRef uuidStr;
    
    uuid = CFUUIDCreate(NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    
    result =[NSString stringWithFormat:@"%@",uuidStr];
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    return result;
    
}


//视频压缩
-(void)converVideoWithURL:(NSURL *)url videodata:(void (^)(NSString *videoURL,NSData*  videodata)) block{
    //压缩视频
    //转码配置
//    [MBProgressHUD showActivityMessageInView:YBLocationString(@"视频压缩中...")];
    AVURLAsset *asset2 = [AVURLAsset URLAssetWithURL:url options:nil];
    AVAssetExportSession *exportSession= [[AVAssetExportSession alloc] initWithAsset:asset2 presetName:AVAssetExportPresetMediumQuality];
    exportSession.shouldOptimizeForNetworkUse = YES;
    //保存至沙盒路径
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *videoPath = [NSString stringWithFormat:@"%@/%@.mp4", pathDocuments, [self createCUID]];

    exportSession.outputURL = [NSURL fileURLWithPath:videoPath];
    exportSession.outputFileType = AVFileTypeMPEG4;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        int exportStatus = exportSession.status;
        NSLog(@"exportStatus~~~~~~%d",exportStatus);
        switch (exportStatus)
        {
            case AVAssetExportSessionStatusFailed:
            {
                // 压缩失败
                block(nil,nil);
            }
                break;
            case AVAssetExportSessionStatusCompleted:
            {
                NSData*Videodata = [NSData dataWithContentsOfFile:videoPath];
                block(videoPath,Videodata);
            }
                break;
        }
    }];
}


@end

//
//  FKDUStreamUtil.m
//  FlickrKit
//
//  Created by David Casserly on 10/06/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//

#import "FKDUStreamUtil.h"

#import <AssetsLibrary/AssetsLibrary.h>

@implementation FKDUStreamUtil

+ (void) writeMultipartStartString:(NSString *)startString imageStream:(NSInputStream *)imageInputStream toOutputStream:(NSOutputStream *)outputStream closingString:(NSString *)closingString {
    const char *UTF8String;
    size_t writeLength;
    UTF8String = [startString UTF8String];
    writeLength = strlen(UTF8String);
	
	size_t __unused actualWrittenLength;
	actualWrittenLength = [outputStream write:(uint8_t *)UTF8String maxLength:writeLength];
    NSAssert(actualWrittenLength == writeLength, @"Start string not writtern");
	
    // open the input stream
    const size_t bufferSize = 65536;
    size_t readSize = 0;
    uint8_t *buffer = (uint8_t *)calloc(1, bufferSize);
    NSAssert(buffer, @"Buffer not created");
	
    [imageInputStream open];
    while ([imageInputStream hasBytesAvailable]) {
        if (!(readSize = [imageInputStream read:buffer maxLength:bufferSize])) {
            break;
        }        
		
		size_t __unused actualWrittenLength;
		actualWrittenLength = [outputStream write:buffer maxLength:readSize];
        NSAssert (actualWrittenLength == readSize, @"Image stream not written");
    }
    
    [imageInputStream close];
    free(buffer);
    
    
    UTF8String = [closingString UTF8String];
    writeLength = strlen(UTF8String);
	actualWrittenLength = [outputStream write:(uint8_t *)UTF8String maxLength:writeLength];
    NSAssert(actualWrittenLength == writeLength, @"Closing string not written");
    [outputStream close];    
}

+ (void)writeMultipartWithAssetURL:(NSURL*)assetURL
                       startString:(NSString *)startString
                       imageFile:(NSString *)imageFile
                    toOutputStream:(NSOutputStream *)outputStream
                     closingString:(NSString *)closingString {
    
    // finish up the formdata
    NSOutputStream *startStream = [NSOutputStream outputStreamToFileAtPath:imageFile append:NO];
    [startStream open];
    
    NSData    *openingData = [startString dataUsingEncoding:NSUTF8StringEncoding];
    NSInteger startwriteLength = [openingData length];
    NSInteger startactualWrittenLength = [startStream write:[openingData bytes] maxLength:startwriteLength];
    
    [startStream close];
    NSAssert(startactualWrittenLength == startwriteLength, @"Start string not writtern");
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            ALAssetRepresentation *representation = [asset defaultRepresentation];
            NSOutputStream *mediaStream = [NSOutputStream outputStreamToFileAtPath:imageFile append:YES];
            [mediaStream open];
            
            NSUInteger bufferSize = 65536;
            NSUInteger read = 0, offset = 0, written = 0;
            uint8_t	   *buff = (uint8_t *)malloc(sizeof(uint8_t)*bufferSize);
            NSError	   *err = nil;
            
            do {
                read = [representation getBytes:buff fromOffset:offset length:bufferSize error:&err];
                written = [mediaStream write:buff maxLength:read];
                offset += read;
                if (err != nil) {
                    NSLog(@"ERROR!!:%@",err);
                    [mediaStream close];
                    free(buff);
                    return;
                }
                if (read != written) {
                    NSLog(@"ERROR!!%@",@"Couldn't prepare data for upload!");
                    [mediaStream close];
                    free(buff);
                    return;
                }
            } while (read != 0);
            
            free(buff);
            [mediaStream close];
            
            dispatch_semaphore_signal(sema);
        } failureBlock:^(NSError *error) {
            dispatch_semaphore_signal(sema);
        }];
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
#if OS_OBJECT_USE_OBJC!=1
    dispatch_release(sema);
#endif
    
    NSOutputStream *endStream = [NSOutputStream outputStreamToFileAtPath:imageFile append:YES];
    [endStream open];
    
    NSData    *closingData = [closingString dataUsingEncoding:NSUTF8StringEncoding];
    NSInteger writeLength = [closingData length];
    NSInteger actualWrittenLength = [endStream write:[closingData bytes] maxLength:writeLength];
    
    [endStream close];
    NSAssert(actualWrittenLength == writeLength, @"Closing string not written");
}

@end

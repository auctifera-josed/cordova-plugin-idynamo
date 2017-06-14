#import "CDVMagtek.h"

@implementation CDVMagtek

static NSString *dataCallbackId = nil;

#pragma mark -
#pragma mark Device Connection
#pragma mark -

- (void)pluginInitialize
{
    self.lib = [MTSCRA new];
    self.lib.delegate = self;
    [self.lib setDeviceType:MAGTEKIDYNAMO];
    [self.lib setDeviceProtocolString:@"com.magtek.idynamo"];
}

- (void)init: (CDVInvokedUrlCommand *) command {
    CDVPluginResult* result = nil;
    dataCallbackId = command.callbackId;
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:dataCallbackId];

}

- (void)openDevice:(CDVInvokedUrlCommand*)command {
   if(!self.lib.isDeviceOpened ) {
        [self.lib openDevice];
    }

}

- (void)closeDevice:(CDVInvokedUrlCommand*)command{
    if(self.lib.isDeviceOpened ) {
        [self.lib closeDevice];
    }
}

#pragma mark -
#pragma mark MTSCRA Delegate Methods
#pragma mark -

- (void) cardSwipeDidStart:(id)instance {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendEvent:@"cardSwipeDidStart" withData:nil];
    });
}
- (void) cardSwipeDidGetTransError {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendEvent:@"cardSwipeDidGetTransError" withData:nil];
    });
}

-(void) onDeviceConnectionDidChange:(MTSCRADeviceType)deviceType connected:(BOOL)connected instance:(id)instance {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([(MTSCRA*)instance isDeviceOpened]){
            if(connected) {
                [self sendEvent:@"onDeviceConnectionDidChange" withData:@"Connected"];
            } else {
                [self sendEvent:@"onDeviceConnectionDidChange" withData:@"Disconnected"];
            }
        } else {
            [self sendEvent:@"onDeviceConnectionDidChange" withData:@"Disconnected"];
        }
    });
}

-(void)onDataReceived:(MTCardData *)cardDataObj instance:(id)instance {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.trackDecodeStatus] forKey:@"Track.Status"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.track1DecodeStatus] forKey:@"Track1.Status"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.track2DecodeStatus] forKey:@"Track2.Status"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.track3DecodeStatus] forKey:@"Track3.Status"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.encryptionStatus] forKey:@"Encryption.Status"];
        [data setObject:[NSString stringWithFormat:@"%ld", cardDataObj.batteryLevel] forKey:@"Battery.Level"];
        [data setObject:[NSString stringWithFormat:@"%ld", cardDataObj.swipeCount] forKey:@"Swipe.Count"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.maskedTracks] forKey:@"Track.Masked"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.maskedTrack1] forKey:@"Track1.Masked"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.maskedTrack2] forKey:@"Track2.Masked"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.maskedTrack3] forKey:@"Track3.Masked"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.encryptedTrack1] forKey:@"Track1.Encrypted"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.encryptedTrack2] forKey:@"Track2.Encrypted"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.encryptedTrack3] forKey:@"Track3.Encrypted"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.cardPAN] forKey:@"Card.PAN"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.encryptedMagneprint] forKey:@"MagnePrint.Encrypted"];
        [data setObject:[NSString stringWithFormat:@"%ld", cardDataObj.magnePrintLength] forKey:@"MagnePrint.Length"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.magneprintStatus] forKey:@"MagnePrint.Status"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.encrypedSessionID] forKey:@"SessionID"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.cardIIN] forKey:@"Card.IIN"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.cardName] forKey:@"Card.Name"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.cardLast4] forKey:@"Card.Last4"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.cardExpDate] forKey:@"Card.ExpDate"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.cardExpDateMonth] forKey:@"Card.ExpDateMonth"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.cardExpDateYear] forKey:@"Card.ExpDateYear"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.cardServiceCode] forKey:@"Card.SvcCode"];
        [data setObject:[NSString stringWithFormat:@"%ld", cardDataObj.cardPANLength] forKey:@"Card.PANLength"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.deviceKSN] forKey:@"KSN"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.deviceSerialNumber] forKey:@"Device.SerialNumber"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.deviceSerialNumberMagTek] forKey:@"MagTek.SerialNumber"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.firmware] forKey:@"Firmware"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.deviceName] forKey:@"Device.Name"];
        [data setObject:[(MTSCRA*)instance getTLVPayload] forKey:@"TLV_Payload"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.deviceCaps] forKey:@"DeviceCapMSR"];
        [data setObject:[(MTSCRA*)instance getOperationStatus] forKey:@"Operation.Status"];
        [data setObject:[NSString stringWithFormat:@"%@", cardDataObj.cardStatus] forKey:@"Card.Status"];
        [data setObject:[(MTSCRA*)instance getResponseData] forKey:@"Raw_Data"];

        [self sendEvent:@"onDataReceived" withData:data];
    });
}

#pragma mark -
#pragma mark Util
#pragma mark -

- (void)sendEvent:(NSString *)dataType withData:(id)data {
    if (dataCallbackId != nil) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:dataType forKey:@"dataType"];
        if (data != nil) {
            [dict setObject:data forKey:@"data"];
        }
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:dataCallbackId];
    }
}

@end
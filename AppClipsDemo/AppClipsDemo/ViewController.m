//
//  ViewController.m
//  ClipsPackExtension
//
//  Created by wangshuailong on 2020/10/22.
//

#import "ViewController.h"
#import <NetworkExtension/NetworkExtension.h>

@interface ViewController ()

@property (strong, nonatomic) NEVPNManager *vpnManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blueColor];
    
    self.vpnManager = [NEVPNManager sharedManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vpnStatusDidChanged:) name:NEVPNStatusDidChangeNotification
             object:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self changeVPNStatus];
}


- (void)changeVPNStatus{
    NEVPNStatus status = _vpnManager.connection.status;
    if (status == NEVPNStatusConnected || status == NEVPNStatusConnecting || status == NEVPNStatusReasserting) {
        [self disconnect];
    } else {
        [self connect];
    }
}

- (void)connect {
    // Install profile
    [self installProfile];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vpnConfigDidChanged:) name:NEVPNConfigurationChangeNotification object:nil];
}

- (void)disconnect{
    [self.vpnManager.connection stopVPNTunnel];
}

- (void)vpnConfigDidChanged:(NSNotification *)notification{
    [self startConnecting];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEVPNConfigurationChangeNotification object:nil];
}

- (void)startConnecting{
    NSError *startError;
    [self.vpnManager.connection startVPNTunnelAndReturnError:&startError];
    if (startError) {
        NSLog(@"Start VPN failed: [%@]", startError.localizedDescription);
    }
}



- (void)vpnStatusDidChanged:(NSNotification *)notification{
    NEVPNStatus status = self.vpnManager.connection.status;
    switch (status) {
        case NEVPNStatusConnected:
            NSLog(@"NEVPNStatusConnected");
            break;
        case NEVPNStatusInvalid:
        case NEVPNStatusDisconnected:
            NSLog(@"NEVPNStatusDisconnected");
            break;
        case NEVPNStatusConnecting:
        case NEVPNStatusReasserting:
            NSLog(@"NEVPNStatusConnecting");
            break;
        case NEVPNStatusDisconnecting:
            NSLog(@"NEVPNStatusDisconnecting");
            break;
        default:
            break;
    }
}

- (void)installProfile {
    NSString *server = @"dsf01.yeafire.com";
    NSString *username = @"xiaowu";
    NSString *remoteIdentifier = @"tx";
    NSString *localIdnetifier = @"123";
    
    [self createKeychainValue:@"123456" forIdentifier:@"VPN_PASSWORD"];
    [self createKeychainValue:@"yeafire" forIdentifier:@"PSK"];
    
    [_vpnManager loadFromPreferencesWithCompletionHandler:^(NSError *error) {
        
        if (error) {
            NSLog(@"Load config failed [%@]", error.localizedDescription);
            return;
        }
        
        NEVPNProtocolIKEv2 *p = (NEVPNProtocolIKEv2 *)self.vpnManager.protocolConfiguration;
        
        if (p) {
        } else {
            p = [[NEVPNProtocolIKEv2 alloc] init];
        }
        
        p.username = username;
        p.serverAddress = server;
        
        p.passwordReference = [self searchKeychainCopyMatching:@"VPN_PASSWORD"];
        
        p.authenticationMethod = NEVPNIKEAuthenticationMethodSharedSecret;
        p.sharedSecretReference = [self searchKeychainCopyMatching:@"PSK"];
        
        p.localIdentifier = localIdnetifier;
        p.remoteIdentifier = remoteIdentifier;
        
        p.useExtendedAuthentication = YES;
        p.disconnectOnSleep = NO;
        
        self.vpnManager.protocolConfiguration = p;
        self.vpnManager.localizedDescription = @"IKEv2 Demo";
        self.vpnManager.enabled = YES;
        
        [self.vpnManager saveToPreferencesWithCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"Save config failed [%@]", error.localizedDescription);
            }
        }];
    }];
}


static NSString * const serviceName = @"im.zorro.ipsec_demo.vpn_config";

- (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    
    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrAccount];
    [searchDictionary setObject:serviceName forKey:(__bridge id)kSecAttrService];
    
    return searchDictionary;
}

- (NSData *)searchKeychainCopyMatching:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    
    [searchDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    
    [searchDictionary setObject:@YES forKey:(__bridge id)kSecReturnPersistentRef];
    
    CFTypeRef result = NULL;
    SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, &result);
    
    return (__bridge_transfer NSData *)result;
}

- (BOOL)createKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier {
    NSMutableDictionary *dictionary = [self newSearchDictionary:identifier];
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)dictionary);
    
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    [dictionary setObject:passwordData forKey:(__bridge id)kSecValueData];
    
    status = SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL);
    
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;
}

@end

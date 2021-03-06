//
//  AppDelegate.swift
//  SASKitFullscreen
//
//  Copyright © 2017 SAS Institute. All rights reserved.
//

import UIKit

import SASKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SASManagerDelegate
{
    let USE_GUESTMODE = true
    let USE_UUID_DESCRIPTOR = true
    
    func getApplicationName() -> String {
        return "SASKitFullscreen"
    }
    
    func getApplicationVersion() -> String {
        return "1.0"
    }
    
    var window: UIWindow?

    //MARK: Notification Listeners
    func handleReportsAvailable()
    {
        // SAS public sample report server
        let url : URL = URL(string: "https://tbub.sas.com:443")!
        
        // UUIDs of reports on sample server
        let reports : [String : String ] = ["Warranty Analysis" : "faca01f6-c631-4cbf-b336-6ba186dc632e" ,
                                            "Capital Campaign"  : "03db38a7-ff39-460e-9aca-3ee108c10140" ,
                                            "Retail Insights"   : "1ccd88c8-38a6-4473-90e0-8bdb447510a4" ,
                                            "Water Consumption and Monitoring" : "cd4205df-44a8-448a-a174-765f89abe058"]
        
        // attempt server verification
        SASManager.shared.verifySASServer( url )
        { (server, error) in
            
            if (self.USE_GUESTMODE)
            {
                server?.guestMode = true
            }
            else
            {
                server?.userid = ""
                server?.password = ""
            }

            server?.connect
            { (error) in
                
                var descriptor : SASReportDescriptor? = nil
                if (self.USE_UUID_DESCRIPTOR)
                {
                    let reportUUID : String = reports["Retail Insights"]!
                    descriptor = SASReportDescriptor(identifier: reportUUID)
                }
                else
                {
                    descriptor = SASReportDescriptor(name: "Retail Insights", location: "Public/Retail") //FAIL
                }
                
                server?.subscribe(descriptor: descriptor!)
                { (report, error ) in
                    
                    if report != nil
                    {
                        let vc : SASReportViewController = (report?.createViewController())!
                        self.window?.rootViewController = vc as? UIViewController;
                    }
                    else
                    {
                        print(error as Any)
                    }
                }

            }
        }
    }

    // MARK: UIApplicationDelegate life-cycle methods.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        SASManager.initialize(delegate: self)
        {_ in
            self.handleReportsAvailable()
        }
        
        // Override point for customization after application launch.
        return true
    }
    
    func showAlert(withTitle title: String!, message: String!, buttonTitle label: String!)
    {
        
    }
    
    func getHelpURL() -> URL!
    {
        return URL.init(string: "www.sas.com" )
    }

}


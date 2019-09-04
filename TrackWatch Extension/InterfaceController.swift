//
//  InterfaceController.swift
//  WatchKitApp Extension
//
//  Created by Haryanto Salim on 29/07/19.
//  Copyright © 2019 Haryanto Salim. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController {
    
    
    
    var arrOfData:[[String]] = [["fauzi","connected"],["reyhan","connected"]]
    
    
    @IBOutlet weak var myTable: WKInterfaceTable!
    
    var session = WCSession.default
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        myTable.setNumberOfRows(arrOfData.count, withRowType: "User")
        
        for index in 0..<myTable.numberOfRows {
            guard let controller = myTable.rowController(at: index) as? myTableObject  else { continue }
            
            controller.data = arrOfData[index]
        }
        // Configure interface objects here.
        print(#function)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        print(#function)
        
        if(WCSession.isSupported()){
            self.session = WCSession.default;
            self.session.delegate = self;
            self.session.activate();
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        print(#function)
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let data = arrOfData[rowIndex]
        presentController(withName: "DetailPage", context: data)
    }
    
}


extension InterfaceController: WCSessionDelegate{
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print(#function)
        OperationQueue.main.addOperation {
            guard let parsedDataFromPhone = applicationContext as? [String : Any] else{
                return
            }
            if let Data = parsedDataFromPhone["Watch"] as? [String : Any] {
                self.presentAlert(withTitle: "\(Data["peerID"])", message: "\(Data["message"])", preferredStyle: .alert, actions: [WKAlertAction(title: "OK", style: .cancel, handler: {
                    
                })])
                print(Data)
            }
            
            
        }
        
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(#function)
    }
    
    
}

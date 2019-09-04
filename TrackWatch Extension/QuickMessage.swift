//
//  QuickMessage.swift
//  Trekker
//
//  Created by Fauzi Rizal on 23/08/19.
//  Copyright © 2019 Fauzi Rizal. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class QuickMessage: WKInterfaceController {
    
    // variables
    var arrayOfMessages = ["REST","SLOW DOWN","REGROUP","INJURED"]
    var session = WCSession.default
    
    // outlets
    @IBOutlet weak var messages: WKInterfaceTable!
    
    @IBOutlet weak var labelQM: WKInterfaceLabel!
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        messages.setNumberOfRows(arrayOfMessages.count, withRowType: "Row")
        
        // Configure interface objects here.
        for i in 0..<messages.numberOfRows{
            guard let controller = messages.rowController(at: i) as? RowMessage else{continue}
            controller.data = arrayOfMessages[i]
        }

        session.activate()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        var con = messages.rowController(at: rowIndex) as? RowMessage
        
        sendData(session, con!.data )
    }
    
    func sendData(_ session: WCSession, _ data: String){
        if session.activationState == .activated {
            let myData = data
            
            do {
                try session.updateApplicationContext(["quickMessage": myData])
                
            } catch{
                print(error)
            }
        }
    }
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if WCSession.isSupported() {
            self.session = WCSession.default;
            self.session.delegate = self;
            self.session.activate();
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}

extension QuickMessage: WCSessionDelegate {
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print(#function)
        OperationQueue.main.addOperation {
            guard let parsedDataFromPhone = applicationContext as? [String : Any] else{
                print("guarderror ")
                return;
            }

            print(parsedDataFromPhone)
            
            if let Data = parsedDataFromPhone["Watch"] as? [String : Any] {
                self.presentAlert(withTitle: "\(Data["peerID"])", message: "\(Data["message"])", preferredStyle: .alert, actions: [WKAlertAction(title: "OK", style: .cancel, handler: {

                })])
                print(Data)
            }else{
                print("error")
            }
            
            
        }
        
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(#function)
    }
    
    
}

//
//  TripMatesVC.swift
//  Trackr
//
//  Created by Fauzi Rizal on 27/08/19.
//  Copyright © 2019 Fauzi Rizal. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import WatchConnectivity
import CoreLocation
import Network

class TripMatesVC: UIViewController, CLLocationManagerDelegate {
    
    // data variables
    var arrayOfPeople = [MCPeerID]()
    var peopleData = [MCPeerID : People]()
    
    // location variables
    var locationManager = CLLocationManager()
    var myLastLocation: CLLocation!
    
    // network variables
    var network = NetworkService()
    let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    let queue = DispatchQueue(label: "InternetConnectionMonitor")
    
    // watch variables
    var watchSession = WCSession.default
    
    
    
    // outlets
    @IBOutlet weak var friendsListTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsListTableView.register(UINib(nibName: "FriendListTableViewCell", bundle: nil), forCellReuseIdentifier: "avatarCell")
        network.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
            do {
                try self.watchSession.updateApplicationContext(["hi" : "apa"])
            }
            catch{
                return
            }
            self.friendsListTableView.reloadData()
            for data in self.peopleData{
                
            }
           
        }
        
        if WCSession.isSupported() {
            self.watchSession = WCSession.default
            self.watchSession.delegate = self
            self.watchSession.activate()
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            myLastLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("titit")
    }
    
    @IBAction func endTripButton(_ sender: UIButton) {
        self.network.session.disconnect()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapSegue" {
            let mapVC = segue.destination as! MapVC
            let indexPath = friendsListTableView.indexPathForSelectedRow!.row - 1
            for (row , data) in peopleData.enumerated(){
                if row == indexPath {
                    mapVC.anotherPeopleLoc = CLLocation(latitude: data.value.latitude, longitude: data.value.longitude)
                    mapVC.anotherPeopleName = data.value.name
                }
            }
            mapVC.myLoc = myLastLocation
        }
    }
}

extension TripMatesVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrayOfPeople.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = friendsListTableView.dequeueReusableCell(withIdentifier: "avatarCell", for: indexPath) as! FriendListTableViewCell
        
        monitor.pathUpdateHandler = { (pathUpdateHandler) in
            if pathUpdateHandler.status == .satisfied {
                if indexPath.row == 0 {
                    DispatchQueue.main.async {
                        cell.nameLabel.text = UIDevice.current.name
                        cell.connectionLabel.isHidden = false
                        cell.connectionLabel.text = "Connected"
                        cell.connectionLabel.textColor = UIColor.green
                    }
                } else {
                    if self.network.session.connectedPeers.count > 0{
                        if self.network.session.connectedPeers[indexPath.row - 1] != self.arrayOfPeople[indexPath.row - 1] {
                            DispatchQueue.main.async {
                                cell.connectionLabel.text = "Disconnected"
                                cell.connectionLabel.textColor = UIColor.red
                                cell.nameLabel.text = self.arrayOfPeople[indexPath.row - 1].displayName
                                // sendData() make indexPath.row
                            }
                        } else {
                            DispatchQueue.main.async {
                                cell.nameLabel.text = self.arrayOfPeople[indexPath.row - 1].displayName
                                cell.connectionLabel.isHidden = false
                                cell.connectionLabel.text = "Connected"
                                cell.connectionLabel.textColor = UIColor.green
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            cell.connectionLabel.text = "Disconnected"
                            cell.connectionLabel.textColor = UIColor.red
                            cell.nameLabel.text = self.arrayOfPeople[indexPath.row - 1].displayName
                        }
                    }
                }
            } else {
                let alert = UIAlertController(title: "Connect to Hotspot", message: "Please connect to a hotspot to see other available trip mates", preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Ok", style: .default, handler: { (alertAction) in
                    let url = URL(string: "App-Prefs:root=WIFI") //for WIFI setting app
                    let app = UIApplication.shared
                    app.open(url!, options: [:], completionHandler: nil)
                })
                
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        monitor.start(queue: queue)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        friendsListTableView.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor(white: 1, alpha: 0)
        cell.contentView.backgroundColor = .clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "mapSegue", sender: self)
        self.friendsListTableView.deselectRow(at: indexPath, animated: false)
        
    }
    
}

extension TripMatesVC : NetworkServiceDelegate {
    func connectedDevicesChanged(manager: NetworkService, connectedDevices: [String]) {
    }
    
    func gotLocationData(manager: NetworkService, locData: [String: Any]) {
        OperationQueue.main.addOperation {
            guard let parsedDictionary = locData as? [String: Any] else{
                return
            }
            if let parsedUser = parsedDictionary["User"] as? [String : Any] {
                print("parsedDict : \(parsedDictionary)")
                print("parsedUser : \(parsedUser)")
                print("parsed : \(parsedUser["peerID"])")
                
                let peopleDataReceived = self.peopleData[parsedUser["peerID"]as! MCPeerID]!
                peopleDataReceived.latitude = parsedUser["latitude"] as! Double
                peopleDataReceived.longitude = parsedUser["longitude"] as! Double
                self.peopleData[parsedUser["peerID"] as! MCPeerID] = peopleDataReceived
                
                print("data latitude: \(self.peopleData[parsedUser["peerID"]! as! MCPeerID])")
            } else if let parsedFromWatch = parsedDictionary["Watch"] as? [String:Any] {
                do {
                    print("pri \(parsedFromWatch)")
                    try? self.watchSession.updateApplicationContext(parsedFromWatch)
                    
                } catch {
                    print("gagal kirim anj")
                }
            }else{
                print("another")
            }
        }
    }
    
    func lostPeer(peerID: String) {
        OperationQueue.main.addOperation {
            let alert = UIAlertController(title: "Someone's missing", message: "\(peerID) has been disconnected", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

extension TripMatesVC : WCSessionDelegate{
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print(#function)
        var dataFromWatch = applicationContext["quickMessage"] as! String
        print("hiiiii : \(dataFromWatch)")
        DispatchQueue.main.async {
            do {
                var watchDict = [String: Any]()
                watchDict["Watch"] = ["message" : "\(dataFromWatch)", "peerID": self.network.session.myPeerID.displayName]
                let data = NSKeyedArchiver.archivedData(withRootObject: watchDict)
                try self.network.session.send(data, toPeers: self.network.session.connectedPeers, with: .reliable)
                print("bisa send : \(watchDict)")
            } catch {
                print(error)
            }
        }
        
    }
    
}

//
//  ViewController.swift
//  Trackr
//
//  Created by Fauzi Rizal on 27/08/19.
//  Copyright © 2019 Fauzi Rizal. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import Network

class GatherFriendsVC: UIViewController {
    
    // outlets
    @IBOutlet weak var friendsListTableView: UITableView!
    
    
    // variables
    let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    let queue = DispatchQueue(label: "InternetConnectionMonitor")
    let network = NetworkService()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
            self.friendsListTableView.reloadData()
        }
        
        friendsListTableView.register(UINib(nibName: "GatherFriendsCell", bundle: nil), forCellReuseIdentifier: "gatheringCell")
        
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func startTripButton(_ sender: UIButton) {
        if network.session.connectedPeers.count == 0 {
            let alert = UIAlertController(title: "Connect with your mates", message: "Please connect with your trip mates to continue", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "startTripSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startTripSegue" {
            let nextVC = segue.destination as! TripMatesVC
            nextVC.arrayOfPeople = network.session.connectedPeers
            
            for i in 0...network.session.connectedPeers.count-1 {
                let people = network.session.connectedPeers[i]
                nextVC.peopleData[people] = People(name: people.displayName, longitude: 0, latitude: 0)
            }
            nextVC.network = network
        }
    }
    
    
}



extension GatherFriendsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if network.session.connectedPeers.count == 0 {
            return 1
        } else {
            return network.session.connectedPeers.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = friendsListTableView.dequeueReusableCell(withIdentifier: "gatheringCell", for: indexPath) as! GatherFriendsCell
        
        monitor.pathUpdateHandler = { (pathUpdateHandler) in
            
            if pathUpdateHandler.status == .satisfied {
                if self.network.session.connectedPeers.count == 0 {
                    DispatchQueue.main.async {
                        cell.nameLabel.text = UIDevice.current.name
                        cell.connectionLabel.isHidden = false
                        cell.connectionLabel.text = "connected"
                        cell.connectionLabel.textColor = UIColor.green
                    }
                    
                } else {
                    if indexPath.row == 0 {
                        DispatchQueue.main.async {
                            cell.nameLabel.text = UIDevice.current.name
                            cell.connectionLabel.isHidden = false
                            cell.connectionLabel.text = "connected"
                            cell.connectionLabel.textColor = UIColor.green
                        }
                        
                    } else {
                        DispatchQueue.main.async {
                            let listOfConnectedPeers = self.network.session.connectedPeers[indexPath.row - 1]
                            cell.nameLabel.text = listOfConnectedPeers.displayName
                            cell.connectionLabel.isHidden = false
                            cell.connectionLabel.text = "connected"
                            cell.connectionLabel.textColor = UIColor.green
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
        
        
        self.friendsListTableView.deselectRow(at: indexPath, animated: false)
    }
    
}


//
//  RouteDetailsTableViewController.swift
//  FloripaBus
//
//  Created by Guilherme Steinmann on 10/4/15.
//  Copyright © 2015 Guilherme Steinmann. All rights reserved.
//

import UIKit

class RouteDetailsTableViewController: UITableViewController {
    
    var routeStops = [RouteStop]()
    var routeDepaturesWeekdays = [RouteDeparture]()
    var routeDepaturesSaturday = [RouteDeparture]()
    var routeDepaturesSunday = [RouteDeparture]()
    
    var routeId = -1
    var routeLongName = ""

    @IBOutlet weak var routeSegment: UISegmentedControl!
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        self.tableView.performSelectorOnMainThread(Selector("reloadData"), withObject: nil, waitUntilDone: true)
    }
    
    func setStops(stops: NSArray) {
        for stop in stops {
            if let stopId = stop["id"] as? Int, let stopName = stop["name"] as? String, let stopSequence = stop["sequence"] as? Int {
                let newStop = RouteStop(stopId: stopId, stopName: stopName, stopSequence: stopSequence)
                self.routeStops.append(newStop)
            }
        }
        self.tableView.performSelectorOnMainThread(Selector("reloadData"), withObject: nil, waitUntilDone: true)
    }
    
    func setDepartures(departures: NSArray) {
        for departure in departures {
            if let departureId = departure["id"] as? Int, let departureCalendar = departure["calendar"] as? String, let departureTime = departure["time"] as? String {
                let newDeparture = RouteDeparture(departureId: departureId, departureCalendar: departureCalendar, departureTime: departureTime)
                switch departureCalendar {
                    case "WEEKDAY":
                        self.routeDepaturesWeekdays.append(newDeparture)
                    
                    case "SATURDAY":
                        self.routeDepaturesSaturday.append(newDeparture)
                    
                    case "SUNDAY":
                        self.routeDepaturesSunday.append(newDeparture)
                    
                    default:
                        continue
                }
            }
        }
        self.tableView.performSelectorOnMainThread(Selector("reloadData"), withObject: nil, waitUntilDone: true)
    }
    
    func loadDetails(destinationURL: String, routeId: Int){
        let jsonRoute: [String : AnyObject] = [
            "params" : [ "routeId" : routeId ]
        ]
        
        let url = NSURL(string: destinationURL)
        let request = NSMutableURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("staging", forHTTPHeaderField: "X-AppGlu-Environment")
        
        let PasswordData = ("\(kUsername):\(kPassword)").dataUsingEncoding(NSUTF8StringEncoding)
        let base64Credential = PasswordData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        request.setValue("Basic \(base64Credential)", forHTTPHeaderField: "Authorization")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonRoute, options: [])
        } catch {
            print("NSJSONSerialization Error")
            return
        }
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            do {
                let responseJsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                if let responseDictionary = responseJsonData as? NSDictionary {
                    if let items = responseDictionary["rows"] as? NSArray {
                        if destinationURL == kStopsUrl {
                            self.setStops(items)
                        }
                        else if destinationURL == kDeparturesUrl {
                            self.setDepartures(items)
                        }
                    }
                }
                
            } catch {
                print("NSJSONSerialization Error")
            }
        })
        
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.routeLongName
        loadDetails(kStopsUrl, routeId: self.routeId)
        loadDetails(kDeparturesUrl, routeId: self.routeId)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch routeSegment.selectedSegmentIndex {
            case 0: // Streets
                return self.routeStops.count
                
            case 1: // Weekdays
                return self.routeDepaturesWeekdays.count
                
            case 2: // Saturday
                return self.routeDepaturesSaturday.count
                
            case 3: // Sunday
                return self.routeDepaturesSunday.count
                
            default: return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch routeSegment.selectedSegmentIndex {
            case 0: // Streets
                let cell = self.tableView.dequeueReusableCellWithIdentifier("RouteDetailsCell", forIndexPath: indexPath) as UITableViewCell
                let route = self.routeStops[indexPath.row]
                cell.textLabel!.text = route.stopName
                return cell
            
            case 1:
                let cell = self.tableView.dequeueReusableCellWithIdentifier("RouteDetailsCell", forIndexPath: indexPath) as UITableViewCell
                let route = self.routeDepaturesWeekdays[indexPath.row]
                cell.textLabel!.text = route.departureTime
                return cell
            
            case 2:
                let cell = self.tableView.dequeueReusableCellWithIdentifier("RouteDetailsCell", forIndexPath: indexPath) as UITableViewCell
                let route = self.routeDepaturesSaturday[indexPath.row]
                cell.textLabel!.text = route.departureTime
                return cell
                
            case 3:
                let cell = self.tableView.dequeueReusableCellWithIdentifier("RouteDetailsCell", forIndexPath: indexPath) as UITableViewCell
                let route = self.routeDepaturesSunday[indexPath.row]
                cell.textLabel!.text = route.departureTime
                return cell
            
            default:
                return self.tableView.dequeueReusableCellWithIdentifier("RouteCell", forIndexPath: indexPath) as UITableViewCell
        }
    }

}

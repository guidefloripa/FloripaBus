//
//  RouteTableViewController.swift
//  FloripaBus
//
//  Created by Guilherme Steinmann on 10/4/15.
//  Copyright © 2015 Guilherme Steinmann. All rights reserved.
//

import UIKit

class RouteTableViewController: UITableViewController, UISearchBarDelegate {
    
    var routes = [Route]()

    @IBOutlet weak var routeSearch: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.routeSearch.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.routes = [Route]()
        
        let stopName = "%" + searchBar.text! + "%"
        let jsonRoute: [String : AnyObject] = [
            "params" : [ "stopName" : stopName ]
        ]
        
        let url = NSURL(string: kRoutesUrl)
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
                        for item in items {
                            if let itemLongName = item["longName"] as? String {
                                if let itemId = item["id"] as? Int {
                                    let route = Route(longName: itemLongName, routeId: itemId)
                                    self.routes.append(route)
                                }
                            }
                        }
                        self.tableView.performSelectorOnMainThread(Selector("reloadData"), withObject: nil, waitUntilDone: true)
                    }
                }
                
            } catch {
                 print("NSJSONSerialization Error")
            }
        })
        
        task.resume()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.routes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("RouteCell", forIndexPath: indexPath) as UITableViewCell
        
        let route = self.routes[indexPath.row]
        cell.textLabel!.text = route.routeLongName
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "routeDetailsSegue" {
            if let detailsController = segue.destinationViewController as? RouteDetailsTableViewController {
                let selectedIndex = self.tableView.indexPathForCell(sender as! UITableViewCell)!.row
                detailsController.routeId = self.routes[selectedIndex].routeId
                detailsController.routeLongName = self.routes[selectedIndex].routeLongName!
            }
        }
    }

}

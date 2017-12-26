//
//  ShowTableViewController.swift
//  ShowTracker
//
//  Created by Charmi Patel on 12/16/17.
//  Copyright © 2017 Charmi Patel. All rights reserved.
//

import UIKit
import os.log

class ShowTableViewController: UITableViewController {

    // MARK: Properties
    
    var dateFormatter = DateFormatter()
    var shows = [Show]()
    
    private func setDateFormatter() {
        dateFormatter.dateStyle = .medium
    }
    
    private func createShows() {
        let show1 = Show(artist: "Loud Luxury", date: dateFormatter.date(from: "Jun 2, 2014")!, location: "Soundcheck", rating: 5)
        let show2 = Show(artist: "Chris Lake", date: dateFormatter.date(from: "Oct 20, 2017")!, location: "U Street Music Hall", rating: 3)
        let show3 = Show(artist: "Seven Lions", date: dateFormatter.date(from: "Dec 8, 2017")!, location: "Echostage", rating: 4)
        
        shows.append(show1!)
        shows.append(show2!)
        shows.append(show3!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDateFormatter()
        createShows()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shows.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ShowTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ShowTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ShowTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let show = shows[indexPath.row]
        
        cell.artistLabel.text = show.artist
        cell.locationLabel.text = show.location
        cell.dateLabel.text = dateFormatter.string(from: show.date)
        cell.ratingControl.rating = show.rating
        
        return cell
        
    }
    
    // MARK: Actions
    @IBAction func unwindToShowList(sender: UIStoryboardSegue) {
        
        // TODO: maintain list in order of date
        
        if let sourceViewController = sender.source as? ShowViewController, let show = sourceViewController.show {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Edit an existing show.
                shows[selectedIndexPath.row] = show
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                // Add a new show.
                let newIndexPath = IndexPath(row: shows.count, section: 0)
                
                shows.append(show)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
        }
        
        
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "AddItem":
            os_log("Adding a new show.", log: OSLog.default, type: .debug)
        
        case "ShowDetail":
            os_log("Viewing the details of a show.", log: OSLog.default, type: .debug)
            
            // change details
            guard let showDetailViewController = segue.destination as? ShowViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedShowCell = sender as? ShowTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedShowCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedShow = shows[indexPath.row]
            showDetailViewController.show = selectedShow
        
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
            
        }
    }

}

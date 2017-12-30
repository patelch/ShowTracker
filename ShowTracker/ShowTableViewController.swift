//
//  ShowTableViewController.swift
//  ShowTracker
//
//  Created by Charmi Patel on 12/16/17.
//  Copyright © 2017 Charmi Patel. All rights reserved.
//

import UIKit
import os.log
import GooglePlaces

class ShowTableViewController: UITableViewController {

    // MARK: Properties
    
    var dateFormatter = DateFormatter()
    var shows = [Show]()
    
    // MARK: Private Methods
    private func setDateFormatter() {
        dateFormatter.dateStyle = .medium
    }
    
    private func createShows() {
        
//        let show1 = Show(artists: ["Loud Luxury", "Throttle"], startDate: dateFormatter.date(from:"Feb 11, 2017")!, endDate: dateFormatter.date(from:"Feb 12, 2017")!, location: nil, isFestival: false, festivalName: nil, rating: 5)
//        let show2 = Show(artists: ["Chris Lake"], startDate: dateFormatter.date(from:"Feb 11, 2017")!, endDate: dateFormatter.date(from:"Feb 12, 2017")!, location: nil, isFestival: false, festivalName: nil, rating: 3)
//        let show3 = Show(artists: ["Seven Lions"], startDate: dateFormatter.date(from:"Feb 11, 2017")!, endDate: dateFormatter.date(from:"Feb 12, 2017")!, location: nil, isFestival: false, festivalName: nil, rating: 3)
//
//        shows.append(show1!)
//        shows.append(show2!)
//        shows.append(show3!)
    }
    
    private func saveShows() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(shows, toFile: Show.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Shows successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save shows...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadShows() -> [Show]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Show.ArchiveURL.path) as? [Show]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDateFormatter()
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        // Load any saved shows, otherwise load sample data.
        if let savedShows = loadShows() {
            shows += savedShows
        } else {
            createShows()
        }
        

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
        
        // Fetches the appropriate show for the data source layout.
        let show = shows[indexPath.row]
        
        if show.isFestival {
            cell.titleLabel.text = show.festivalName
        } else {
            cell.titleLabel.text = show.artists.first
            
            if show.artists.count == 1 {
                cell.titleLabel.text = show.artists.first
            } else if show.artists.count == 2 {
                cell.titleLabel.text = "\(show.artists[0]), \(show.artists[1])"
            } else {
                cell.titleLabel.text = "\(show.artists[0]), \(show.artists[1]), etc."
            }
        }
        //cell.locationLabel.text = show.location.name
        cell.dateLabel.text = dateFormatter.string(from: show.startDate)
        cell.ratingControl.rating = show.rating
        
        return cell
        
    }
    
    // MARK: Actions
    
    @IBAction func unwindToShowList(sender: UIStoryboardSegue) {
        
        // TODO: maintain list in order of date
        
        if let sourceViewController = sender.source as? CreateShowTableViewController, let show = sourceViewController.show {
            
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
        
        saveShows()
        
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            shows.remove(at: indexPath.row)
            saveShows()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

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
            guard let showDetailViewController = segue.destination as? CreateShowTableViewController else {
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

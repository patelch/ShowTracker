//
//  ShowViewController.swift
//  ShowTracker
//
//  Created by Charmi Patel on 12/16/17.
//  Copyright © 2017 Charmi Patel. All rights reserved.
//

import UIKit
import os.log

class ShowViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate {

    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var artistField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var ratingField: RatingControl!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: Properties
    var show: Show?
    
    var artistName = String()
    var location = String()

    // The date fields that will hold the current date value and the formatter
    var date = Date()
    var dateFormatter = DateFormatter()
    
    // The indexPath when the UIDatePicker is open
    let datePickerTag = 1
    var datePickerIndexPath: IndexPath?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dateFormatter.dateStyle = .medium
        
        tableView.delegate = self
        tableView.dataSource = self
        
        artistField.delegate = self
        locationField.delegate = self
        
        updateSaveButtonState()
        
        // TODO: configure times?
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    func calculateDatePickerIndexPath(_ indexPathSelected: IndexPath) -> IndexPath {
        if datePickerIndexPath != nil && (datePickerIndexPath! as NSIndexPath).row  < (indexPathSelected as NSIndexPath).row {
            return IndexPath(row: (indexPathSelected as NSIndexPath).row, section: 0)
        } else {
            return IndexPath(row: (indexPathSelected as NSIndexPath).row + 1, section: 0)
        }
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        if datePickerIndexPath != nil && (datePickerIndexPath! as NSIndexPath).row - 1 == (indexPath as NSIndexPath).row {
            let cell = tableView.cellForRow(at: datePickerIndexPath!)
            let datePicker = cell!.viewWithTag(datePickerTag) as! UIDatePicker
            date = datePicker.date
            tableView.deleteRows(at: [datePickerIndexPath!], with: .fade)
            datePickerIndexPath = nil
        } else {
            datePickerIndexPath = calculateDatePickerIndexPath(indexPath)
            tableView.insertRows(at: [datePickerIndexPath!], with: .fade)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.endUpdates()
        
        // Required in this case for correct contentSize
        tableView.reloadData()
        
        // Set the height of tableView to match its content size height
        // Constraint is an easy way to do it versus adding up row heights
        tableViewHeightConstraint.constant = tableView.contentSize.height
    }
    
    // Estimate the rowHeight
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight = 50
        if datePickerIndexPath != nil && datePickerIndexPath!.row == indexPath.row {
            let cell = tableView.dequeueReusableCell(withIdentifier: "datePickerCell")!
            rowHeight = Int(Double(cell.frame.height))
        }
        return CGFloat(rowHeight)
    }
    
    // Automatic height or date picker height from storyboard
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight = UITableViewAutomaticDimension
        if datePickerIndexPath != nil && datePickerIndexPath!.row == indexPath.row {
            let cell = tableView.dequeueReusableCell(withIdentifier: "datePickerCell")!
            rowHeight = cell.frame.height
        }
        return rowHeight
    }
    
    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 1
        if datePickerIndexPath != nil {
            // Add one row to the field count since date picker is open
            rows += 1
        }
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if datePickerIndexPath != nil && (datePickerIndexPath! as NSIndexPath).row == (indexPath as NSIndexPath).row {
            // Date picker open and this cell index is the datePickerIndexPath
            cell = tableView.dequeueReusableCell(withIdentifier: "datePickerCell")!
            let datePicker = cell.viewWithTag(datePickerTag) as! UIDatePicker
            // Since we have a date picker, the index of dateField is one less
            datePicker.setDate(date, animated: true)
        } else {
            // This cell isn't a date picker, so it is a dateCell
            cell = tableView.dequeueReusableCell(withIdentifier: "dateCell")!
            cell.detailTextLabel?.text = dateFormatter.string(from: date)
        }
        
        return cell
    }
    
    // Determines if the UITableView has a UIDatePicker in any of its cells.
    func hasInlineDatePicker() -> Bool {
        return datePickerIndexPath != nil
    }
    
    //Determines if the given indexPath points to a UIDatePicker cell
    func indexPathHasPicker(_ indexPath: IndexPath) -> Bool {
        return hasInlineDatePicker() && (datePickerIndexPath as NSIndexPath?)?.row == (indexPath as NSIndexPath).row
    }
    
    
    // MARK: Navigation
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let artist = artistField.text ?? ""
        let location = locationField.text ?? ""
        let rating = ratingField.rating
        
        show = Show(artist: artist, date: date, location: location, rating: rating)
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        
    }
    
    // MARK: Private Methods
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let artistText = artistField.text ?? ""
        let locationText = locationField.text ?? ""
        saveButton.isEnabled = !artistText.isEmpty && !locationText.isEmpty
    }


     /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

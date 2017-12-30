//
//  CreateShowTableViewController.swift
//  ShowTracker
//
//  Created by Charmi Patel on 12/26/17.
//  Copyright © 2017 Charmi Patel. All rights reserved.
//

import UIKit
import GooglePlaces
import os.log


class CreateShowTableViewController: UITableViewController {
    
    // MARK: Types
    struct CustomCellNames {
        static let artistAddCell = "ArtistAddTableViewCell"
        static let artistEntryCell = "ArtistEntryTableViewCell"
        static let dateLabelCell = "DateLabelTableViewCell"
        static let datePickerCell = "DatePickerTableViewCell"
        static let emptyLocationCell = "EmptyLocationTableViewCell"
        static let filledLocationCell = "FilledLocationTableViewCell"
        static let festivalCell = "FestivalTableViewCell"
        static let ratingCell = "RatingTableViewCell"
    }
    
    // MARK: Constants
    enum SectionName {
        case artists, date, otherInformation, rating
    }
    
    var tableSections = [SectionName: Int]()
    var customCellNamesToIdentifiers = [String: String]()
    
    let artistEntryTag = 0
    let festivalNameTag = 1
    let maxArtists = 30
    
    // MARK: Properties
    
    private var startDateCellExpanded = false
    private var endDateCellExpanded = false
    private var invalidDate = false
    
    private var dateFormatter = DateFormatter()
    
    private var startDate = Date()
    private var endDate = Date()
    
    private var artists = [String]()
    private var artistCount = 0
    
    private var location: GMSPlace?
    private var isFestival = false
    private var festivalName = String()
    
    private var rating = 0
    
    var show: Show?
    
    // MARK: Outlets
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add table section name to index mapping
        tableSections = [.artists: 0, .date: 1, .otherInformation: 2, .rating: 3]
        
        customCellNamesToIdentifiers = ["ArtistAddTableViewCell" : "artistAddCell", "ArtistEntryTableViewCell" : "artistEntryCell", "EmptyLocationTableViewCell" : "emptyLocationCell", "FilledLocationTableViewCell" : "filledLocationCell", "FestivalTableViewCell" : "festivalCell", "DateLabelTableViewCell" : "dateLabelCell", "DatePickerTableViewCell" : "datePickerCell", "RatingTableViewCell" : "ratingCell"]
        
        
        // register nibs
        for (cellName, cellIdentifier) in customCellNamesToIdentifiers {
            tableView.register(UINib(nibName: cellName, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        }
        
        // scrolling fields
        tableView.tableFooterView = UIView()
        tableView.alwaysBounceVertical = false
        tableView.bounces = false
        
        // date
        dateFormatter.dateStyle = .medium
        
        // Set up views if editing an existing Show.
        if let show = show {
            artists = show.artists
            artistCount = artists.count
            startDate = show.startDate
            endDate = show.endDate
            location = show.location
            isFestival = show.isFestival
            if isFestival {
                festivalName = show.festivalName!
            }
            rating = show.rating
        }
        
        updateSaveButtonState()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Datepicker Methods
    @objc func datePickerChanged(datePicker: UIDatePicker) {
        if datePicker.tag == 0 { // start datepicker
            startDate = datePicker.date
        } else { // end datepicker
            endDate = datePicker.date
        }
        
        invalidDate = startDate > endDate
        
        // reload date
        let indexSet = NSIndexSet(index: tableSections[.date]!) as IndexSet
        tableView.reloadSections(indexSet, with: .automatic)
        updateSaveButtonState()
        
    }
    
    // MARK: Festival Switch Methods
    @objc func festivalSwitchChanged(festivalSwitch: UISwitch) {
        isFestival = festivalSwitch.isOn
        
        // reload other information
        let indexSet = NSIndexSet(index: tableSections[.otherInformation]!) as IndexSet
        tableView.reloadSections(indexSet, with: .automatic)
    }
    
    
    // MARK: Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == tableSections[.artists] {
            return artistCount + 1
        } else if section == tableSections[.date] {
            return (startDateCellExpanded || endDateCellExpanded ? 3 : 2)
        } else if section == tableSections[.otherInformation] {
            return 2
        } else {
            return 1
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // date section
        if indexPath.section == tableSections[.date] {
            
            tableView.beginUpdates()
            if (indexPath.row == 0) {
                // start date
                startDateCellExpanded = startDateCellExpanded ? false : true
                if startDateCellExpanded {
                    
                    // only one date picker can be open at a time
                    // if the end datepicker is open, close it
                    if endDateCellExpanded {
                        tableView.deleteRows(at: [NSIndexPath(row: indexPath.row + 2, section: indexPath.section) as IndexPath], with: .fade)
                        endDateCellExpanded = false
                    }
                    
                    tableView.insertRows(at: [NSIndexPath(row: indexPath.row + 1, section: indexPath.section) as IndexPath], with: .fade)
                } else {
                    tableView.deleteRows(at: [NSIndexPath(row: indexPath.row + 1, section: indexPath.section) as IndexPath], with: .fade)
                }
            } else if (indexPath.row == 1 && !startDateCellExpanded) {
                // end date
                endDateCellExpanded = endDateCellExpanded ? false : true
                if endDateCellExpanded {
                    tableView.insertRows(at: [NSIndexPath(row: indexPath.row + 1, section: indexPath.section) as IndexPath], with: .fade)
                } else {
                    tableView.deleteRows(at: [NSIndexPath(row: indexPath.row + 1, section: indexPath.section) as IndexPath], with: .fade)
                }
            } else if (indexPath.row == 2 && startDateCellExpanded) {
                // end date
                endDateCellExpanded = endDateCellExpanded ? false : true
                if endDateCellExpanded {
                    
                    // only one date picker can be open at a time
                    // since the start datepicker is open, close it
                    startDateCellExpanded = false
                    
                } else {
                    tableView.deleteRows(at: [NSIndexPath(row: indexPath.row + 1, section: indexPath.section) as IndexPath], with: .fade)
                }
            } else {
                // TODO: something?
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.endUpdates()
            
            // reload date
            let indexSet = NSIndexSet(index: tableSections[.date]!) as IndexSet
            tableView.reloadSections(indexSet, with: .fade)
        }
        
        
        // artist section -- add new artist
        if indexPath.section == tableSections[.artists] && indexPath.row == artistCount {
            
            // add new cell to table
            tableView.beginUpdates()
            tableView.insertRows(at: [NSIndexPath(row: artistCount, section: indexPath.section) as IndexPath], with: .fade)
            artistCount += 1
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.endUpdates()
            
            // reload artists
            let indexSet = NSIndexSet(index: tableSections[.artists]!) as IndexSet
            tableView.reloadSections(indexSet, with: .fade)
            
        }
        
        // other information section
        if indexPath.section == tableSections[.otherInformation] && indexPath.row == 0 {
            // location
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            present(autocompleteController, animated: true, completion: nil)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // date section
        if indexPath.section == tableSections[.date] {
            if (indexPath.row == 1 && startDateCellExpanded) || (indexPath.row == 2 && endDateCellExpanded) {
                return 200
            }
        }
        
        return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // MARK: Artist Cell
        if indexPath.section == tableSections[.artists] {
            if indexPath.row == artistCount {
                let cell = tableView.dequeueReusableCell(withIdentifier: "artistAddCell", for: indexPath) as! ArtistAddTableViewCell
                
                if artistCount != artists.count || artistCount == maxArtists {
                    cell.selectionStyle = .none
                    cell.isUserInteractionEnabled = false
                    cell.addArtistButton.isEnabled = false
                    cell.addArtistLabel.isEnabled = false
                } else {
                    cell.selectionStyle = .default
                    cell.isUserInteractionEnabled = true
                    cell.addArtistButton.isEnabled = true
                    cell.addArtistLabel.isEnabled = true
                }
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "artistEntryCell", for: indexPath) as! ArtistEntryTableViewCell
                
                // configure cell
                cell.editArtistField.delegate = self
                cell.editArtistField.tag = artistEntryTag
                
                if (indexPath.row < artists.count) {
                    cell.editArtistField.text = artists[indexPath.row]
                } else {
                    cell.editArtistField.text = ""
                }
                
                return cell
                
            }
        }
            
            // MARK: Other Information Cell
        else if indexPath.section == tableSections[.otherInformation] {
            if indexPath.row == 0 {
                if location == nil {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "emptyLocationCell", for: indexPath) as! EmptyLocationTableViewCell
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "filledLocationCell", for: indexPath) as! FilledLocationTableViewCell
                    cell.titleLabel.text = location!.name
                    cell.subtitleLabel.text = location!.formattedAddress
                    return cell
                }
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "festivalCell", for: indexPath) as! FestivalTableViewCell
                
                cell.selectionStyle = .none
                
                cell.isFestivalSwitch.setOn(isFestival, animated: true)
                if isFestival {
                    cell.festivalNameField.isEnabled = true
                    cell.festivalNameField.delegate = self
                    cell.festivalNameField.tag = festivalNameTag
                } else {
                    cell.festivalNameField.isEnabled = false
                    let festivalSwitch = cell.isFestivalSwitch
                    festivalSwitch?.addTarget(self, action: #selector(festivalSwitchChanged(festivalSwitch:)), for: .valueChanged)
                }
                
                return cell
            }
        }
            
            // MARK: Date Cell
        else if indexPath.section == tableSections[.date] {
            
            // first cell is the header for the start date
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "dateLabelCell", for: indexPath) as! DateLabelTableViewCell
                
                // configure cell
                cell.titleLabel.text = "Start"
                cell.detailLabel.attributedText = nil
                cell.detailLabel.text = dateFormatter.string(from: startDate)
                cell.detailLabel.textColor = .black
                
                return cell
            }
            
            // second cell can be the datepicker field for the start date or the header for the end date
            if indexPath.row == 1 {
                
                if startDateCellExpanded {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "datePickerCell", for: indexPath) as! DatePickerTableViewCell
                    
                    let datePicker = cell.datePicker!
                    datePicker.tag = 0 // tag represents start date picker
                    datePicker.addTarget(self, action: #selector(datePickerChanged(datePicker:)), for: .valueChanged)
                    datePicker.setDate(startDate, animated: false)
                    
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "dateLabelCell", for: indexPath) as! DateLabelTableViewCell
                    
                    // configure cell
                    cell.titleLabel.text = "End"
                    cell.detailLabel.attributedText = nil
                    cell.detailLabel.text = dateFormatter.string(from: endDate)
                    
                    if invalidDate {
                        cell.detailLabel.textColor = .red
                        
                        let attributeString = NSAttributedString(string: dateFormatter.string(from: startDate), attributes: [NSAttributedStringKey.strikethroughStyle : NSUnderlineStyle.styleSingle.rawValue])
                        
                        cell.detailLabel.attributedText = attributeString
                    } else {
                        cell.detailLabel.textColor = .black
                    }
                    
                    return cell
                }
            }
            
            // third cell can be the header for the end date or the datepicker field for the end date
            if indexPath.row == 2 {
                
                if endDateCellExpanded {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "datePickerCell", for: indexPath) as! DatePickerTableViewCell
                    
                    let datePicker = cell.datePicker!
                    datePicker.tag = 1 // tag represents end date picker
                    datePicker.addTarget(self, action: #selector(datePickerChanged(datePicker:)), for: .valueChanged)
                    datePicker.setDate(endDate, animated: false)
                    
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "dateLabelCell", for: indexPath) as! DateLabelTableViewCell
                    
                    // configure cell
                    cell.titleLabel.text = "End"
                    cell.detailLabel.attributedText = nil
                    cell.detailLabel.text = dateFormatter.string(from: endDate)
                    
                    if invalidDate {
                        cell.detailLabel.textColor = .red
                        
                        let attributeString = NSAttributedString(string: dateFormatter.string(from: startDate), attributes: [NSAttributedStringKey.strikethroughStyle : NSUnderlineStyle.styleSingle.rawValue])
                        
                        cell.detailLabel.attributedText = attributeString
                    } else {
                        cell.detailLabel.textColor = .black
                    }
                    
                    return cell
                }
                
            }
            return UITableViewCell()
        }
            
            // MARK: Rating Cell
        else if indexPath.section == tableSections[.rating] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ratingCell", for: indexPath) as! RatingTableViewCell
            
            cell.ratingControl.rating = rating
            cell.ratingControl.ratingDidChangeClosure = {
                // reload rating
                self.rating = cell.ratingControl.rating
            }
            
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
    
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.section == tableSections[.artists] && indexPath.row != artistCount {
            return true
        } else {
            return false
        }

     }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            artists.remove(at: indexPath.row)
            artistCount -= 1
            tableView.deleteRows(at: [indexPath], with: .fade)
            updateSaveButtonState()
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
    
    
    // MARK: - Navigation
    
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {

        let isPresentingInAddShowMode = presentingViewController is UINavigationController
        
        if isPresentingInAddShowMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The MealViewController is not inside a navigation controller.")
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        show = Show(artists: artists, startDate: startDate, endDate: endDate, location: location!, isFestival: isFestival, festivalName: festivalName, rating: rating)
        
    }
    
    // MARK: Private Methods
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let validArtists = artists.count > 0 && artists.count == artistCount
        let validDate = startDate <= endDate
        let validLocation = location != nil
        saveButton.isEnabled = validArtists && validDate && validLocation
    }
}


extension CreateShowTableViewController: UITextFieldDelegate {
    
    // MARK: UITextField Delegate
    
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
        
        if textField.tag == artistEntryTag {
            artists.append(textField.text!)
            
            // reload artist list
            let indexSet = NSIndexSet(index: tableSections[.artists]!) as IndexSet
            tableView.reloadSections(indexSet, with: .automatic)
        } else {
            festivalName = textField.text!
            
            // reload other information section
            let indexSet = NSIndexSet(index: tableSections[.otherInformation]!) as IndexSet
            tableView.reloadSections(indexSet, with: .automatic)
        }
        
        updateSaveButtonState()
    }
}

extension CreateShowTableViewController: GMSAutocompleteViewControllerDelegate {
    
    // MARK: Location Autocomplete Delegate
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        location = place
        updateSaveButtonState()
        
        // reload other information
        let indexSet = NSIndexSet(index: tableSections[.otherInformation]!) as IndexSet
        tableView.reloadSections(indexSet, with: .fade)
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}


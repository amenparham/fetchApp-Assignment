//
//  ViewController.swift
//  fetch
//
//  Created by Amen Parham on 4/21/21.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet var tableView: UITableView!
    
    var dataSource: [TableModel] = []
    var updatedCell = TableViewCell()
    var updatedIndex = Int()
    var finishedLoading: Bool = false
    @IBOutlet var loadingTxt: UILabel!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet var searchBar: UISearchBar!
    var searching: Bool = false
    
    var searchFilter: [(
        eventTitle_Filtered:String,
        eventLocation_Filtered: String,
        eventImageLink_Filtered: String,
        eventID_Filtered:Int,
        eventName_Filtered:String,
        eventType_Filtered:String,
        imagesLoaded_Filtered:UIImage
    )] = []
    
    var all: [(
        eventTitle_Filtered:String,
        eventLocation_Filtered: String,
        eventImageLink_Filtered: String,
        eventID_Filtered:Int,
        eventName_Filtered:String,
        eventType_Filtered:String,
        imagesLoaded_Filtered:UIImage
    )] = []
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.separatorStyle = .none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchBar.delegate = self
        if let savedDataKey = UserDefaults.standard.array(forKey: "savedDataKey") as? [String]  {
            IDArray = savedDataKey
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        // Call func for JSON Parsing
        parseJSON {
            print("Successful")
            self.dataSource = Array(repeating: TableModel(isLiked: false), count: self.all.count)
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.reloadData()
        }
    }
    
    func parseJSON(completed: @escaping() -> ()) {
        // Create URL Obect
        if let url = URL(string:"https://api.seatgeek.com/2/events?client_id=MjE3NTI2Nzd8MTYxOTAzMDM0Mi4zNTY5NzI1") {
            
            // Begin Retrieve JSON Data
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    // Initialize JSONDecoder
                    let jsonDecoder = JSONDecoder()
                        do {
                            // Begin Parse JSON
                            let parsedJSON = try jsonDecoder.decode(Entry.self, from: data)
                            
                            // for loop to cycle through all Entry’s dictionary data received
                            for entryData in parsedJSON.events {
                                let imageLinkValue = entryData.performers.first!.image
                                let eventIDValue = entryData.id
                                let eventTitleValue = entryData.performers.first!.short_name!
                                let eventLocationValue = entryData.venue.display_location
                                let eventNameValue = entryData.venue.name
                                let eventTypeValue = entryData.type
                                let imageUrl = URL(string: entryData.performers.first!.image!)!
                                let imageData = try! Data(contentsOf: imageUrl)
                                let image = UIImage(data: imageData)
                                let imagesLoadedValue = image!
                                
//- /performers/{PERFORMER_ID} var (for future use) //
                                // let performersID_Value = entryData.performers.first!.id
                                // performersID_Value
                                       
//- /venues/{VENUE_ID} var (for future use)//
                                // let venuesID_Value = entryData.venue.id
                                // venuesID_Value
                                
                                allTitles.append(eventTitleValue)
                                self.all += [(eventTitle_Filtered:eventTitleValue,
                                              eventLocation_Filtered:"\(eventLocationValue!)",
                                              eventImageLink_Filtered: "\(String(imageLinkValue!))",
                                              eventID_Filtered: eventIDValue,
                                              eventName_Filtered: "\(eventNameValue!)",
                                              eventType_Filtered: "\(String(eventTypeValue!))",
                                              imagesLoaded_Filtered: imagesLoadedValue)]
                            }
                                DispatchQueue.main.async {
                                    completed()
                                }
                        } catch {
                            print(error)
                        }
                }
           }.resume()
        }
    }
    
    @IBAction func buttonSelected(_ sender: Any) {
        // Update Cell for which UIButton (Like Button) was tapped.
        dataSource[(sender as AnyObject).tag].isLiked = !dataSource[(sender as AnyObject).tag].isLiked
        let indexPath = IndexPath(row: (sender as AnyObject).tag, section: 0)
        let newIndex = (sender as AnyObject).tag!
        let isLiked = dataSource[newIndex].isLiked
        
        if (isLiked == true) {
            // Add To IDArray
            if (searching == true) {
                IDArray.append(String(searchFilter[indexPath.row].eventID_Filtered))
            } else {
                // Not Searching
                IDArray.append(String(all[indexPath.row].eventID_Filtered))
            }
        } else {
            // Remove From IDArray
            if (searching == true) {
                IDArray = IDArray.filter{$0 != "\(searchFilter[indexPath.row].eventID_Filtered)"}
            } else {
                // Not Searching
                if (IDArray.contains(String(all[indexPath.row].eventID_Filtered))) {
                    IDArray = IDArray.filter{$0 != "\(all[indexPath.row].eventID_Filtered)"}
                }
            }
        }
        
        let defaults = UserDefaults.standard
        defaults.setValue(IDArray, forKey: "savedDataKey")
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Saved updatedCell & updatedIndex variables for delegate pattern. To Update this VC's cells data when edited on secondVC (moreInfoViewController) in a way, made them accessible outside this function
        // To Get Specific TableView Cell the user is interacting with.
        updatedCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        updatedIndex = indexPath.row
        
        // Go to Second VC and Send cell tapped data to next view
        let vc = (storyboard?.instantiateViewController(withIdentifier:  "secondVC") as? moreInfoViewController)!
        vc.delegate = self
        
        if (searching == true) {
            vc.currentID = "\(searchFilter[indexPath.row].eventID_Filtered)"
            vc.mainTitleTxt = "\(searchFilter[indexPath.row].eventTitle_Filtered)"
            vc.mainImageURL = "\(searchFilter[indexPath.row].eventImageLink_Filtered)"
            vc.mainLocationTxt = "\(searchFilter[indexPath.row].eventLocation_Filtered)"
            vc.mainNameTxt = "\(searchFilter[indexPath.row].eventName_Filtered)"
            let editedType_Txt = searchFilter[indexPath.row].eventType_Filtered.replacingOccurrences(of: "_", with: " ")
            vc.mainTypeTxt = "\(editedType_Txt)"
        } else {
            // Not Searching
            vc.currentID = "\(all[indexPath.row].eventID_Filtered)"
            vc.mainTitleTxt = "\(all[indexPath.row].eventTitle_Filtered)"
            vc.mainImageURL = "\(all[indexPath.row].eventImageLink_Filtered)"
            vc.mainLocationTxt = "\(all[indexPath.row].eventLocation_Filtered)"
            vc.mainNameTxt = "\(all[indexPath.row].eventName_Filtered)"
            let editedType_Txt = all[indexPath.row].eventType_Filtered.replacingOccurrences(of: "_", with: " ")
            vc.mainTypeTxt = "\(editedType_Txt)"
        }
        
        // Get Status of Liked Button in the cell the user tapped and display if the user liked it previously in the SecondVC
        let isLiked = dataSource[indexPath.row].isLiked
        if isLiked {
            // print("Liked")
            vc.isLiked = true
        } else {
            // print("Not Liked")
            vc.isLiked = false
        }
        
        searching = false
        searchThisIndex = true
        dismissKeyboard()
        searchBar.text = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [] in
            tableView.reloadData()
        }
        
        present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (searching == true) {
            return searchFilter.count
        } else {
            // Not Searching
            return all.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.likeBtn.tag = indexPath.row
        
        if (finishedLoading == false) {
            cell.moreBtn.tag = indexPath.row
        }
        
        if (searching == true) {
            cell.likeBtn.isHidden = true
            if (finishedLoading == true) {
                // Get Each Cell Liked Button Status and display if the user liked or not Liked each cell
                let isLiked = dataSource[indexPath.row].isLiked
                if isLiked {
                    // User liked the post
                    cell.likeBtn.setImage(UIImage(named: "liked"), for: UIControl.State.normal)
                } else {
                    // User Unliked the post
                    cell.likeBtn.setImage(UIImage(named: "unLiked"), for: UIControl.State.normal)
                }
            }
            
            // Populate each cell with JSON Data Received
            // Event Title Data
            cell.titleTxt?.text = "\(searchFilter[indexPath.row].eventTitle_Filtered)"
            // Event Location Data
            cell.locationTxt?.text = "- \(searchFilter[indexPath.row].eventLocation_Filtered)"
            // Event Image URL Data
            cell.mainImage?.image = searchFilter[indexPath.row].imagesLoaded_Filtered
        } else {
            // Not Searching
            cell.likeBtn.isHidden = false
            if (finishedLoading == false && IDArray.contains(String(all[indexPath.row].eventID_Filtered))) {
                // print("Post Already Liked")
                dataSource[indexPath.row].isLiked = true
                cell.likeBtn.setImage(UIImage(named: "liked"), for: UIControl.State.normal)
            }
            if (finishedLoading == true) {
                // Get Each Cell Liked Button Status and display if the user liked or not Liked each cell
                let isLiked = dataSource[indexPath.row].isLiked
                if isLiked {
                    // User liked the post
                    cell.likeBtn.setImage(UIImage(named: "liked"), for: UIControl.State.normal)
                } else {
                    // User Unliked the post
                    cell.likeBtn.setImage(UIImage(named: "unLiked"), for: UIControl.State.normal)
                }
            }
            
            // Populate each cell with JSON Data Received
            // Event Title Data
            cell.titleTxt?.text = "\(all[indexPath.row].eventTitle_Filtered)"
            // Event Location Data
            cell.locationTxt?.text = "- \(all[indexPath.row].eventLocation_Filtered)"
            // Event Image URL Data
            cell.mainImage?.image = all[indexPath.row].imagesLoaded_Filtered
        }
        
        if indexPath.row == all.count-1 {
            finishedLoading = true
            loadingTxt.isHidden = true
            searchBar.isHidden = false
            loadingIndicator.stopAnimating()
            loadingIndicator.isHidden = true
            
            UIView.animate(withDuration: 0.6) {
                self.searchBar.alpha = 1.0
            }
        }
        
        cell.titleTxt?.numberOfLines = 1
        cell.titleTxt?.adjustsFontSizeToFitWidth = true
        cell.locationTxt?.numberOfLines = 1
        cell.locationTxt?.adjustsFontSizeToFitWidth = true
        cell.mainImage.layer.borderColor = UIColor.black.cgColor
        cell.mainImage.layer.borderWidth = 1.5
        cell.mainImage.layer.cornerRadius = 10
        
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Return searchFilter Data TableView Cells
        searchFilter = all.filter({ (data) -> Bool in
            let tmp: NSString = data.eventTitle_Filtered as NSString // the eventTitle_Filtered
            let range = tmp.range(of: searchText, options: .caseInsensitive)
            
            let tmp2: NSString = data.eventLocation_Filtered as NSString // the eventLocation_Filtered
            let range2 = tmp2.range(of: searchText, options: .caseInsensitive)
            
            let tmp3: NSString = data.eventType_Filtered as NSString // the eventType_Filtered
            let range3 = tmp3.range(of: searchText, options: .caseInsensitive)
            
            let tmp4: NSString = data.eventName_Filtered as NSString // the eventName_Filtered
            let range4 = tmp4.range(of: searchText, options: .caseInsensitive)
            
            return range.location != NSNotFound || range2.location != NSNotFound || range3.location != NSNotFound || range4.location != NSNotFound
        })
        
        if (searchBar.text._bridgeToObjectiveC().length >= 1) {
//            print("Character/s Added to TextField")
            searching = true
        } else if (searchBar.text._bridgeToObjectiveC().length <= 0) {
            print("TextField Now Empty")
            searching = false
            self.tableView.reloadData()
        }
        
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchActive = false
        hideKeyBoard()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideKeyBoard()
    }
    
    func hideKeyBoard(){
        searchBar.resignFirstResponder()
        dismissKeyboard()
    }
}

// Conform VC to protocol (VC2Delegate) located in "Structs.swift" - File
extension ViewController: VC2Delegate {
    func likeStatusDidChange(_ vc2: moreInfoViewController, to title: Bool) {
        // set the text of the table cell here...
        if (searchThisIndex == true) {
            print("Do Nothing")
            dataSource[cellRowNum].isLiked = !dataSource[cellRowNum].isLiked
            let indexPath = IndexPath(row: cellRowNum, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            dataSource[updatedIndex].isLiked = !dataSource[updatedIndex].isLiked
            let indexPath = IndexPath(row: updatedIndex, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

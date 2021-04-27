//
//  moreInfoViewController.swift
//  fetch
//
//  Created by Amen Parham on 4/22/21.
//

import UIKit

class moreInfoViewController: UIViewController {

    @IBOutlet var backBtn: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var theImage: UIImageView!
    @IBOutlet var mainlikeBtn: UIButton!
    @IBOutlet var mainTypeLbl: UILabel!
    @IBOutlet var mainNameLbl: UILabel!
    
    // Some Variables are used to pass Data between ViewControllers
    var mainTitleTxt:String = ""
    var mainImageURL:String = ""
    var mainLocationTxt:String = ""
    var currentID:String = ""
    var isLiked = Bool()
    var mainTypeTxt: String = ""
    var mainNameTxt: String = ""
    weak var delegate: VC2Delegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        styles()
        
        // mainImageURL from previous VC to populate ImageView with correct Image URL
        let imageUrl = URL(string: mainImageURL)
        let imageData = try! Data(contentsOf: imageUrl!)
        let image = UIImage(data: imageData)
        theImage?.image = image
        
        // Add Title Text and others
        titleLabel.text = mainTitleTxt
        
        // Find CellRowNum
        let indexOfTitle = allTitles.firstIndex(of: mainTitleTxt)
        cellRowNum = indexOfTitle!
        print("cellRowNum: \(cellRowNum)")
        
        locationLabel.text = "- \(mainLocationTxt)"
        mainTypeLbl.text = "\(mainTypeTxt.uppercased())"
        mainNameLbl.text = "\(mainNameTxt)"
//        mainNameLbl.text = "\(mainNameTxt)"
        
        // "isLiked" variable to display whether or user liked this event
        print(currentID)
        print(IDArray)
        if (IDArray.contains(currentID)) {
            // is Liked
            mainlikeBtn.setImage(UIImage(named: "liked"), for: UIControl.State.normal)
        }
    }
    
    // Heart/Like Button Action. User can like event in this VC with this button and it will tell the firstVC (ViewController) to update "Like Status" there also
    @IBAction func likeBtnAction(_ sender: Any) {
        if (isLiked == true || IDArray.contains(currentID)) {
            // is Liked
            isLiked = false
            IDArray = IDArray.filter{$0 != currentID}
            let defaults = UserDefaults.standard
            defaults.setValue(IDArray, forKey: "savedDataKey")
            mainlikeBtn.setImage(UIImage(named: "unLiked"), for: UIControl.State.normal)
        } else {
            isLiked = true
            IDArray.append(currentID)
            let defaults = UserDefaults.standard
            defaults.setValue(IDArray, forKey: "savedDataKey")
            mainlikeBtn.setImage(UIImage(named: "liked"), for: UIControl.State.normal)
        }
        // When User interacts with like Button, this function gets called that tells the firstVC (ViewController) to update as well.
        // likeStatusDidChange function is located at the bottom of the (ViewController) with extension ViewController.
        delegate?.likeStatusDidChange(self, to: true)
    }
    
    // Go Back To FirstVC (ViewController)
    @IBAction func previousVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        searchThisIndex = false
    }
    
    func styles() {
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        locationLabel.numberOfLines = 1
        locationLabel.adjustsFontSizeToFitWidth = true
        mainTypeLbl.numberOfLines = 1
        mainTypeLbl.adjustsFontSizeToFitWidth = true
        mainNameLbl.numberOfLines = 1
        mainNameLbl.adjustsFontSizeToFitWidth = true
        backBtn.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        theImage.layer.borderColor = UIColor.black.cgColor
        theImage.layer.borderWidth = 2
        theImage.layer.cornerRadius = 10
    }
}


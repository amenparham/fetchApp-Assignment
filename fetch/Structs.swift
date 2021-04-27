//
//  Structs.swift
//  FetchApp
//
//  Created by Amen Parham on 4/20/21.
//.

import Foundation

    var IDArray = [String]()
    let defaults = UserDefaults.standard
    var searchThisIndex: Bool = false
    var cellRowNum = Int()
    var allTitles = [String]()

    struct Entry: Codable {
        let events: [EventsData]
    }

    struct EventsData: Codable {
        let type: String?
        let id: Int
        let title: String?
        let venue: locationInfo
        let performers: [ImageLink]
    }

    struct ImageLink: Codable {
        let image: String?
        let short_name: String?
        let id: Int?
    }

    struct locationInfo: Codable {
        let display_location: String?
        let name: String?
        let id: Int?
    //    let state: String
    //    let name_v2: String
    }

    struct TableModel {
        var isLiked: Bool
    }

protocol VC2Delegate : class {
        func likeStatusDidChange(_ vc2: moreInfoViewController, to title: Bool)
    }

extension ViewController {
        @objc func dismissKeyboard() {
            view.endEditing(true)
        }
    }
    

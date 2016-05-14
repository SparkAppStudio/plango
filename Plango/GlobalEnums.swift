//
//  GlobalEnums.swift
//  DoItLive
//
//  Created by Douglas Hewitt on 3/3/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import Foundation

enum StoryboardID: String {
    case Main = "Main"
    case Utilities = "Utilities"
}

enum ViewControllerID: String {
    case Settings = "SettingsTableViewController"
    case Discover = "DiscoverTableViewController"
//    case Plans = "PlansTableViewController"
    case Login = "LoginTableViewController"
    case Search = "SearchViewController"
    case TripFriends = "TripFriendsViewController"
    case Report = "ReportViewController"
}

enum CellID: String {
    case Plans = "PlansTableViewCell"
    case PlanTypes = "PlanTypesTableViewCell"
    case TopCollections = "TopCollectionsTableViewCell"
    case SpecificType = "TypeCollectionViewCell"
}

enum Notify: String {
    case Login = "Login"
    case Logout = "Logout"
    case Timer = "Timer"
}

enum App: String {
    case Name = "Plango"
}

enum UserDefaultsKeys: String {
    case firstLoad = "firstLoad"
    case firstView = "firstView"
    case currentUser = "currentUser"
}


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
    case SideMenu = "SideMenuTableViewController"
    case HomeMenu = "HomeMenuTableViewController"
    case Plans = "PlansTableViewController"
    case Login = "LoginTableViewController"
    case Search = "SearchTableViewController"
    case TripFriends = "TripFriendsViewController"
}

enum CellID: String {
    case Plans = "PlansTableViewCell"
}

enum Notify: String {
    case Login = "Login"
    case Logout = "Logout"
}

enum App: String {
    case Name = "Plango"
}

enum UserDefaultsKeys: String {
    case firstLoad = "firstLoad"
    case firstView = "firstView"
}
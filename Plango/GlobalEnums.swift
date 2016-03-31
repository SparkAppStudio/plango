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
}

enum ViewControllerID: String {
    case NavFeed = "FeedNavController"
    case Feed = "FeedTableViewController"
    case Login = "LoginViewController"
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
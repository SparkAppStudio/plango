//
//  Extensions.swift
//  DoItLive
//
//  Created by Douglas Hewitt on 3/2/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import Photos
import MBProgressHUD
import Hue

extension UIBarButtonItem {
    func hide(sender: Bool) {
        self.enabled = !sender
        if sender == true {
            self.tintColor = UIColor.clearColor()
        } else {
            self.tintColor = UIColor.whiteColor()
        }
    }
}

extension UINavigationController {
    
    override public func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    //New implementation to prevent autorotate yet allow camera to rotate for proper pictures
    //works across the app because everything is embedded in the UINavigationController
    override public func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
}

extension NSDateFormatter {
    
    func dateFromStringOptional(string:String?) -> NSDate?
    {
        guard let value = string else
        {
            return nil
        }
        
        return self.dateFromString(value)
    }
}

extension String {
    func trimWhiteSpace() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    //This is necessary because the JSON object actually has timezone data '.SSSZ' which we dont want
    func trimDateTimeZone() -> String {
        return String(self.characters.dropLast(5))
    }
    
    func getStates(state: State) -> String {
        switch state {
        case .AL:
            return "ALABAMA";
            
        case State.AK:
            return "ALASKA";
            
        case State.AS:
            return "AMERICAN SAMOA";
            
        case State.AZ:
            return "ARIZONA";
            
        case State.AR:
            return "ARKANSAS";
            
        case State.CA:
            return "CALIFORNIA";
            
        case State.CO:
            return "COLORADO";
            
        case State.CT:
            return "CONNECTICUT";
            
        case State.DE:
            return "DELAWARE";
            
        case State.DC:
            return "DISTRICT OF COLUMBIA";
            
        case State.FM:
            return "FEDERATED STATES OF MICRONESIA";
            
        case State.FL:
            return "FLORIDA";
            
        case State.GA:
            return "GEORGIA";
            
        case State.GU:
            return "GUAM";
            
        case State.HI:
            return "HAWAII";
            
        case State.ID:
            return "IDAHO";
            
        case State.IL:
            return "ILLINOIS";
            
        case State.IN:
            return "INDIANA";
            
        case State.IA:
            return "IOWA";
            
        case State.KS:
            return "KANSAS";
            
        case State.KY:
            return "KENTUCKY";
            
        case State.LA:
            return "LOUISIANA";
            
        case State.ME:
            return "MAINE";
            
        case State.MH:
            return "MARSHALL ISLANDS";
            
        case State.MD:
            return "MARYLAND";
            
        case State.MA:
            return "MASSACHUSETTS";
            
        case State.MI:
            return "MICHIGAN";
            
        case State.MN:
            return "MINNESOTA";
            
        case State.MS:
            return "MISSISSIPPI";
            
        case State.MO:
            return "MISSOURI";
            
        case State.MT:
            return "MONTANA";
            
        case State.NE:
            return "NEBRASKA";
            
        case State.NV:
            return "NEVADA";
            
        case State.NH:
            return "NEW HAMPSHIRE";
            
        case State.NJ:
            return "NEW JERSEY";
            
        case State.NM:
            return "NEW MEXICO";
            
        case State.NY:
            return "NEW YORK";
            
        case State.NC:
            return "NORTH CAROLINA";
            
        case State.ND:
            return "NORTH DAKOTA";
            
        case State.MP:
            return "NORTHERN MARIANA ISLANDS";
            
        case State.OH:
            return "OHIO";
            
        case State.OK:
            return "OKLAHOMA";
            
        case State.OR:
            return "OREGON";
            
        case State.PW:
            return "PALAU";
            
        case State.PA:
            return "PENNSYLVANIA";
            
        case State.PR:
            return "PUERTO RICO";
            
        case State.RI:
            return "RHODE ISLAND";
            
        case State.SC:
            return "SOUTH CAROLINA";
            
        case State.SD:
            return "SOUTH DAKOTA";
            
        case State.TN:
            return "TENNESSEE";
            
        case State.TX:
            return "TEXAS";
            
        case State.UT:
            return "UTAH";
            
        case State.VT:
            return "VERMONT";
            
        case State.VI:
            return "VIRGIN ISLANDS";
            
        case State.VA:
            return "VIRGINIA";
            
        case State.WA:
            return "WASHINGTON";
            
        case State.WV:
            return "WEST VIRGINIA";
            
        case State.WI:
            return "WISCONSIN";
            
        case State.WY:
            return "WYOMING";
        }
    }
    
    
    func getShortState() -> State? {
        switch (self.uppercaseString) {
        case "ALABAMA":
        return State.AL;
        
        case "ALASKA":
        return State.AK;
        
        case "AMERICAN SAMOA":
        return State.AS;
        
        case "ARIZONA":
        return State.AZ;
        
        case "ARKANSAS":
        return State.AR;
        
        case "CALIFORNIA":
        return State.CA;
        
        case "COLORADO":
        return State.CO;
        
        case "CONNECTICUT":
        return State.CT;
        
        case "DELAWARE":
        return State.DE;
        
        case "DISTRICT OF COLUMBIA":
        return State.DC;
        
        case "FEDERATED STATES OF MICRONESIA":
        return State.FM;
        
        case "FLORIDA":
        return State.FL;
        
        case "GEORGIA":
        return State.GA;
        
        case "GUAM":
        return State.GU;
        
        case "HAWAII":
        return State.HI;
        
        case "IDAHO":
        return State.ID;
        
        case "ILLINOIS":
        return State.IL;
        
        case "INDIANA":
        return State.IN;
        
        case "IOWA":
        return State.IA;
        
        case "KANSAS":
        return State.KS;
        
        case "KENTUCKY":
        return State.KY;
        
        case "LOUISIANA":
        return State.LA;
        
        case "MAINE":
        return State.ME;
        
        case "MARSHALL ISLANDS":
        return State.MH;
        
        case "MARYLAND":
        return State.MD;
        
        case "MASSACHUSETTS":
        return State.MA;
        
        case "MICHIGAN":
        return State.MI;
        
        case "MINNESOTA":
        return State.MN;
        
        case "MISSISSIPPI":
        return State.MS;
        
        case "MISSOURI":
        return State.MO;
        
        case "MONTANA":
        return State.MT;
        
        case "NEBRASKA":
        return State.NE;
        
        case "NEVADA":
        return State.NV;
        
        case "NEW HAMPSHIRE":
        return State.NH;
        
        case "NEW JERSEY":
        return State.NJ;
        
        case "NEW MEXICO":
        return State.NM;
        
        case "NEW YORK":
        return State.NY;
        
        case "NORTH CAROLINA":
        return State.NC;
        
        case "NORTH DAKOTA":
        return State.ND;
        
        case "NORTHERN MARIANA ISLANDS":
        return State.MP;
        
        case "OHIO":
        return State.OH;
        
        case "OKLAHOMA":
        return State.OK;
        
        case "OREGON":
        return State.OR;
        
        case "PALAU":
        return State.PW;
        
        case "PENNSYLVANIA":
        return State.PA;
        
        case "PUERTO RICO":
        return State.PR;
        
        case "RHODE ISLAND":
        return State.RI;
        
        case "SOUTH CAROLINA":
        return State.SC;
        
        case "SOUTH DAKOTA":
        return State.SD;
        
        case "TENNESSEE":
        return State.TN;
        
        case "TEXAS":
        return State.TX;
        
        case "UTAH":
        return State.UT;
        
        case "VERMONT":
        return State.VT;
        
        case "VIRGIN ISLANDS":
            return State.VI;
        
        case "VIRGINIA":
            return State.VA;
        
        case "WASHINGTON":
            return State.WA;
            
        case "WEST VIRGINIA":
            return State.WV;
        
        case "WISCONSIN":
            return State.WI;
        
        case "WYOMING":
            return State.WY;
        
        default:
            return nil
        }
    }
    
    func getShortStateCanada() -> StateCanada? {
        switch self.uppercaseString {
        case "ALBERTA":
            return StateCanada.AB
        case "BRITISH COLUMBIA":
            return StateCanada.BC
        case "MANITOBA":
            return StateCanada.MB
            case "NEW BRUNSWICK":
            return StateCanada.NB
            case "NEWFOUNDLAND AND LABRADOR":
            return StateCanada.NL
            case "NORTHWEST TERRITORIES":
            return StateCanada.NT
            case "NOVA SCOTIA":
            return StateCanada.NS
            case "NUNAVUT":
            return StateCanada.NU
            case "ONTARIO":
            return StateCanada.ON
            case "PRINCE EDWARD ISLAND":
            return StateCanada.PE
            case "QUEBEC":
            return StateCanada.QC
            case "SASKATCHEWAN":
            return StateCanada.SK
            case "YUKON":
            return StateCanada.YT
        default:
            return nil
        }
    }
    
    func getShortStateAustralia() -> StateAustralia? {
        switch self.uppercaseString {
        case "AUSTRALIAN CAPITAL TERRITORY":
            return StateAustralia.ACT
            case "NEW SOUTH WALES":
            return StateAustralia.NSW
            case "VICTORIA":
            return StateAustralia.VIC
            case "QUEENSLAND":
            return StateAustralia.QLD
            case "SOUTH AUSTRALIA":
            return StateAustralia.SA
            case "WESTERN AUSTRALIA":
            return StateAustralia.WA
            case "TASMANIA":
            return StateAustralia.TAS
            case "NORTHERN TERRITORY":
            return StateAustralia.NT
            case "AUSTRALIAN ANTARTIC TERRITORY":
            return StateAustralia.AAT
        default:
            return nil
        }
    }
    
    enum StateCanada: String {
        case AB = "AB"
        case BC = "BC"
        case MB = "MB"
        case NB = "NB"
        case NL = "NL"
        case NT = "NT"
        case NS = "NS"
        case NU = "NU"
        case ON = "ON"
        case PE = "PE"
        case QC = "QC"
        case SK = "SK"
        case YT = "YT"
    }
    
    enum StateAustralia: String {
        case ACT = "ACT"
        case NSW = "NSW"
        case VIC = "VIC"
        case QLD = "QLD"
        case SA = "SA"
        case WA = "WA"
        case TAS = "TAS"
        case NT = "NT"
        case AAT = "AAT"
    }
    
    enum State: String {
        case AL = "AL"
        case AK = "AK"
        case AS = "AS"
        case AZ = "AZ"
        case AR = "AR"
        case CA = "CA"
        case CO = "CO"
        case CT = "CT"
        case DE = "DE"
        case DC = "DC"
        case FM = "FM"
        case FL = "FL"
        case GA = "GA"
        case GU = "GU"
        case HI = "HI"
        case ID = "ID"
        case IL = "IL"
        case IN = "IN"
        case IA = "IA"
        case KS = "KS"
        case KY = "KY"
        case LA = "LA"
        case ME = "ME"
        case MH = "MH"
        case MD = "MD"
        case MA = "MA"
        case MI = "MI"
        case MN = "MN"
        case MS = "MS"
        case MO = "MO"
        case MT = "MT"
        case NE = "NE"
        case NV = "NV"
        case NH = "NH"
        case NJ = "NJ"
        case NM = "NM"
        case NY = "NY"
        case NC = "NC"
        case ND = "ND"
        case MP = "MP"
        case OH = "OH"
        case OK = "OK"
        case OR = "OR"
        case PW = "PW"
        case PA = "PA"
        case PR = "PR"
        case RI = "RI"
        case SC = "SC"
        case SD = "SD"
        case TN = "TN"
        case TX = "TX"
        case UT = "UT"
        case VT = "VT"
        case VI = "VI"
        case VA = "VA"
        case WA = "WA"
        case WV = "WV"
        case WI = "WI"
        case WY = "WY"
    }
}

extension PHAsset {
    
    func getAdjustedSize(maxDimension: CGFloat)-> CGSize {
        let width = CGFloat(pixelWidth)
        let height = CGFloat(pixelHeight)
        var newWidth: CGFloat = 0
        var newHeight: CGFloat = 0
        
        if height > width {
            newHeight = maxDimension
            newWidth = maxDimension * (width / height )
        } else {
            newWidth = maxDimension
            newHeight = maxDimension * ( height / width )
        }
        return CGSize(width: newWidth, height: newHeight)
    }
}

extension UIImage {
    func getAdjustedSize(maxDimension: CGFloat)-> CGSize {
        let height = size.height
        let width = size.width
        var newHeight: CGFloat = 0
        var newWidth: CGFloat = 0
        if height > width {
            newHeight = maxDimension
            newWidth = maxDimension * (width / height )
        } else {
            newWidth = maxDimension
            newHeight = maxDimension * ( height / width )
        }
        return CGSize(width: newWidth, height: newHeight)
    }
}

extension UIFont {
    static func plangoHeader() -> UIFont {
        return UIFont(name: "Raleway-Regular", size: 16)!
    }
    static func plangoSectionHeader() -> UIFont {
        return UIFont(name: "Lato-Bold", size: 16)!
    }
    static func plangoNav() -> UIFont {
        return UIFont(name: "Raleway-Bold", size: 18)!
    }
    static func plangoTabBar() -> UIFont {
        return UIFont(name: "Raleway-Light", size: 10)!
    }
    static func plangoBodyBig() -> UIFont {
        return UIFont(name: "Lato-Regular", size: 14)!
    }
    static func plangoBody() -> UIFont {
        return UIFont(name: "Lato-Regular", size: 12)!
    }
    static func plangoButton() -> UIFont {
        return UIFont(name: "Raleway-Bold", size: 18)!
    }
    static func plangoPlaceholder() -> UIFont {
        return UIFont(name: "Lato-Regular", size: 10)!
    }
    static func plangoSmallButton() -> UIFont {
        return UIFont(name: "Raleway-Bold", size: 14)!
    }
}

extension UIColor {
    static func plangoTeal() -> UIColor {
        return UIColor.hex("#36C1CD")
    }
    static func plangoOrange() -> UIColor {
        return UIColor.hex("#FF7916")
    }
    static func plangoBackgroundGray() -> UIColor {
        return UIColor.hex("#f2f2f2")
    }
    static func plangoSectionHeaderGray() -> UIColor {
        return UIColor.hex("#f9f9f9")
    }
    static func plangoTypeSectionHeaderGray() -> UIColor {
        return UIColor.hex("#666666")
    }
    static func plangoBlack() -> UIColor {
        return UIColor.hex("#333333")
    }
    static func plangoText() -> UIColor {
        return UIColor.hex("#4A4A4A")
    }
    static func plangoCream() -> UIColor {
        return UIColor.hex("#FDF6EA")
    }
    static func plangoGreen() -> UIColor {
        return UIColor.hex("#67B908")
    }
    static func plangoBrown() -> UIColor {
        return UIColor.hex("#93723B")
    }
}

extension NSIndexSet {
    
    func aapl_indexPathsFromIndexesWithSection(section: Int) -> [NSIndexPath] {
        var indexPaths: [NSIndexPath] = []
        indexPaths.reserveCapacity(self.count)
        self.enumerateIndexesUsingBlock{idx, stop in
            indexPaths.append(NSIndexPath(forItem: idx, inSection: section))
        }
        return indexPaths
    }
    
}

extension UITableView {
    // breaks tableview ability to recognize select
//    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        super.touchesBegan(touches, withEvent: event)
//        self.endEditing(true)
//    }
}

extension UICollectionView {
//    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        super.touchesBegan(touches, withEvent: event)
//        self.endEditing(true)
//    }
    
    //### returns empty Array, rather than nil, when no elements in rect.
    func aapl_indexPathsForElementsInRect(rect: CGRect) -> [NSIndexPath] {
        guard let allLayoutAttributes = self.collectionViewLayout.layoutAttributesForElementsInRect(rect)
            else {return []}
        let indexPaths = allLayoutAttributes.map{$0.indexPath}
        return indexPaths
    }
    
}

extension UICollectionViewFlowLayout {
    func cellsFitAcrossScreen(numberOfCells: Int, labelHeight: CGFloat, cellShapeRatio: CGFloat) -> CGSize {
        //using information from flowLayout get proper spacing for cells across entire screen
        let insideMargin = self.minimumInteritemSpacing
        let outsideMargins = self.sectionInset.left + self.sectionInset.right
        let numberOfDivisions: Int = numberOfCells - 1
        let subtractionForMargins: CGFloat = insideMargin * CGFloat(numberOfDivisions) + outsideMargins
        
        let fittedWidth = (UIScreen.mainScreen().bounds.width - subtractionForMargins) / CGFloat(numberOfCells)
        let ratioHeight = fittedWidth * cellShapeRatio
        
        return CGSize(width: fittedWidth, height: ratioHeight + labelHeight)
    }
    
    func widescreenCards() -> CGSize {
        let cellWidth = UIScreen.mainScreen().bounds.size.width * 0.6
        let cellHeight = cellWidth * (9/16)
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

extension UIResponder {
    func printPlangoError(error: PlangoError) {
        if let status = error.statusCode, message = error.message {
            print("In \(self) Status Code: \(status) Message: \(message)")
        }
    }
    
    func printError(error: NSError) {
        print("In \(self) Code: \(error.code) Failure Reason: \(error.localizedFailureReason)")
    }
}

extension UIView {
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.endEditing(true)
    }
    
    func makeCircle() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
    
    func makeRoundCorners(divider: Int) {
        self.layer.cornerRadius = self.frame.size.width / CGFloat(divider)
        self.clipsToBounds = true
    }
    
    func addSelectionLayer() {
        let select = SelectionLayer()
        select.frame = self.bounds
        select.addBadge()
        self.layer.addSublayer(select)
    }
    
    func gradientDarkToClear() {
        let colorTop = UIColor.clearColor().CGColor
        let colorBottom = UIColor.blackColor().colorWithAlphaComponent(0.7).CGColor
        
        let gl: CAGradientLayer
        
        gl = CAGradientLayer()
        gl.colors = [ colorTop, colorBottom]
        gl.locations = [ 0.0, 1.0]
        gl.frame = self.bounds
        self.layer.addSublayer(gl)
    }
    
    
    // MARK: Toast via MBProgressHUD
    func quickToast(title: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let hud = MBProgressHUD.showHUDAddedTo(self, animated: true)
            hud.mode = MBProgressHUDMode.Text
            hud.labelText = title
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(UIView.hudTimerDidFire(_:)), userInfo: hud, repeats: false)
        })
    }
    
    func detailToast(title: String, details: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let hud = MBProgressHUD.showHUDAddedTo(self, animated: true)
            hud.mode = MBProgressHUDMode.Text
            hud.labelText = title
            hud.detailsLabelText = details
            NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(UIView.hudTimerDidFire(_:)), userInfo: hud, repeats: false)
        })
    }
    
    func imageToast(title: String?, image: UIImage, notify: Bool) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let hud = MBProgressHUD.showHUDAddedTo(self, animated: true)
            hud.mode = MBProgressHUDMode.CustomView
            hud.labelText = title
            hud.customView = UIImageView(image: image)
            
            if notify == true {
                NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(UIView.hudTimerDidFireAndNotify(_:)), userInfo: hud, repeats: false)
            } else {
                NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(UIView.hudTimerDidFire(_:)), userInfo: hud, repeats: false)
            }
            
        })
    }
    
    func showSimpleLoading() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            MBProgressHUD.showHUDAddedTo(self, animated: true)
        })
    }
    
    func hideSimpleLoading() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            MBProgressHUD.hideHUDForView(self, animated: true)
        })
    }
    
    func showPieLoading() -> MBProgressHUD {
        let hud = MBProgressHUD(view: self)
        hud.mode = MBProgressHUDMode.Determinate
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.addSubview(hud)
            hud.show(true)
        })
        return hud
    }
    
    func hidePieLoading(hud: MBProgressHUD, percent: Float) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            hud.progress = percent
            if hud.progress == 1.0 {
                hud.hide(true)
            }
        })
    }
    
    func hudTimerDidFire(sender: NSTimer) {
        if let hud = sender.userInfo as? MBProgressHUD {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                hud.hide(true)
            })
        }
    }
    
    func hudTimerDidFireAndNotify(sender: NSTimer) {
        if let hud = sender.userInfo as? MBProgressHUD {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                hud.hide(true)
                NSNotificationCenter.defaultCenter().postNotificationName(Notify.Timer.rawValue, object: nil, userInfo: nil)
            })

        }
    }
}
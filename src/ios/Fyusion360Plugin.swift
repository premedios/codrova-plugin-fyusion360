//
//  Fyusion360Plugin.swift
//  Fyusion360Test
//
//  Created by Pedro Remédios on 28/07/2020.
//

import Foundation

import FyuseSessionTagging

public enum CapturedDetailPhotoTypes: CustomStringConvertible {
    
    //Default ordered set for non 2D flow
    case coreOdometer
    case centerConsoleDsiplay
    case emissionSticker
    case vinPlate
    case frontDriverSeat
    case leftSeatBack
    case vanThirdRow
    case coreTrunk
    case coreEngine
    
    //Default ordered set for 2D flow
    case exteriorFrontLeft
    case exteriorBackLeft
    case exteriorBackRight
    case exteriorRight
    
    // Extras
    case fullDashboard
    case angledDashboard
    case backOfFrontSeat
    case backUpCamera
    case exteriorBack
    case exteriorFront
    case frontPassengerSeat
    case gloveCompartment
    case steeringWheel
    case sunroof

    //For Electric Car
    case electricChargerCord
    case electricEngine

    //For Van
    case vanThirdRowDown
    case vanFlipTV
    case vanTrunk
    
    //For Truck
    case truckBed
    case truckGateDown
    
    case thumbnail
    
    public var description: String {
        switch self {
            //Default ordered set for non 2D flow
        case .coreOdometer: return "Core Odometer"
        case .centerConsoleDsiplay: return "Center Console Display"
        case .emissionSticker: return "Emission Sticker"
        case .vinPlate: return "VIN Plate"
        case .frontDriverSeat: return "Front Driver Seat"
        case .leftSeatBack: return "Left Seat Back"
        case .vanThirdRow: return "Third Row"
        case .coreTrunk: return "Trunk"
        case .coreEngine: return "Engine"
            
            //Default ordered set for 2D flow
        case .exteriorFrontLeft: return "Exterior Front Left"
        case .exteriorBackLeft: return "Exterior Back Left"
        case .exteriorBackRight: return "Exterior Back Right"
        case .exteriorRight: return "Exterior Right"
            
            // Extras
        case .fullDashboard: return "Full Dashboard"
        case .angledDashboard: return "Angled Dashboard"
        case .backOfFrontSeat: return "Back Of Front Seat"
        case .backUpCamera: return "Back-Up Camera"
        case .exteriorBack: return "Exterior Back"
        case .exteriorFront: return "Exterior Front"
        case .frontPassengerSeat: return "Front Passenger Seat"
        case .gloveCompartment: return "Glove Compartment"
        case .steeringWheel: return "Steering Wheel"
        case .sunroof: return "Sunroof"

            //For Electric Car
        case .electricChargerCord: return "Electric Charger Cord"
        case .electricEngine: return "Engine"

            //For Van
        case .vanThirdRowDown: return "Third Row Down"
        case .vanFlipTV: return "Flip TV"
        case .vanTrunk: return "Trunk"
            
            //For Truck
        case .truckBed: return "Bed"
        case .truckGateDown: return "Gate Down"
            
        case .thumbnail: return "Thumbnail"
        }
    }
}

@objc(Fyusion360Plugin) class Fyusion360Plugin: CDVPlugin {
    
    var callbackId: String!

    var sessionViewController: FYSessionViewController!
    var backgroundUploadSessionManager: FYBackgroundUploadSessionManager!
    var uploadSessionManager: FYUploadSessionManager!
    var currentSessionIdentifier: String!
    var fyuseViewController: UIViewController!
    
    var fyuseIDs: [String]!
    
    var fyuseInfo: NSMutableDictionary!
    
    @objc(startSession:)
    func startSession(command: CDVInvokedUrlCommand) {

        fyuseInfo = NSMutableDictionary()
        fyuseIDs = [String]()
        
        let optionsString: NSString = command.arguments[0] as? NSString ?? ""
        let options = try? JSONSerialization.jsonObject(with: optionsString.data(using: String.Encoding.utf8.rawValue) ?? Data(), options: .allowFragments) as! NSDictionary
        
        sessionViewController = FYSessionViewController.make { (builder) in
            builder?.skipPhotos = options?["skipPhotos"] as? Bool ?? false
            builder?.skipTutorialFlow = options?["skipTutorialFlow"] as? Bool ?? false
            builder?.skipReviewPhotoScreen = options?["skipReviewPhotoScreen"] as? Bool ?? false
            builder?.enableFeedbackScreens = options?["enableFeedbackScreens"] as? Bool ?? true
        }
        
        self.callbackId = command.callbackId
        sessionViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        sessionViewController.sessionDelegate = self
        self.viewController.present(sessionViewController, animated: true, completion: nil)

    }
    
    @objc(showFyuse:)
    func showFyuse(command: CDVInvokedUrlCommand) {
        if let arguments = command.arguments, arguments.count > 0 {
            self.commandDelegate.run {
                FYSessionManager.requestMainFyuseForSession(withIdentifier: (arguments[0] as! String)) { fyuseObj in
                    var pluginResult: CDVPluginResult
                    
                    if let fyuse = fyuseObj {
                        self.fyuseViewController = UIViewController()
                        self.fyuseViewController.modalPresentationStyle = .currentContext
                        self.fyuseViewController.view.backgroundColor = .white
                        let fyuseView = FYFyuseView()
                        fyuseView.translatesAutoresizingMaskIntoConstraints = false
                        fyuseView.fyuse = fyuse
                        fyuseView.contentMode = .scaleAspectFit
                        fyuseView.motionEnabled = true
                        fyuseView.priority = .visible
                        fyuseView.preferredResolution = .normal
                        self.fyuseViewController.view.addSubview(fyuseView)
                        fyuseView.topAnchor.constraint(equalTo: self.fyuseViewController.view.topAnchor, constant: 16).isActive = true
                        fyuseView.centerXAnchor.constraint(equalTo: self.fyuseViewController.view.centerXAnchor).isActive = true
                        fyuseView.leadingAnchor.constraint(equalTo: self.fyuseViewController.view.leadingAnchor, constant: 16).isActive = true
                        fyuseView.trailingAnchor.constraint(equalTo: self.fyuseViewController.view.trailingAnchor, constant: -16).isActive = true
                        fyuseView.bottomAnchor.constraint(equalTo: self.fyuseViewController.view.bottomAnchor, constant: 16).isActive = true
                        self.viewController.present(self.fyuseViewController, animated: true, completion: nil)
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Fyusion360 session retrieved successfully")
                    } else {
                        pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Unable to retrieve Fyusion360 session. Please contact support")
                    }
                    self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                }
            }
        }
    }
    
    fileprivate func UIImageToBase64(_ thumbnailImage: UIImage) -> String! {
        return UIImagePNGRepresentation(thumbnailImage)?.base64EncodedString(options: .lineLength64Characters) ?? ""
    }
    
    @objc(getFyuseThumbnail:)
    func getFyuseThumbnail(command: CDVInvokedUrlCommand) {
        if let arguments = command.arguments, arguments.count > 0 {
            self.commandDelegate.run {
                FYSessionManager.requestMainFyuseForSession(withIdentifier: (arguments[0] as! String)) { fyuseObj in
                    
                    fyuseObj?.thumbnail(success: { thumbnailImage in
                        
                        if let thumbnailImage = thumbnailImage {
                            let thumbnailImageBase64 = self.UIImageToBase64(thumbnailImage)
                            if thumbnailImageBase64 != "" {
                                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: thumbnailImageBase64)
                                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                            } else {
                                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error parsing thumbnail image to base64 string")
                                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                            }
                        } else {
                            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "No thumbnail")
                            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                        }
                    }, failure: { error in
                        let errorResult = error!
                        let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error retrieving thumbnail: \(errorResult)")
                        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                    })
                }
            }
        } else {
            
        }
    }
    
    fileprivate func getDetailPhotoKey(forCapturedDetailPhoto capturedDetailPhoto: FYSessionDetailPhoto) -> String {
        switch capturedDetailPhoto.photoType {
        //Default ordered set for non 2D flow
        case .coreOdometer: return "\(CapturedDetailPhotoTypes.coreOdometer)"
        case .centerConsoleDsiplay: return "\(CapturedDetailPhotoTypes.centerConsoleDsiplay)"
        case .emissionSticker: return "\(CapturedDetailPhotoTypes.emissionSticker)"
        case .vinPlate: return "\(CapturedDetailPhotoTypes.vinPlate)"
        case .frontDriverSeat: return "\(CapturedDetailPhotoTypes.frontDriverSeat)"
        case .leftSeatBack: return "\(CapturedDetailPhotoTypes.leftSeatBack)"
        case .vanThirdRow: return "\(CapturedDetailPhotoTypes.vanThirdRow)"
        case .coreTrunk: return "\(CapturedDetailPhotoTypes.coreTrunk)"
        case .coreEngine: return "\(CapturedDetailPhotoTypes.coreEngine)"
            
        //Default ordered set for 2D flow
        case .exteriorFrontLeft: return "\(CapturedDetailPhotoTypes.exteriorFrontLeft)"
        case .exteriorBackLeft: return "\(CapturedDetailPhotoTypes.exteriorBackLeft)"
        case .exteriorBackRight: return "\(CapturedDetailPhotoTypes.exteriorBackRight)"
        case .exteriorRight: return "\(CapturedDetailPhotoTypes.exteriorRight)"
            
        // Extras
        case .fullDashboard: return "\(CapturedDetailPhotoTypes.fullDashboard)"
        case .angledDashboard: return "\(CapturedDetailPhotoTypes.angledDashboard)"
        case .backOfFrontSeat: return "\(CapturedDetailPhotoTypes.backOfFrontSeat)"
        case .backUpCamera: return "\(CapturedDetailPhotoTypes.backUpCamera)"
        case .exteriorBack: return "\(CapturedDetailPhotoTypes.exteriorBack)"
        case .exteriorFront: return "\(CapturedDetailPhotoTypes.exteriorFront)"
        case .frontPassengerSeat: return "\(CapturedDetailPhotoTypes.frontPassengerSeat)"
        case .gloveCompartment: return "\(CapturedDetailPhotoTypes.gloveCompartment)"
        case .steeringWheel: return "\(CapturedDetailPhotoTypes.steeringWheel)"
        case .sunroof: return "\(CapturedDetailPhotoTypes.sunroof)"
            
        //For Electric Car
        case .electricChargerCord: return "\(CapturedDetailPhotoTypes.electricChargerCord)"
        case .electricEngine: return "\(CapturedDetailPhotoTypes.electricEngine)"
            
        //For Van
        case .vanThirdRowDown: return "\(CapturedDetailPhotoTypes.vanThirdRowDown)"
        case .vanFlipTV: return "\(CapturedDetailPhotoTypes.vanFlipTV)"
        case .vanTrunk: return "\(CapturedDetailPhotoTypes.vanTrunk)"
            
        //For Truck
        case .truckBed: return "\(CapturedDetailPhotoTypes.truckBed)"
        case .truckGateDown: return "\(CapturedDetailPhotoTypes.truckGateDown)"
            
        case .thumbnail: return "\(CapturedDetailPhotoTypes.thumbnail)"
        }
    }
    
    @objc(getDetailPhotos:)
    func getDetailPhotos(command: CDVInvokedUrlCommand) {
        if let arguments = command.arguments, arguments.count == 2 {
            let desiredResolution = arguments[1] as! String
            let desiredSessionID = arguments[0] as! String
            let capturedDetailPhotos: [FYSessionDetailPhoto]! = FYSessionManager.capturedDetailPhotos(forSession: desiredSessionID)
            if capturedDetailPhotos.count == 0 {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "No detail photos found for the requested session ID")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId);
            } else {
                let detailPhotos = NSMutableDictionary()
                for capturedDetailPhoto in capturedDetailPhotos {
                    FYSessionManager.requestDetailImage(forSessionId: desiredSessionID, detailPhoto: capturedDetailPhoto, completion: { (detailPhoto) in
                        detailPhotos[self.getDetailPhotoKey(forCapturedDetailPhoto: capturedDetailPhoto)] = self.UIImageToBase64(detailPhoto!)
                        if detailPhotos.allKeys.count == capturedDetailPhotos.count {
                            let detailPhotosDictionaryString = String(data: try! JSONSerialization.data(withJSONObject: detailPhotos, options: []), encoding: .utf8)
                            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: detailPhotosDictionaryString)
                            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                        }
                    }, resolution: (desiredResolution == "THUMBNAIL" ? FYPhotoResolution.thumbnail : FYPhotoResolution.default))
                }
            }
        } else {
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Please indicate the saved session ID and desired resolution ('THUMBNAIL' or 'NORMAL')")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
    }
    
    private func addToFyuseInfo(data: String!, forKey key: String!) -> String! {
        fyuseInfo[key] = data
        
        return String(data: try! JSONSerialization.data(withJSONObject: fyuseInfo, options: []), encoding: .utf8)
    }
    
}

extension Fyusion360Plugin: FYSessionViewControllerDelegate, FYUploadSessionManagerDelegate {
    func sessionController(_ sessionController: FYSessionViewController!, didSaveSessionWithIdentifier identifier: String!) {
        self.currentSessionIdentifier = identifier!
        _ = self.addToFyuseInfo(data: self.currentSessionIdentifier, forKey: "sessionID")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64(0.5) * NSEC_PER_SEC)) {
            self.uploadSessionManager = FYUploadSessionManager()
            self.uploadSessionManager.delegate = self
            self.uploadSessionManager.uploadSession(withIdentifier: self.currentSessionIdentifier)
        }
    }
    
    func sessionControllerDidDismiss(_ sessionController: FYSessionViewController!) {
        if self.currentSessionIdentifier == nil {
            let pluginResult = CDVPluginResult(status: .ok, messageAs: "Session aborted")
            self.commandDelegate.send(pluginResult, callbackId: self.callbackId)
        }
    }
    
    func sessionUpdatedUploadProgress(_ progress: CGFloat) {
//        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: addToFyuseInfo(data: String(format: "%.1f", progress), forKey: "uploadProgress"))!
//        pluginResult.keepCallback = true
//        self.commandDelegate.send(pluginResult, callbackId: self.callbackId)
//        print(progress)
    }
    
    func sessionFinishedUploading(withUID uid: String!) {
        let fyuseID = FYUploadSessionManager.mainFyuseID(forSessionIdentifier: self.currentSessionIdentifier)
        
        fyuseInfo["fyuseID"] = fyuseID ?? ""
        
        if let fyuseID = fyuseID {
            fyuseIDs.append(fyuseID)
        }
               
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: addToFyuseInfo(data: fyuseID, forKey: "fyuseID"));
        
        self.commandDelegate.send(pluginResult, callbackId: self.callbackId)
    }
    
}

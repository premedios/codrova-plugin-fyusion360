//
//  Fyusion360Plugin.swift
//  Fyusion360Test
//
//  Created by Pedro Remédios on 28/07/2020.
//

import Foundation

import FyuseSessionTagging

@objc(Fyusion360Plugin) class Fyusion360Plugin: CDVPlugin {
    
    var callbackId: String!

    var sessionViewController: FYSessionViewController? = nil
    var backgroundUploadSessionManager: FYBackgroundUploadSessionManager!
    var uploadSessionManager: FYUploadSessionManager!
    var currentSessionIdentifier: String!
    var editingSessionViewController: FYEditSessionViewController!
    var fyuseViewController: UIViewController!
    
    var fyuseIDs: [String]!
    
    var fyuseInfo: NSMutableDictionary!
    
    @objc(startSession:)
    func startSession(command: CDVInvokedUrlCommand) {
        fyuseInfo = NSMutableDictionary()
        fyuseIDs = [String]()
        
        FYSessionDetailPhoto.object(for: .coreOdometer)?.displayName = "bla bla"
        sessionViewController = FYSessionViewController()
        
        if let sessionViewController = sessionViewController {
            self.callbackId = command.callbackId
            sessionViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            sessionViewController.sessionDelegate = self
            self.viewController.present(sessionViewController, animated: true, completion: nil)
        } else {
            self.commandDelegate.send(CDVPluginResult(status: .error, messageAs: "Unable to initiate capture session screen"), callbackId: command.callbackId)
        }
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
    
    @objc(getFyuseThumbnail:)
    func getFyuseThumbnail(command: CDVInvokedUrlCommand) {
        if let arguments = command.arguments, arguments.count > 0 {
            self.commandDelegate.run {
                FYSessionManager.requestMainFyuseForSession(withIdentifier: (arguments[0] as! String)) { fyuseObj in
                    
                    fyuseObj?.thumbnail(success: { thumbnailImage in
                        
                        if let thumbnailImage = thumbnailImage {
                            let thumbnailImageBase64 = UIImagePNGRepresentation(thumbnailImage)?.base64EncodedString(options: .lineLength64Characters)
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
        let pluginResult = CDVPluginResult(status: .ok, messageAs: String(format: "Session saved with session identifier: %@", self.currentSessionIdentifier))
        self.commandDelegate.send(pluginResult, callbackId: self.callbackId)
    }
    
    func sessionUpdatedUploadProgress(_ progress: CGFloat) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: addToFyuseInfo(data: String(format: "%.1f", progress), forKey: "uploadProgress"))!
        pluginResult.keepCallback = true
        self.commandDelegate.send(pluginResult, callbackId: self.callbackId)
        print(progress)
    }
    
    func sessionFinishedUploading(withUID uid: String!) {
        let fyuseID = FYUploadSessionManager.mainFyuseID(forSessionIdentifier: self.currentSessionIdentifier)
        
        fyuseInfo["fyuseID"] = fyuseID ?? ""
        
        if let fyuseID = fyuseID {
            fyuseIDs.append(fyuseID)
        }
        
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: addToFyuseInfo(data: fyuseID, forKey: "fyuseID"));
        
        self.commandDelegate.send(pluginResult, callbackId: self.callbackId)
        //print(FYUploadSessionManager.mainFyuseID(forSessionIdentifier: self.currentSessionIdentifier))
    }
    
}

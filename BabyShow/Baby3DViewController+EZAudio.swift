//
//  Baby3DViewController+EZAudio.swift
//  BabyShow
//
//  Created by ksn_cn on 2016/11/14.
//  Copyright © 2016年 CQU. All rights reserved.
//

import Foundation

extension Baby3DViewController: EZMicrophoneDelegate {
    
    func audioSettingInit() {
        
        self.audioPlot.isHidden = true
        
        // 设置AudioSession
        setAudionSessionAndAudioPlot()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.inputDeviceDidChange), name: Notification.Name.AVAudioSessionRouteChange, object: AVAudioSession.sharedInstance())
    }
    
    /// 输入设备发生变化时的回调
    func inputDeviceDidChange(notification: NSNotification) {
        //        let inputDevice = notification.object as! AVAudioSession
        //        print("current input device: \(inputDevice.currentRoute)")
        
        let interuptionDict = notification.userInfo;
        
        let routeChangeReason = interuptionDict![AVAudioSessionRouteChangeReasonKey] as! UInt
        
        switch (routeChangeReason) {
            
        case AVAudioSessionRouteChangeReason.newDeviceAvailable.rawValue:
            NSLog("AVAudioSessionRouteChangeReasonNewDeviceAvailable")
            
            headphoneDidPlug()
            
            break
            
        case AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue:
            NSLog("AVAudioSessionRouteChangeReasonOldDeviceUnavailable")
            
            headphoneDidUnplug()
            
            break
            
        case AVAudioSessionRouteChangeReason.categoryChange.rawValue:
            // called at start - also when other audio wants to play
            NSLog("AVAudioSessionRouteChangeReasonCategoryChange")
            break
        default:
            NSLog("default")
        }
    }
    
    /// 设置AudioSession 和 EZAudioPlot
    func setAudionSessionAndAudioPlot() {
        //
        // Setup the AVAudioSession. EZMicrophone will not work properly on iOS
        // if you don't do this!
        //
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
        } catch {
            NSLog("Error setting up audio session category: \(error)")
        }
        do {
            try session.setActive(true)
        } catch {
            NSLog("Error setting up audio session active: \(error)")
        }
        
        //
        // Customizing the audio plot's look
        //
        
//        // hidden
//        audioPlot.isHidden = true
        
        // Background color
//        self.audioPlot.backgroundColor = UIColor.clear
        
        // Waveform color
        self.audioPlot.color = UIColor(red: 1.0, green:1.0, blue:1.0, alpha:1.0)
        
        // Plot type
        self.audioPlot.plotType = .rolling
        self.audioPlot.shouldFill = true
        self.audioPlot.shouldMirror = true
        self.audioPlot.gain = 10.0
        
        // Create the microphone
        self.microphone = EZMicrophone(delegate: self)
        
        self.inputs = EZAudioDevice.inputDevices() as NSArray?
        
        // 检测是否插入耳机
        for item in session.currentRoute.outputs {
            if item.portType == AVAudioSessionPortHeadphones {
                headphoneDidPlug()
            }
        }
    }
    
    /// 插入耳机后的操作
    func headphoneDidPlug() {
        NSLog("Headphone/Line plugged in")
        
        self.audioDeviceIsPlugged = true
        
//        audioPlot.isHidden = false
//        txyBtn.isEnabled = false
//        microphone!.startFetchingAudio()
    }
    
    /// 拔出耳机后的操作
    func headphoneDidUnplug() {
        NSLog("Headphone/Line was pulled")
        
        self.audioDeviceIsPlugged = false
        
//        audioPlot.isHidden = true
//        txyBtn.isEnabled = true
        microphone?.stopFetchingAudio()
        self.audioPlot.clear()
    }
    
    // MARK: - EZMicrophoneDelegate
    func microphone(_ microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        
        DispatchQueue.main.async {
            //
            // All the audio plot needs is the buffer data (float*) and the size.
            // Internally the audio plot will handle all the drawing related code,
            // history management, and freeing its own resources.
            // Hence, one badass line of code gets you a pretty plot :)
            //
            
            self.audioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
        }
    }
    
    func microphone(_ microphone: EZMicrophone!, hasAudioStreamBasicDescription audioStreamBasicDescription: AudioStreamBasicDescription) {
        EZAudioUtilities.printASBD(audioStreamBasicDescription)
    }
    
    func microphone(_ microphone: EZMicrophone!, hasBufferList bufferList: UnsafeMutablePointer<AudioBufferList>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        
    }
    
    private func microphone(microphone: EZMicrophone!, changedDevice device: EZAudioDevice!) {
        NSLog("Microphone changed device: \(device.name)");
        
        //
        // Called anytime the microphone's device changes
        //
        DispatchQueue.main.async {
            
            //
            // Reset the device list (a device may have been plugged in/out)
            //
            //            if device.name == "耳机麦克风" {
            //                print("device.name == 耳机麦克风")
            //
            //            } else {
            //                self.microphone!.stopFetchingAudio()
            //            }
            self.inputs = EZAudioDevice.inputDevices() as NSArray?
        }
    }
}

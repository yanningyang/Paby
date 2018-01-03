//
//  Baby3DViewController+BabyControl.swift
//  BabyShow
//
//  Created by ksn_cn on 16/8/11.
//  Copyright © 2016年 CQU. All rights reserved.
//

import UIKit
import SceneKit

extension Baby3DViewController {
    
    // MARK: Touch Events
    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        // Start panning
//        
//        panningTouch = touches.first
//        print("touches.count :\(touches.count)")
//    }
//    
//    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        if let touch = panningTouch {
//            let location = touch.locationInView(view)
//            let preLocation = touch.previousLocationInView(view)
//            let displacement = (float2(Float(location.x), Float(location.y)) - float2(Float(preLocation.x), Float(preLocation.y)))
//            
//            panCamera(displacement)
//        }
//    }
//    
//    func commonTouchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        if let touch = panningTouch {
//            if touches.contains(touch) {
//                panningTouch = nil
//            }
//        }
//    }
//    
//    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
//        commonTouchesEnded(touches!, withEvent: event)
//    }
//    
//    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        commonTouchesEnded(touches, withEvent: event)
//    }
    
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.babySCNView
        
        //        self.mainSkeleton!.paused = false
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        
        let hitResults = scnView?.hitTest(p, options: nil)
        // check that we clicked on at least one object
        if (hitResults?.count)! > 0 {
            // retrieved the first clicked object
            //            let result: AnyObject! = hitResults![0]
            
            for item in hitResults! {
                print(item.node.name ?? "error: no node name")
            }
            
//            // get its material
//            let material = result.node!.geometry!.firstMaterial!
//            
//            
//            // highlight it
//            SCNTransaction.begin()
//            SCNTransaction.setAnimationDuration(0.5)
//            
//            // on completion - unhighlight
//            SCNTransaction.setCompletionBlock {
//                SCNTransaction.begin()
//                SCNTransaction.setAnimationDuration(0.5)
//                
//                material.emission.contents = UIColor.blackColor()
//                
//                SCNTransaction.commit()
//            }
//            
//            material.emission.contents = UIColor.redColor()
//            
//            SCNTransaction.commit()
        }
    }
    
    func handlePan(_ gestureRecognize: UIPanGestureRecognizer) {
        
        let currentLocation = gestureRecognize.location(in: self.babySCNView)
        
        let numOfTouch = gestureRecognize.numberOfTouches
        
        switch gestureRecognize.state {
        case .began:
            
            startLocation = gestureRecognize.location(in: self.babySCNView)
            lastLocation = startLocation
        case .changed:
            
            let offsetX = Float(currentLocation.x  - lastLocation.x)
            let offsetY = Float(currentLocation.y  - lastLocation.y)
            
            let displacement = float2(offsetX, offsetY)
            if numOfTouch == 1 {
                panCamera(displacement)
            } else if numOfTouch == 2 {
                translateCamera(displacement)
            }
            lastLocation = currentLocation
        case .ended:
            break
        default:
            break
        }
    }
    
    func handlePinch(_ gestureRecognize: UIPinchGestureRecognizer) {
        
        switch gestureRecognize.state {
        case .began:
            lastCameraYFov = self.babySCNView.pointOfView?.camera?.yFov
            break
        case .changed:
            
            let deltaScale = Double(gestureRecognize.scale)
            
            var newYFov: Double = self.lastCameraYFov
            if deltaScale > Double(1) {
                newYFov = self.lastCameraYFov - Double(pow(deltaScale, 2) * 2)
            } else if deltaScale < Double(1) {
                newYFov = self.lastCameraYFov + Double(pow(1/deltaScale, 2) * 2)
            }
            if newYFov < Double(1) {
                newYFov = Double(1)
            } else if newYFov > Double(120) {
                newYFov = Double(120)
            }
            print("YFovOffset: \(newYFov - self.lastCameraYFov)")
            SCNTransaction.animateWithDuration(0.0) {
                self.babySCNView.pointOfView?.camera?.yFov = newYFov
            }
        case .ended:
            break
        default:
            break
        }
    }
    
    /// find main skeleton node
    ///
    /// - Parameter scene: SCNNode
    func findAndSetSkeleton(_ scene: SCNNode) {
        scene.enumerateChildNodes { child, stop in
            if child.skinner != nil {
                print("main skeleton node: \(child.name)")
                self.mainSkeleton = child.skinner!.skeleton
                print("main skeleton: \(self.mainSkeleton)")
                stop.initialize(to: true)
            }
        }
    }
    
    // MARK: - Setup scene
    
    func setupScene(from: URL?) {
        
        guard let from = from else {
            print("DAE文件不存在!")
            return
        }
        
        var scene: SCNScene?
        do {
            scene = try SCNScene(url: from, options: [SCNSceneSource.LoadingOption.strictConformance : ""])
        } catch {
            print("load scene file failure!")
            scene = nil
        }
        guard let babyScene = scene else {
            return
        }
        
//        let babyScene = SCNScene(named: "art.scnassets/models/baby_face.dae")!
        
        babyScene.rootNode.enumerateChildNodes({ (child, stop) in
            
            //            for key in child.animationKeys {
            //                let animation = child.animationForKey(key)!
            //                animation.usesSceneTimeBase = false
            //                animation.repeatCount = 1
            //                child.addAnimation(animation, forKey: key)
            //            }
            
            //            child.removeAllAnimations()
            //            print("node name: \(child.name)")
        })
        
        self.mainSkeleton = babyScene.rootNode
        
        self.mainSkeleton!.isPaused = true
        
        for node in babyScene.rootNode.childNodes {
            if let _ = node.geometry {
                self.babyNode = node
            }
        }
        
        guard let _ = self.babyNode else {
            return
        }
        
        // add a point light
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = SCNLight.LightType.omni
        lightNode.light?.color = UIColor(white: 0.75, alpha: 1.0)
        lightNode.position = SCNVector3Make(0, -100, 100)
        babyScene.rootNode.addChildNode(lightNode)
        
        let material = SCNMaterial()
        material.locksAmbientWithDiffuse = true
        let diffuse = "BabyFaceTexture"
        material.diffuse.contents = UIImage(named: diffuse)
        self.babyNode.geometry?.firstMaterial = material
        
        self.babyNode.position = SCNVector3Zero
        
        // animate the 3d object
        //        baby.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 1, z: 0, duration: 1)))
        //        babyScene.rootNode.runAction(SCNAction.rotateToX(0, y: -1, z: 0, duration: 0.1, shortestUnitArc: true))
        //        babyScene.rootNode.runAction(SCNAction.scaleTo(0.5, duration: 0.1))
        //        babyScene.rootNode.runAction(SCNAction.moveTo(SCNVector3(x: -100, y: 200, z: 0), duration: 0.1))
        
        // set the scene to the view
        babySCNView.scene = babyScene
        
        // allows the user to manipulate the camera
//        babySCNView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        //        babySCNView.showsStatistics = true
        
        babySCNView.autoenablesDefaultLighting = true
        
        // configure the view
        babySCNView.backgroundColor = UIColor.clear
        
        // add a tap gesture recognizer
        //        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        //        babySCNView.addGestureRecognizer(tapGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        babySCNView.addGestureRecognizer(panGesture)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        babySCNView.addGestureRecognizer(pinchGesture)
    }
    
    func setupCamera() {
        guard let pov = self.babySCNView.pointOfView else {
            return
        }
        pov.camera?.yFov = 90
        pov.eulerAngles = SCNVector3Zero
        pov.position = SCNVector3(0.0, 0.0, 200)
        
        //        var minVec = SCNVector3Zero
        //        var maxVec = SCNVector3Zero
        //        if mainSkeleton.boundingBox(&minVec, max: &maxVec) {
        //            let bound = SCNVector3(x: maxVec.x - minVec.x, y: maxVec.y - minVec.y, z: maxVec.z - minVec.z)
        //            print("mainSkeleton.bound: \(bound)")
        //
        ////            cameraYHandle.pivot = SCNMatrix4MakeTranslation(bound.x / 2, bound.y / 2, bound.z / 2)
        //        }
        
        cameraXHandle.addChildNode(pov)
        cameraYHandle.addChildNode(cameraXHandle)
        
        babySCNView.scene?.rootNode.addChildNode(cameraYHandle)
    }
    
    // MARK: - Managing the Camera
    
    func panCamera(_ direction: float2) {
        //        if lockCamera {
        //            return
        //        }
        var directionToPan = direction
        
        directionToPan *= float2(1.0, -1.0)
        
        let F = SCNFloat(0.005)
        
        // Make sure the camera handles are correctly reset (because automatic camera animations may have put the "rotation" in a weird state.
        SCNTransaction.animateWithDuration(0.0) {
            self.cameraYHandle.removeAllActions()
            self.cameraXHandle.removeAllActions()
            
            if self.cameraYHandle.rotation.y < 0 {
                self.cameraYHandle.rotation = SCNVector4(0, 1, 0, -self.cameraYHandle.rotation.w)
            }
            
            if self.cameraXHandle.rotation.x < 0 {
                self.cameraXHandle.rotation = SCNVector4(1, 0, 0, -self.cameraXHandle.rotation.w)
            }
        }
        
        // Update the camera position with some inertia.
        let yAngle = (min(SCNFloat(M_PI_4 * 2), max(SCNFloat(-M_PI_4 * 2), self.cameraYHandle.rotation.w - SCNFloat(directionToPan.x) * F)))
        let xAngle = (max(SCNFloat(-M_PI_4 * 1), min(SCNFloat(M_PI_4 * 1), self.cameraXHandle.rotation.w + SCNFloat(directionToPan.y) * F)))
        SCNTransaction.animateWithDuration(0.0) {
            self.cameraYHandle.rotation = SCNVector4(0, 1, 0, yAngle)
            self.cameraXHandle.rotation = SCNVector4(1, 0, 0, xAngle)
        }
    }
    
    func translateCamera(_ displament: float2) {
        SCNTransaction.animateWithDuration(0.0) {
            self.babySCNView.pointOfView?.position.x -= displament.x
            self.babySCNView.pointOfView?.position.y += displament.y
        }
    }
}

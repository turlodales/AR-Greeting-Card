//
//  ARCard.swift
//  LoginGuide
//
//  This file implements a class ARCard, which is the model of DetailARViewController.
//  It contains all the data and properties for the AR object we want to display.

import UIKit
import ARKit
import SceneKit

// AR class for card
class ARCard: SCNNode {
    let width: Float
    let height: Float
    
    var isOpen = false
    var animationDuration = 3.0
    var coverFrontNode: SCNNode?
    var coverBackNode: SCNNode?
    var contentFrontNode: SCNNode?
    var contentBackNode: SCNNode?
    
    var coverFrontImage: UIImage?
    var coverBackImage: UIImage?
    var contentFrontImage: UIImage?
    var contentBackImage: UIImage?
    
    // constructor
    init(width: Float, height: Float) {
        self.width = width
        self.height = height
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // set two images for cover page
    func setCover(front: UIImage, back: UIImage) {
        let frontPlane = SCNPlane(image: front, width: width, height: height)
        coverFrontNode = SCNNode(geometry: frontPlane)
        coverFrontNode?.physicsBody = frontPlane.staticBody
        coverFrontNode?.eulerAngles = SCNVector3Make(-Float.pi / 2, 0, 0)
        coverFrontNode?.pivot = SCNMatrix4MakeTranslation(-width / 2, 0, 0)
        addChildNode(coverFrontNode!)
        
        let backPlane = SCNPlane(image: back, width: width, height: height)
        coverBackNode = SCNNode(geometry: backPlane)
        coverBackNode?.physicsBody = backPlane.staticBody
        coverBackNode?.eulerAngles = SCNVector3Make(-Float.pi / 2, 0, -Float.pi)
        coverBackNode?.pivot = SCNMatrix4MakeTranslation(width / 2, 0, 0)
        addChildNode(coverBackNode!)
        
        coverFrontImage = front
        coverBackImage = back
        coverFrontNode?.position = SCNVector3Make((coverFrontNode?.position.x)!, (coverFrontNode?.position.y)! + 0.001, (coverFrontNode?.position.z)!)
        coverBackNode?.position = SCNVector3Make((coverBackNode?.position.x)!, (coverBackNode?.position.y)! + 0.001, (coverBackNode?.position.z)!)
    }
    
    // set two images for content page
    func setContent(front: UIImage, back: UIImage) {
        let frontPlane = SCNPlane(image: front, width: width, height: height)
        contentFrontNode = SCNNode(geometry: frontPlane)
        contentFrontNode?.physicsBody = frontPlane.staticBody
        contentFrontNode?.eulerAngles = SCNVector3Make(-Float.pi / 2, 0, 0)
        contentFrontNode?.pivot = SCNMatrix4MakeTranslation(-width / 2, 0, 0)
        addChildNode(contentFrontNode!)
        
        let backPlane = SCNPlane(image: back, width: width, height: height)
        contentBackNode = SCNNode(geometry: backPlane)
        contentBackNode?.physicsBody = backPlane.staticBody
        contentBackNode?.eulerAngles = SCNVector3Make(-Float.pi / 2, 0, -Float.pi)
        contentBackNode?.pivot = SCNMatrix4MakeTranslation(width / 2, 0, 0)
        addChildNode(contentBackNode!)
        
        contentFrontImage = front
        contentBackImage = back
    }
    
    // Handle action when user tapped on the opend card
    func respondsToTap() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.animateCover()
            self.coverFrontNode?.eulerAngles.z = self.isOpen ? 0 : Float.pi
            self.coverBackNode?.eulerAngles.z = self.isOpen ? -Float.pi : 0
            self.isOpen = self.isOpen ? false : true
        }
    }
    
    // Animation for handling action
    private func animateCover() {
        let fronAnimation = CAKeyframeAnimation(keyPath: "eulerAngles.z")
        fronAnimation.duration = self.animationDuration
        fronAnimation.keyTimes = [0.0, 1.0]
        fronAnimation.values = !isOpen ? [0, Float.pi] : [Float.pi, 0]
        fronAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)]
        coverFrontNode?.addAnimation(fronAnimation, forKey: "animate cover front")
        
        let backAnimation = CAKeyframeAnimation(keyPath: "eulerAngles.z")
        backAnimation.duration = self.animationDuration
        backAnimation.keyTimes = [0.0, 1.0]
        backAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)]
        backAnimation.values = !isOpen ? [-Float.pi, 0] : [0, -Float.pi]
        coverBackNode?.addAnimation(backAnimation, forKey: "animate cover back")
    }
    
}

extension SCNPlane {
    
    var staticBody: SCNPhysicsBody {
        let shape = SCNPhysicsShape(geometry: self, options: nil)
        return SCNPhysicsBody(type: .static, shape: shape)
    }
    
    convenience init(image: UIImage, width: Float, height: Float) {
        self.init(width: CGFloat(width), height: CGFloat(height))
        let frontMaterial = SCNMaterial()
        frontMaterial.diffuse.contents = image
        materials = [frontMaterial]
    }
}


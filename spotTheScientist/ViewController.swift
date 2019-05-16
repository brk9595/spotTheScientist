//
//  ViewController.swift
//  spotTheScientist
//
//  Created by Bharath  Raj kumar on 12/05/19.
//  Copyright © 2019 Bharath Raj Kumar. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var scientits = [String:Scientist]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
    
        self.loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "Scientists", bundle: nil) else
        {
            fatalError("Couldn't load Images")
        }
        
        configuration.trackingImages = trackingImages
        

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let imageAnchor = anchor as? ARImageAnchor else {
            return nil
        }
        guard let name = imageAnchor.referenceImage.name else {
            return nil
        }
        guard let scientist = scientits[name] else {
            return nil
        }
        
        print(scientist.name)
        print(scientist.bio)
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
        plane.firstMaterial?.diffuse.contents = UIColor.clear
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x =  -.pi / 2
        
        let node = SCNNode()
        node.addChildNode(planeNode)
        
        let spacing: Float = 0.005
        let titleNode = textNode(scientist.name, font: UIFont.boldSystemFont(ofSize: 10))
        titleNode.pivotOnTopLeft()
        
        titleNode.position.x += Float(plane.width / 2) + spacing
        titleNode.position.y += Float(plane.height / 2) + spacing
        
        let bioNode = textNode(scientist.bio, font: UIFont.systemFont(ofSize: 4), maxWidth: 100)
        bioNode.pivotOnTopLeft()
        
        bioNode.position.x += Float(plane.width / 2) + spacing
        bioNode.position.y = titleNode.position.y - titleNode.height / 4 - spacing
        
        
        let flag = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.width / 8 * 5)
        
        flag.firstMaterial?.diffuse.contents = UIImage(named: scientist.country)
        
        let flagNode = SCNNode(geometry: flag)
        flagNode.pivotOnTopCenter()
        flagNode.position.y -= Float(plane.height / 2) + spacing
        planeNode.addChildNode(flagNode)
        
        planeNode.addChildNode(titleNode)
        planeNode.addChildNode(bioNode)
        return node
    }
    
    func loadData()
    {
        guard let url = Bundle.main.url(forResource: "scientists", withExtension: "json")
            else
        {
            fatalError("Unable to find json")
        }
        
        guard let data = try? Data(contentsOf: url)
        else
        {
            fatalError("Unable to load json")
        }
        
        let decoder = JSONDecoder()
        guard let loadScientists = try? decoder.decode([String:Scientist].self, from: data)
        else
        {
            fatalError("unable to Decode")
        }
        
        scientits = loadScientists
    }
    
    
    func textNode(_ string: String,font: UIFont,maxWidth: Int? = nil) -> SCNNode
    {
        let text = SCNText(string: string, extrusionDepth: 0.0)
        text.flatness = 0.1
        text.font = font
        
        if let maxWidth = maxWidth
        {
            text.containerFrame = CGRect(origin: .zero, size: CGSize(width: maxWidth, height: 500))
            text.isWrapped = true
        }
        
        let textNode = SCNNode(geometry: text)
        textNode.scale = SCNVector3(0.002, 0.002, 0.002)
        return textNode
    }
  
}

extension SCNNode
{
    var width : Float
    {
    return (boundingBox.max.x - boundingBox.max.y) * scale.x
    }
    
    var height : Float
    {
        return (boundingBox.max.x - boundingBox.max.y) * scale.x
    }
    
    func pivotOnTopLeft()
    {
        let (min,max) = boundingBox
        pivot = SCNMatrix4MakeTranslation(min.x, (max.y - min.y) + min.y, 0)
    }
    
    func pivotOnTopCenter()
    {
        let (min,max) = boundingBox
        pivot = SCNMatrix4MakeTranslation((max.x - min.x) / 2 + min.x, (max.y - min.y) + min.y, 0)
    }
}

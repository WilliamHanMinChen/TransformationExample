//
//  ViewController.swift
//  TransformationMatrixExample
//
//  Created by William Chen on 2023/3/19.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    //View
    @IBOutlet weak var backgroundView: UIView!
    
    //Default transformation values (How much we move every time we tap the button)
    
    //In m
    var DEFAULT_X_TRANSLATION : Float = 0.0005
    var DEFAULT_Y_TRANSLATION : Float = 0.0005
    var DEFAULT_Z_TRANSLATION : Float = 0.0005
    
    
    //Rapid fire interval in seconds (How often do we trigger a button event when the user holds down the button)
    var RAPID_FIRE_INTERVAL: Double = 0.005
    
    
    @IBOutlet weak var scaleSlider: UISlider!
    
    @IBOutlet weak var rXSlider: UISlider!
    
    @IBOutlet weak var rYSlider: UISlider!
    
    @IBOutlet weak var rZSlider: UISlider!
    
    @IBOutlet weak var forwardButton: UIButton!
    
    @IBOutlet weak var rightButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var leftButton: UIButton!
    
    @IBOutlet weak var raiseButton: UIButton!
    
    @IBOutlet weak var lowerButton: UIButton!
    
    //Values
    var maxScaleVal : Int = 10
    var defaultScaleVal : Int = 1
    
    
    //Reference to our added object
    var objectNode : SCNReferenceNode?
    
    //Button Tags
    let FORWARDBUTTONTAG: Int = 1
    let BACKBUTTONTAG: Int = 2
    let LEFTBUTTONTAG: Int = 3
    let RIGHTBUTTONTAG: Int = 4
    let RAISEBUTTONTAG: Int = 5
    let LOWERBUTTONTAG: Int = 6
    
    //Timers for button rapid fire
    var forwardButtonTimer: Timer?
    var backButtonTimer: Timer?
    var leftButtonTimer: Timer?
    var rightButtonTimer: Timer?
    var raiseButtonTimer: Timer?
    var lowerButtonTimer: Timer?
    
    //Counter to keep track of continuous rapid fire to scale transformation
    var forwardButtonCounter: Int = 0
    var backButtonCounter: Int = 0
    var leftButtonCounter: Int = 0
    var rightButtonCounter: Int = 0
    var raiseButtonCounter: Int = 0
    var lowerButtonCounter: Int = 0
    
    //Keeps track of previous scales to know how much more to scale
    var lastScale : Float = 1.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the background color
        backgroundView.layer.cornerRadius = 10
        
        backgroundView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        //Load the destination object
        //Model name
        let modelName = "tub"
        
        //Get the object
        guard let sceneURL = Bundle.main.url(forResource: modelName, withExtension: "scn", subdirectory: "art.scnassets"),
              let object = SCNReferenceNode(url: sceneURL) else {
                fatalError("can't load virtual object")
        }
        
        object.name = modelName
        
        object.load()
        
        // Set the scene to the view
        sceneView.scene.rootNode.addChildNode(object)
        
        //placing it in front of camera with 1 meter away from it
        object.transform = SCNMatrix4MakeTranslation(0, 0, -1)
        
        objectNode = object
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        //Before starting session, put this option in configuration
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
                configuration.sceneReconstruction = .mesh
        } else {
                // Handle device that doesn't support scene reconstruction
        }
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        setUpButtons()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let meshAnchor = anchor as? ARMeshAnchor else {
                return nil
            }

        let geometry = createGeometryFromAnchor(meshAnchor: meshAnchor)

        //apply occlusion material
        geometry.firstMaterial?.colorBufferWriteMask = []
        geometry.firstMaterial?.writesToDepthBuffer = true
        geometry.firstMaterial?.readsFromDepthBuffer = true
            

        let node = SCNNode(geometry: geometry)
        //change rendering order so it renders before  our virtual object
        node.renderingOrder = -1
        
        return node
    }
    
    // Taken from https://developer.apple.com/forums/thread/130599
    func createGeometryFromAnchor(meshAnchor: ARMeshAnchor) -> SCNGeometry {
        let meshGeometry = meshAnchor.geometry
        let vertices = meshGeometry.vertices
        let normals = meshGeometry.normals
        let faces = meshGeometry.faces
        
        // use the MTL buffer that ARKit gives us
        let vertexSource = SCNGeometrySource(buffer: vertices.buffer, vertexFormat: vertices.format, semantic: .vertex, vertexCount: vertices.count, dataOffset: vertices.offset, dataStride: vertices.stride)
        
        let normalsSource = SCNGeometrySource(buffer: normals.buffer, vertexFormat: normals.format, semantic: .normal, vertexCount: normals.count, dataOffset: normals.offset, dataStride: normals.stride)
        // Copy bytes as we may use them later
        let faceData = Data(bytes: faces.buffer.contents(), count: faces.buffer.length)
        
        // create the geometry element
        let geometryElement = SCNGeometryElement(data: faceData, primitiveType: primitiveType(type: faces.primitiveType), primitiveCount: faces.count, bytesPerIndex: faces.bytesPerIndex)
        
        return SCNGeometry(sources: [vertexSource, normalsSource], elements: [geometryElement])
    }

    func primitiveType(type: ARGeometryPrimitiveType) -> SCNGeometryPrimitiveType {
            switch type {
                case .line: return .line
                case .triangle: return .triangles
            default : return .triangles
            }
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
    //MARK: Storyboard actions
    
    ///This function scales the object in all axis, if you want to scale only in one, call SCNMatrix4MakeScale with either only x, y or z value
    @IBAction func scaleSliderChanged(_ sender: Any) {
        guard let slider = sender as? UISlider else {
            return
        }
        
        //Change the scale
        let scale = slider.value
        
        objectNode?.scale = SCNVector3(scale,scale,scale)
        
        
        
    }
    
    @IBAction func rXSliderChanged(_ sender: Any) {
        guard let slider = sender as? UISlider else {
            return
        }
        
        //Get the slider value
        let sliderValue = slider.value
        
        //Get our current euler angle vector
        guard let eulerVector = objectNode?.eulerAngles else {
            fatalError("No euler angle, is the node even added?")
        }
        
        //Get the rotation vector
        let rotationVector = SCNVector3Make(GLKMathDegreesToRadians(sliderValue), eulerVector.y, eulerVector.z)
        
        //Update our node's angle
        objectNode?.eulerAngles = rotationVector
    }
    
    @IBAction func rYSliderChanged(_ sender: Any) {
        guard let slider = sender as? UISlider else {
            return
        }
        
        //Get the slider value
        let sliderValue = slider.value
        
        //Get our current euler angle vector
        guard let eulerVector = objectNode?.eulerAngles else {
            fatalError("No euler angle, is the node even added?")
        }
        
        //Get the rotation vector
        let rotationVector = SCNVector3Make(eulerVector.x, GLKMathDegreesToRadians(sliderValue), eulerVector.z)
        
        //Update our node's angle
        objectNode?.eulerAngles = rotationVector
    }
    
    @IBAction func rZSliderChanged(_ sender: Any) {
        guard let slider = sender as? UISlider else {
            return
        }
        
        //Get the slider value
        let sliderValue = slider.value
        
        //Get our current euler angle vector
        guard let eulerVector = objectNode?.eulerAngles else {
            fatalError("No euler angle, is the node even added?")
        }
        
        //Get the rotation vector
        let rotationVector = SCNVector3Make(eulerVector.x, eulerVector.y, GLKMathDegreesToRadians(sliderValue))
        
        //Update our node's angle
        objectNode?.eulerAngles = rotationVector
    }
    
    
    //MARK: Methods to handle Translation, Transformation and Rotation
 
    /// SCNMatrix4MakeTranslation(x, y, z)
    ///x = Forward and back
    ///y = Altitude
    ///z = Left and right
    ///Translating the object forward
    @objc func moveRight(){
        
        //Increase our rapid fire counter
        forwardButtonCounter += 1
        //Get our node's transformation matrix
        guard let initialMatrix = objectNode?.transform else {
            fatalError("Object node does not have a transform matrix, is it even added to the scene?")
        }
        //Create a transformation matrix
        let transformationMatrix = SCNMatrix4MakeTranslation(Float(sqrt(Double(forwardButtonCounter))) * DEFAULT_X_TRANSLATION, 0, 0)
        //Multiply the two together to get our new transformation matrix
        let resultMatrix = SCNMatrix4Mult(initialMatrix, transformationMatrix)
        
        //Start an animation
        SCNTransaction.begin()
        SCNTransaction.animationDuration = RAPID_FIRE_INTERVAL
        //Update our object's matrix
        objectNode?.transform = resultMatrix
        SCNTransaction.commit()
        
        print("Moving right")
        
        
    }
    
    @objc func moveLeft(){
        
        //Increase our rapid fire counter
        backButtonCounter += 1
        //Get our node's transformation matrix
        guard let initialMatrix = objectNode?.transform else {
            fatalError("Object node does not have a transform matrix, is it even added to the scene?")
        }
        //Create a transformation matrix
        let transformationMatrix = SCNMatrix4MakeTranslation(-Float(sqrt(Double(backButtonCounter))) * DEFAULT_X_TRANSLATION, 0, 0)
        //Multiply the two together to get our new transformation matrix
        let resultMatrix = SCNMatrix4Mult(initialMatrix, transformationMatrix)
        //Start an animation
        SCNTransaction.begin()
        SCNTransaction.animationDuration = RAPID_FIRE_INTERVAL
        //Update our object's matrix
        objectNode?.transform = resultMatrix
        SCNTransaction.commit()
        
        print("Moving left")
    }
    
    @objc func moveForward(){
        //Increase our rapid fire counter
        leftButtonCounter += 1
        //Get our node's transformation matrix
        guard let initialMatrix = objectNode?.transform else {
            fatalError("Object node does not have a transform matrix, is it even added to the scene?")
        }
        //Create a transformation matrix
        let transformationMatrix = SCNMatrix4MakeTranslation(0, 0,-Float(sqrt(Double(leftButtonCounter))) * DEFAULT_Y_TRANSLATION)
        
        //Multiply the two together to get our new transformation matrix
        let resultMatrix = SCNMatrix4Mult(initialMatrix, transformationMatrix)
        
        
        //Start an animation
        SCNTransaction.begin()
        SCNTransaction.animationDuration = RAPID_FIRE_INTERVAL
        //Update our object's matrix
        objectNode?.transform = resultMatrix
        SCNTransaction.commit()
        print("Moving forward")
    }
    
    @objc func moveBack(){
        //Increase our rapid fire counter
        rightButtonCounter += 1
        //Get our node's transformation matrix
        guard let initialMatrix = objectNode?.transform else {
            fatalError("Object node does not have a transform matrix, is it even added to the scene?")
        }
        //Create a transformation matrix
        let transformationMatrix = SCNMatrix4MakeTranslation(0, 0,Float(sqrt(Double(rightButtonCounter))) * DEFAULT_Y_TRANSLATION)
        
        //Multiply the two together to get our new transformation matrix
        let resultMatrix = SCNMatrix4Mult(initialMatrix, transformationMatrix)
        //Start an animation
        SCNTransaction.begin()
        SCNTransaction.animationDuration = RAPID_FIRE_INTERVAL
        //Update our object's matrix
        objectNode?.transform = resultMatrix
        SCNTransaction.commit()
        print("Moving back")
    }
    
    @objc func raise(){
        //Increase our rapid fire counter
        raiseButtonCounter += 1
        //Get our node's transformation matrix
        guard let initialMatrix = objectNode?.transform else {
            fatalError("Object node does not have a transform matrix, is it even added to the scene?")
        }
        //Create a transformation matrix
        let transformationMatrix = SCNMatrix4MakeTranslation(0, Float(sqrt(Double(raiseButtonCounter))) * DEFAULT_Z_TRANSLATION, 0)
        
        //Multiply the two together to get our new transformation matrix
        let resultMatrix = SCNMatrix4Mult(initialMatrix, transformationMatrix)
        //Start an animation
        SCNTransaction.begin()
        SCNTransaction.animationDuration = RAPID_FIRE_INTERVAL
        //Update our object's matrix
        objectNode?.transform = resultMatrix
        SCNTransaction.commit()
        print("Raising")
    }
    
    @objc func lower(){
        //Increase our rapid fire counter
        lowerButtonCounter += 1
        //Get our node's transformation matrix
        guard let initialMatrix = objectNode?.transform else {
            fatalError("Object node does not have a transform matrix, is it even added to the scene?")
        }
        //Create a transformation matrix
        let transformationMatrix = SCNMatrix4MakeTranslation(0, -Float(sqrt(Double(lowerButtonCounter))) * DEFAULT_Z_TRANSLATION, 0)
        
        //Multiply the two together to get our new transformation matrix
        let resultMatrix = SCNMatrix4Mult(initialMatrix, transformationMatrix)
        //Start an animation
        SCNTransaction.begin()
        SCNTransaction.animationDuration = RAPID_FIRE_INTERVAL
        //Update our object's matrix
        objectNode?.transform = resultMatrix
        SCNTransaction.commit()
        print("Lowering")
    }
}

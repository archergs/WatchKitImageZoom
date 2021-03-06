//
//  InterfaceController.swift
//  scrolltest WatchKit Extension
//
//  Created by Will Bishop on 9/2/18.
//  Copyright © 2018 Will Bishop. All rights reserved.
//

import WatchKit
import Foundation
import SpriteKit


class InterfaceController: WKInterfaceController, WKCrownDelegate {
	
	var zoomLevel: CGFloat = 1
	
	var previous = CGPoint()
	
	let scene = SKScene(fileNamed: "MyScene")
	@IBOutlet var skInterface: WKInterfaceSKScene!
	var imageNode = SKSpriteNode()
	let cameraNode = SKCameraNode()
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		
		
		cameraNode.position = CGPoint(x: WKInterfaceDevice.current().screenBounds.width / 2, y: WKInterfaceDevice.current().screenBounds.height / 2)
		scene?.addChild(cameraNode)
		scene?.camera = cameraNode
		// Present the scene
		
		scene?.children.forEach {node in
			if node.name == "image"{
				cameraNode.position = node.position
				if let shape = node as? SKSpriteNode{
					imageNode = shape
					let image = UIImage(named: "comic")!
					let tex = SKTexture(image: image)
					imageNode.run(SKAction.setTexture(tex))
					
					let newSize = CGSize(width:  WKInterfaceDevice.current().screenBounds.width, height: image.size.height)
					
					imageNode.run(SKAction.resize(toWidth: newSize.width, height: newSize.height * (WKInterfaceDevice.current().screenBounds.width / image.size.width), duration: 0))
				}
				
			}
		}
		self.skInterface.presentScene(scene)
		
		// Use a preferredFramesPerSecond that will maintain consistent frame rate
		self.skInterface.preferredFramesPerSecond = 30
		
		crownSequencer.delegate = self
		
		// Configure interface objects here.
	}
	
	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()
		
		crownSequencer.focus()
	}
	
	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
		super.didDeactivate()
	}
	
	
	@IBAction func didPan(_ sender: WKPanGestureRecognizer) {
		if(sender.state == .ended)
		{
			previous = CGPoint()
		} else{
			
			var translation = sender.translationInObject()
			
			translation.y *= -1 //Panning to the right would make it go left, need to * -1
			translation.x = translation.x * cameraNode.xScale
			translation.y = translation.y * cameraNode.yScale
			
			
			print((cameraNode.frame.maxX - imageNode.frame.maxX) + (imageNode.frame.width / 2) * zoomLevel)

			if ((cameraNode.frame.minX - imageNode.frame.minX) - (imageNode.frame.width / 2) * zoomLevel) > 0{
				if (cameraNode.frame.maxX - imageNode.frame.maxX) + (imageNode.frame.width / 2) * zoomLevel < 0{
					cameraNode.position.x -= translation.x - self.previous.x
				} else{
					cameraNode.position.x = imageNode.frame.maxX - (imageNode.frame.width / 2) * zoomLevel
				}
				
			} else{
				cameraNode.position.x = imageNode.frame.minX + (imageNode.frame.width / 2) * zoomLevel //Stick to left
			}
			
			
			if (cameraNode.frame.minY - imageNode.frame.minY) - (imageNode.frame.width / 2) * zoomLevel > 0{
				if ((cameraNode.frame.maxY - imageNode.frame.maxY) + (imageNode.frame.width / 2) * zoomLevel) < 0{
					cameraNode.position.y -= translation.y - self.previous.y
				} else{
					cameraNode.position.y = imageNode.frame.maxY - (imageNode.frame.width / 2) * zoomLevel - 0.1
				}
			} else{
				cameraNode.position.y = imageNode.frame.minY + (imageNode.frame.width / 2) * zoomLevel
			}
			if (cameraNode.frame.minY - imageNode.frame.minY) - (imageNode.frame.width / 2) * zoomLevel < 1{
				print("Equal")
				cameraNode.position.y = imageNode.frame.minY + (imageNode.frame.width / 2) * zoomLevel + 0.1
			}
		
			
			self.previous = translation
		}
		
	}
	func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
		
		if zoomLevel > 1{
			zoomLevel = 1
		}
		print(zoomLevel)
		if rotationalDelta < 0 && zoomLevel <= 1{ //Zoom out
			zoomLevel += 0.01 * zoomLevel
			let zoomInAction = SKAction.scale(to: zoomLevel, duration: 0)
			cameraNode.run(zoomInAction)
		}
		if rotationalDelta > 0{ //Zoom in
			zoomLevel -= 0.01 * zoomLevel
			let zoomInAction = SKAction.scale(to: zoomLevel, duration: 0)
			cameraNode.run(zoomInAction)
		}
		
	}
	
	
}
extension CGPoint{
	static func +=(left: CGPoint, right: CGPoint) -> CGPoint{
		var copy = left
		copy.x += right.x
		copy.y += right.y
		return copy
	}
	static func -=(left: CGPoint, right: CGPoint) -> CGPoint{
		var copy = left
		copy.x -= right.x
		copy.y -= right.y
		return copy
	}
	static func -(left: CGPoint, right: CGPoint) -> CGPoint{
		var copy = left
		copy.x -= right.x
		copy.y -= right.y
		return copy
	}
	static func -(left: CGPoint, right: CGFloat) -> CGPoint{
		var copy = left
		copy.x -= right
		copy.y -= right
		return copy
	}
	static func +(left: CGPoint, right: CGPoint) -> CGPoint{
		var copy = left
		copy.x += right.x
		copy.y += right.y
		return copy
	}
}

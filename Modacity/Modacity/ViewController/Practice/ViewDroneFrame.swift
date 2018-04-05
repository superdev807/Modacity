 //
//  ViewDroneFrame.swift
//  Modacity
//
//  Created by Perfect Engineer on 1/11/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

protocol MetrodroneUIDelegate : class {
    func setSelectedIndex(_ index: Int)
    func getSelectedIndex() -> Int
}

class ViewDroneFrame: UIView, MetrodroneUIDelegate {

    var size = CGSize.zero
    
    let droneLetters = ["E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#"]
    
    let offsetForShadow = CGFloat(2)
    let selectedDroneSizeDifference = CGFloat(4)
    let offsetBetweenCenter = CGFloat(4)
    
    var selectedDronFrameIdx = -1
    var currentTouchedIdx = -1
    var delegate: DroneFrameDelegate?
    
    var niceImage: UIImage {

        let activeAreaSize = CGFloat((size.width - offsetForShadow * 2 - selectedDroneSizeDifference * 2))
        let kThickness = size.width / 6.0
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let gc = UIGraphicsGetCurrentContext()!
        
        for al in 0..<12 {
            
            var radius = (activeAreaSize - kThickness) / 2
            
            if al == selectedDronFrameIdx {
                radius = radius + self.selectedDroneSizeDifference / 2
            }
            
            gc.addArc(center: CGPoint(x: size.width/2, y: size.height/2),
                      radius: radius,
                      startAngle: CGFloat(Double.pi / 6 * Double(al)),
                      endAngle: CGFloat(Double.pi / 6 * Double(al + 1) - Double.pi / 60),
                      clockwise: false)

            if al == selectedDronFrameIdx {
                gc.setLineWidth(kThickness + self.selectedDroneSizeDifference)
            } else {
                gc.setLineWidth(kThickness)
            }
            
            gc.setLineCap(.butt)
            gc.replacePathWithStrokedPath()
            
            let path = gc.path!
            
            gc.setShadow(
                offset: CGSize(width: 0, height: 2),
                blur: 4,
                color: UIColor.black.alpha(0.5).cgColor
            )
            
            gc.beginTransparencyLayer(auxiliaryInfo: nil)
            
            gc.saveGState()
            
            let rgb = CGColorSpaceCreateDeviceRGB()
            
            var colors = [Color(hexString: "0x343351").cgColor, Color(hexString: "0x343351").cgColor] as CFArray
            if al == selectedDronFrameIdx {
                colors = [Color(hexString: "0x2B67F5").cgColor, Color(hexString: "0x6815CE").cgColor] as CFArray
            }
            
            let gradient = CGGradient(
                colorsSpace: rgb,
                colors: colors,
                locations: [CGFloat(0), CGFloat(1)])!
            
            let bbox = path.boundingBox
            let startP = bbox.origin
            var endP = CGPoint(x: bbox.maxX, y: bbox.maxY);
            if (bbox.size.width > bbox.size.height) {
                endP.y = startP.y
            } else {
                endP.x = startP.x
            }
            
            gc.clip()
            
            gc.drawLinearGradient(gradient, start: startP, end: endP,
                                  options: CGGradientDrawingOptions(rawValue: 0))
            
            gc.restoreGState()
            
            gc.addPath(path)
            
            gc.setLineWidth(0)
            gc.setLineJoin(.miter)
            UIColor.clear.setStroke()
            gc.strokePath()
            
            gc.endTransparencyLayer()
            
        }
        
        gc.setFillColor(Color(hexString: "0x3E405B").cgColor)
        gc.fillEllipse(in: CGRect(x: offsetForShadow + selectedDroneSizeDifference + kThickness + offsetBetweenCenter,
                                  y: offsetForShadow + selectedDroneSizeDifference + kThickness + offsetBetweenCenter,
                                  width: (activeAreaSize - size.width / 6 * 2 - offsetBetweenCenter * 2),
                                  height: (activeAreaSize - size.width / 6 * 2 - offsetBetweenCenter * 2)))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    override func draw(_ rect: CGRect) {
        size = rect.size
        niceImage.draw(at:.zero)
        drawDroneLetters(rect: rect)
    }
    
    func drawDroneLetters(rect: CGRect) {
        
        var angle = Double.pi / 12
        let center = CGPoint(x: rect.size.width / 2, y: rect.size.height / 2)
        let radius = CGFloat((size.width - offsetForShadow * 2 - selectedDroneSizeDifference * 2) / 2 - size.width / 12.0)//rect.size.width / 2 - 3 - (rect.size.width / 12)
        
        for idx in 0..<self.droneLetters.count {
            let letter = self.droneLetters[idx]
            let textFont = UIFont(name: "Lato-Regular", size: 14)!
            let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            textStyle.alignment = .center
            let textFontAttributes:[NSAttributedStringKey : Any] = [
                .font: textFont,
                .paragraphStyle:textStyle,
                .foregroundColor: (idx == selectedDronFrameIdx) ? Color.white : Color.white.alpha(0.7),
                ]
            let point = CGPoint(x:center.x + radius * CGFloat(cos(angle)), y: center.y + radius * CGFloat(sin(angle)))
            letter.draw(in: CGRect(x: point.x - 20, y: point.y - 10, width: 40, height: 20), withAttributes: textFontAttributes)
            angle = angle + Double.pi / 6
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       let changed = updateDroneIndex(forEvent: event!)
       
        if (delegate != nil) {
            print("Touches now at \(selectedDronFrameIdx)")
            if (changed) { delegate?.selectedIndexChanged(newIndex: selectedDronFrameIdx) }
            delegate?.toneWheelNoteDown()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let changed = updateDroneIndex(forEvent: event!)
        print("Touches now at \(selectedDronFrameIdx)")
        if (delegate != nil) {
            if (changed) {
                delegate?.selectedIndexChanged(newIndex: selectedDronFrameIdx)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touches now at \(selectedDronFrameIdx)")
        if (delegate != nil) {
            delegate?.toneWheelNoteUp()
        }
    }
    
    func setDelegate(_ del: DroneFrameDelegate) {
        self.delegate = del
        del.UIDelegate = self
    }
    
    func updateVisuals() {
        self.setNeedsDisplay()
    }
    
    func getSelectedIndex() -> Int {
        return selectedDronFrameIdx
    }
    
    func setSelectedIndex(_ index: Int) {
        self.selectedDronFrameIdx = index
        updateVisuals()
    }
    
    //func detectDroneIndex(forEvent: UIEvent) -> Int {
    func updateDroneIndex(forEvent: UIEvent) -> Bool {
        var returnIndex = -1
        var changed: Bool = false
        
        if let touch = forEvent.allTouches?.first {
            let touchPoint = touch.location(in: self)
            let dx = touchPoint.x - self.frame.size.width / 2
            let dy = touchPoint.y - self.frame.size.height / 2
            if sqrt(Double(dx) * Double(dx) + Double(dy) * Double(dy)) > Double(self.frame.size.width / 4) {
                var angle = Double.pi / 2
                if dx > 0 {
                    if dy >= 0 {
                        angle = atan(Double(dy) / Double(dx))
                    } else {
                        angle = Double.pi * 2 - atan(Double(abs(dy)) / Double(dx))
                    }
                } else if dx < 0 {
                    if dy >= 0 {
                        angle = Double.pi - atan(Double(dy) / Double(abs(dx)))
                    } else {
                        angle = Double.pi + atan(Double((dy)) / Double(dx))
                    }
                } else {
                    if dy >= 0 {
                        angle = Double.pi / 2
                    } else {
                        angle = Double.pi / 2 * (-1)
                    }
                }
                returnIndex = Int(angle / Double.pi * 6)
            }
            else {
                // no selected drone
                returnIndex = -1
                //return false
            }
        }
        changed = (returnIndex != self.selectedDronFrameIdx)
        
        self.selectedDronFrameIdx = returnIndex
        
        if (changed) { setNeedsDisplay() }
        return changed
    }

}

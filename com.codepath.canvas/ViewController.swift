//
//  ViewController.swift
//  com.codepath.canvas
//
//  Created by Savio Tsui on 11/3/16.
//  Copyright © 2016 Savio Tsui. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var parentView: UIView!
    @IBOutlet weak var trayView: UIView!
    @IBOutlet weak var arrow: UIImageView!

    fileprivate var initialTrayViewCenter: CGPoint!
    fileprivate var openTrayViewCenter: CGPoint!
    fileprivate var closedTrayViewCenter: CGPoint!

    fileprivate var newlyCreatedFace: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        openTrayViewCenter = CGPoint(x: trayView.center.x, y: trayView.center.y)
        closedTrayViewCenter = CGPoint(x: trayView.center.x, y: trayView.frame.maxY + trayView.frame.height / 2 - (arrow.frame.height + 16))

        print("openTrayViewCenter: \(openTrayViewCenter)")
        print("closedTrayViewCenter: \(closedTrayViewCenter)")

        animateClose()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onPanTrayViewGesture(_ panGestureRecognizer: UIPanGestureRecognizer) {
        // Absolute (x,y) coordinates in parent view (parentView should be
        // the parent view of the tray)
        let velocity = panGestureRecognizer.velocity(in: parentView)

        if panGestureRecognizer.state == UIGestureRecognizerState.began {
            // print("Gesture began at: \(point)")
            initialTrayViewCenter = trayView.center
        }
        else if panGestureRecognizer.state == UIGestureRecognizerState.changed {
            // print("Gesture changed at: \(point); velocity: \(velocity.y)")
            trayView.center = CGPoint(x: initialTrayViewCenter.x, y: initialTrayViewCenter.y + panGestureRecognizer.translation(in: parentView).y)
        }
        else if panGestureRecognizer.state == UIGestureRecognizerState.ended {
            // print("Gesture ended at: \(point); velocity: \(velocity.y)")
            if (velocity.y > 0) {
                // moving down
                animateClose()
            }
            else if (velocity.y < 0) {
                // moving up
                animateOpen()
            }
            else {
            }
        }
    }

    @IBAction func onTapTrayView(_ sender: UITapGestureRecognizer) {
        if (self.trayView.center == self.openTrayViewCenter) {
            animateClose()
        }
        else {
            animateOpen()
        }
    }

    @IBAction func onFacePan(_ panGestureRecognizer: UIPanGestureRecognizer) {

        if panGestureRecognizer.state == UIGestureRecognizerState.began {
            // Gesture recognizers know the view they are attached to
            let imageView = panGestureRecognizer.view as! UIImageView

            // Create a new image view that has the same image as the one currently panning
            newlyCreatedFace = UIImageView(image: imageView.image)
            newlyCreatedFace.isUserInteractionEnabled = true
            newlyCreatedFace.center = imageView.center
            newlyCreatedFace.center.y += trayView.frame.origin.y

            // recognize double tap
            let tap = UITapGestureRecognizer(target: self, action: #selector(onFaceDoubleTapped))
            tap.numberOfTapsRequired = 2
            newlyCreatedFace.addGestureRecognizer(tap)

            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(onFacePinch))
            newlyCreatedFace.addGestureRecognizer(pinch)

            UIView.animate(withDuration: 0.2, animations: {
                self.newlyCreatedFace.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
            })

            // Add the new face to the tray's parent view.
            view.addSubview(newlyCreatedFace)
        }
        else if panGestureRecognizer.state == UIGestureRecognizerState.changed {
            newlyCreatedFace.center = panGestureRecognizer.location(in: parentView)
        }
        else if panGestureRecognizer.state == UIGestureRecognizerState.ended {
            print("trayView.frame: \(self.trayView.frame); newlyCreatedFace.center: \(newlyCreatedFace.center)")

            if (self.trayView.frame.contains(newlyCreatedFace.center)) {
                newlyCreatedFace.removeFromSuperview()
            }

            UIView.animate(withDuration: 0.2, animations: {
                self.newlyCreatedFace.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
    }

    @objc fileprivate func onFaceDoubleTapped(_ tapGestureRecognizer: UITapGestureRecognizer) {
        print("onFaceDoubleTapped: removing face")
        let face = tapGestureRecognizer.view!
        UIView.animate(withDuration: 0.2, animations: {
            face.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }) { _ in
            face.removeFromSuperview()
        }
    }

    @objc fileprivate func onFacePinch(_ pinchGestureRecognizer: UIPinchGestureRecognizer) {
        print("onFacePinch: scaling face")
        let face = pinchGestureRecognizer.view!

        face.transform = CGAffineTransform(scaleX: pinchGestureRecognizer.scale, y: pinchGestureRecognizer.scale)
    }

    fileprivate func animateClose() {
        UIView.animate(
            withDuration: 0.7,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 2,
            options: UIViewAnimationOptions.allowAnimatedContent,
            animations: {
                self.trayView.center = self.closedTrayViewCenter
                self.arrow.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI))
            },
            completion: nil)
    }

    fileprivate func animateOpen() {
        UIView.animate(
            withDuration: 0.7,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 2,
            options: UIViewAnimationOptions.allowAnimatedContent,
            animations: {
                self.trayView.center = self.openTrayViewCenter
                self.arrow.transform = CGAffineTransform(rotationAngle: CGFloat(0))
        },
            completion: nil)
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

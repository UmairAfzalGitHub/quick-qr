//
//  LoaderViewController.swift
//  Photo Recovery
//
//  Created by Umair Afzal on 17/05/2025.
//

import Foundation
import UIKit
import Lottie

class LoaderViewController: UIViewController {
    
    var animationName = "contacts"
    var animationSpeed: CGFloat?
    
    private var animationView: LottieAnimationView!
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animationView = LottieAnimationView(name: animationName)
        animationView.animationSpeed = animationSpeed ?? 1
        // Make background transparent
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        // Set up container
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 200),
            containerView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        // Set up Lottie animation
        containerView.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            animationView.widthAnchor.constraint(equalToConstant: 150),
            animationView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
    }
}

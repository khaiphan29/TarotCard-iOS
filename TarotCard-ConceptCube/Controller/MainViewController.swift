//
//  MainViewController.swift
//  TarotCard-ConceptCube
//
//  Created by Phan Khai on 03/06/2022.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    
    var cardManager = CardManager()
    var cardImageViews: [UIImageView] = []
    
    var imageWidth: CGFloat?
    var imageHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        backButton.layer.cornerRadius = backButton.frame.height / 2.0
        shuffleButton.layer.cornerRadius = shuffleButton.frame.height / 2.0
        
        //CGFloat has precision base on device
        imageWidth = cardManager.getCardBack().size.width/1.5
        imageHeight = cardManager.getCardBack().size.height/1.5
        
        for _ in 0..<cardManager.count {
            setImageView()
        }
        
    }
    
    //MARK: - Set up ImageView
    
    func setImageView() {
        let image = cardManager.getCardBack()
        let imageView = UIImageView(image: image)
        
        setOriginalPosition(for: imageView)
        imageView.isUserInteractionEnabled = true
        self.view.addSubview(imageView)
        
        //Tap Gesture
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHandler(_: ))))
        
        //Pan Gesture
        imageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panHandler(_: ))))
        cardImageViews.append(imageView)
    }
    
    func setOriginalPosition (for imageView: UIImageView) {
        let screenSize = UIScreen.main.bounds
        let x = screenSize.width/2.0 - imageWidth!/2
        let y = screenSize.height/2.5 - imageWidth!/2
        let width = imageWidth!
        let height = imageHeight!
        
        //Set position
        UIView.animate(withDuration: 0.4) {
            imageView.frame = CGRect (x: x, y: y, width: width, height: height)
        }
    }
    
    //MARK: - Gesture Handler
    
    @objc func tapHandler(_ tapGesture: UITapGestureRecognizer){
        if let imageView = tapGesture.view as? UIImageView {
            let index = cardImageViews.firstIndex(of: imageView)!
            imageView.image = cardManager.getCardFront()[index]
        }
    }
    
    @objc func panHandler(_ panGesture: UIPanGestureRecognizer){
        if panGesture.state == .began {
            //print("began pan")
        } else if panGesture.state == .changed {
            let transition = panGesture.location(in: self.view)
            //print(transition.x)
            if let imageView = panGesture.view as? UIImageView {
                imageView.frame.origin.x = transition.x - imageView.frame.width/2.0
                imageView.frame.origin.y = transition.y - imageView.frame.height/2.0
            }
        } else if panGesture.state == .ended {
            //print("end pan")
        }
    }
    
    //MARK: - button processing

    @IBAction func shuffleButtonPressed(_ sender: UIButton) {
        cardManager.shuffle()
        for imageView in cardImageViews {
            setOriginalPosition(for: imageView)
            imageView.image = cardManager.getCardBack()
        }
    }
    @IBAction func backButtonPressed(_ sender: UIButton) {
        UserManager.currentUser = nil
        navigationController?.popViewController(animated: true)
    }
}

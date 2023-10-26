//
//  ViewController.swift
//  LetsPlay
//
//  Created by Maris Lagzdins on 30/06/2021.
//

import CoreLocation
import UIKit

class ViewController: UIViewController {
    private var locationManager: CLLocationManager?
    private var warningLabel: UILabel!
    private var locationLabel: UILabel!
    private var quizButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        createButtons()

        warningLabel.isHidden = false
        quizButton.isHidden = true

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
    }

    func createButtons() {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        locationLabel = UILabel()
        locationLabel.lineBreakMode = .byWordWrapping
        locationLabel.numberOfLines = 0
        locationLabel.textAlignment = .center
        locationLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        stackView.addArrangedSubview(locationLabel)

        quizButton = UIButton(type: .system)
        quizButton.setTitle("Quiz", for: .normal)
        quizButton.tintColor = .blue
        quizButton.addTarget(self, action: #selector(moveToQuiz), for: .touchUpInside)
        quizButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        stackView.addArrangedSubview(quizButton)

        warningLabel = UILabel()
        warningLabel.lineBreakMode = .byWordWrapping
        warningLabel.numberOfLines = 0
        warningLabel.textAlignment = .center
        warningLabel.text = "You must enable location service so that we could verify your location and allow you to play the Quiz."
        stackView.addArrangedSubview(warningLabel)

        NSLayoutConstraint.activate([
            quizButton.widthAnchor.constraint(equalToConstant: 200),
            quizButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    @objc
    func moveToQuiz() {
        let vc = QuizViewController()
        let nc = UINavigationController(rootViewController: vc)
        present(nc, animated: true)
    }

    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?) -> Void) {
        if let lastLocation = self.locationManager?.location {
            let geocoder = CLGeocoder()

            geocoder.reverseGeocodeLocation(lastLocation) { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?.first
                    completionHandler(firstLocation)
                }
                else {
                    completionHandler(nil)
                }
            }
        }
        else {
            completionHandler(nil)
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            warningLabel.text = "Detecting your location."
            warningLabel.isHidden = false
            quizButton.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                manager.requestLocation()
            }
        default:
            warningLabel.text = "You must enable location service so that we could verify your location and allow you to play the Quiz."
            warningLabel.isHidden = false
            quizButton.isHidden = true
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Found user's location: \(location)")
            lookUpCurrentLocation { [weak self] placemark in
                if let city = placemark?.locality {
                    self?.locationLabel.text = city
                } else {
                    self?.locationLabel.text = "Could not find out city name."
                }
                self?.warningLabel.isHidden = true
                self?.quizButton.isHidden = false
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}

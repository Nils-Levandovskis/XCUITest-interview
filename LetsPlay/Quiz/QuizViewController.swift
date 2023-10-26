//
//  QuizViewController.swift
//  LetsPlay
//
//  Created by Maris Lagzdins on 30/06/2021.
//

import AmazonIVSPlayer
import UIKit

class QuizViewController: UIViewController {
    private let player = IVSPlayer()
    private let url = URL(string: "https://4c62a87c1810.us-west-2.playback.live-video.net/api/video/v1/us-west-2.049054135175.channel.GHRwjPylmdXm.m3u8")!

    private var timeLabel: UILabel!
    private var question: Question? {
        didSet {
            questionLabel.text = question?.question
            button1.setTitle(question?.answers[0] ?? "?", for: .normal)
            button2.setTitle(question?.answers[1] ?? "?", for: .normal)
            button3.setTitle(question?.answers[2] ?? "?", for: .normal)
            button4.setTitle(question?.answers[3] ?? "?", for: .normal)

            button1.isHidden = false
            button2.isHidden = false
            button3.isHidden = false
            button4.isHidden = false

            resetButtonColor()
            enableAllButtons()
            setCorrectAnswerButton()

            if question != nil {
                questionIsAnswered = false
                questionCount += 1
            }
        }
    }

    private var correctAnswerButton: UIButton?
    private var timer: Timer?

    private var correctlyAnsweredQuestions = 0 {
        didSet { pointLabel.text = "\(correctlyAnsweredQuestions) / \(questionCount)" }
    }

    private var questionCount = 0 {
        didSet { pointLabel.text = "\(correctlyAnsweredQuestions) / \(questionCount)" }
    }
    
    private var questionIsAnswered: Bool = false
    private var stackView: UIStackView!

    private var playerView: IVSPlayerView!
    private var questionLabel: UILabel!
    private var pointLabel: UILabel!
    private var button1: UIButton!
    private var button2: UIButton!
    private var button3: UIButton!
    private var button4: UIButton!
    private var closeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Quiz"

        view.backgroundColor = .systemBackground

        setupTime()
        setupPlayer()
        setupControls()
        setupCloseButton()
        
        setupAccessibility()

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        timeLabel.text = "Quiz started \(dateFormatter.string(from: Date()))"

        player.load(url)
        
        #if TESTS
            mockLoadingQuestionData { question in
                self.question = question
            }
        #endif
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
        timer = nil
    }
    
    func setupAccessibility() {
        button1.accessibilityIdentifier = "button1"
        button2.accessibilityIdentifier = "button2"
        button3.accessibilityIdentifier = "button3"
        button4.accessibilityIdentifier = "button4"
        closeButton.accessibilityIdentifier = "close"
        pointLabel.accessibilityIdentifier = "points"
        questionLabel.accessibilityIdentifier = "question"
        timeLabel.accessibilityIdentifier = "time"
    }

    func setupTime() {
        timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.text = "-"
        timeLabel.textAlignment = .center
        timeLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        timeLabel.sizeToFit()
        
        view.addSubview(timeLabel)
        
        let navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
        
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: navigationBarHeight + 20),
            timeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            timeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }

    func setupPlayer() {
        player.delegate = self

        playerView = IVSPlayerView()
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.player = player
        view.addSubview(playerView)

        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 20),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            playerView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    func setupControls() {
        stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        view.addSubview(stackView)

        pointLabel = UILabel()
        pointLabel.text = "0 / 0"
        pointLabel.translatesAutoresizingMaskIntoConstraints = false
        pointLabel.numberOfLines = 0
        pointLabel.textAlignment = .center
        pointLabel.lineBreakMode = .byWordWrapping
        stackView.addArrangedSubview(pointLabel)

        questionLabel = UILabel()
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.numberOfLines = 0
        questionLabel.textAlignment = .center
        questionLabel.lineBreakMode = .byWordWrapping
        stackView.addArrangedSubview(questionLabel)

        let configuration = UIImage.SymbolConfiguration(textStyle: .caption1)

        let buttonStackView = UIStackView()
        buttonStackView.axis = .vertical
        buttonStackView.alignment = .center
        buttonStackView.distribution = .fillEqually
        stackView.addArrangedSubview(buttonStackView)

        button1 = UIButton(type: .system)
        button1.tag = 1
        button1.isHidden = true
        button1.contentHorizontalAlignment = .leading
        button1.translatesAutoresizingMaskIntoConstraints = false
        button1.contentEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 0)
        button1.imageEdgeInsets = .init(top: 0, left: -10, bottom: 0, right: 0)
        button1.setImage(UIImage(systemName: "a.circle", withConfiguration: configuration), for: .normal)
        button1.addTarget(self, action: #selector(answerButtonTapped(_:)), for: .touchUpInside)
        buttonStackView.addArrangedSubview(button1)

        button2 = UIButton(type: .system)
        button2.tag = 2
        button2.isHidden = true
        button2.contentHorizontalAlignment = .leading
        button2.translatesAutoresizingMaskIntoConstraints = false
        button2.contentEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 0)
        button2.imageEdgeInsets = .init(top: 0, left: -10, bottom: 0, right: 0)
        button2.setImage(UIImage(systemName: "b.circle", withConfiguration: configuration), for: .normal)
        button2.addTarget(self, action: #selector(answerButtonTapped(_:)), for: .touchUpInside)
        buttonStackView.addArrangedSubview(button2)

        button3 = UIButton(type: .system)
        button3.tag = 3
        button3.isHidden = true
        button3.contentHorizontalAlignment = .leading
        button3.translatesAutoresizingMaskIntoConstraints = false
        button3.contentEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 0)
        button3.imageEdgeInsets = .init(top: 0, left: -10, bottom: 0, right: 0)
        button3.setImage(UIImage(systemName: "c.circle", withConfiguration: configuration), for: .normal)
        button3.addTarget(self, action: #selector(answerButtonTapped(_:)), for: .touchUpInside)
        buttonStackView.addArrangedSubview(button3)

        button4 = UIButton(type: .system)
        button4.tag = 4
        button4.isHidden = true
        button4.contentHorizontalAlignment = .leading
        button4.translatesAutoresizingMaskIntoConstraints = false
        button4.contentEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 0)
        button4.imageEdgeInsets = .init(top: 0, left: -10, bottom: 0, right: 0)
        button4.setImage(UIImage(systemName: "d.circle", withConfiguration: configuration), for: .normal)
        button4.addTarget(self, action: #selector(answerButtonTapped(_:)), for: .touchUpInside)
        buttonStackView.addArrangedSubview(button4)

        resetButtonColor()

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: playerView.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            questionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),

            button1.widthAnchor.constraint(equalTo: button2.widthAnchor),
            button2.widthAnchor.constraint(equalTo: button3.widthAnchor),
            button3.widthAnchor.constraint(equalTo: button4.widthAnchor),

            button1.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            button2.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            button3.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            button4.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
        ])
    }

    func setupCloseButton() {
        closeButton = UIButton(type: .system)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.label, for: .normal)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)

        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        ])
    }

    func resetButtonColor() {
        button1.setTitleColor(.label, for: .normal)
        button2.setTitleColor(.label, for: .normal)
        button3.setTitleColor(.label, for: .normal)
        button4.setTitleColor(.label, for: .normal)
    }

    func disableAllButtons() {
        button1.isEnabled = false
        button2.isEnabled = false
        button3.isEnabled = false
        button4.isEnabled = false
    }

    func enableAllButtons() {
        button1.isEnabled = true
        button2.isEnabled = true
        button3.isEnabled = true
        button4.isEnabled = true
    }

    @objc func answerButtonTapped(_ sender: UIButton) {
        print(sender.tag)
        guard let question = question else {
            return
        }

        guard questionIsAnswered == false else {
            return
        }

        disableAllButtons()

        questionIsAnswered = true

        if sender.tag == question.correctIndex + 1 {
            sender.setTitleColor(.green, for: .normal)
            correctlyAnsweredQuestions += 1
        } else {
            sender.setTitleColor(.red, for: .normal)
            if let correctAnswerButton = view.viewWithTag(question.correctIndex + 1) as? UIButton {
                correctAnswerButton.setTitleColor(.green, for: .normal)
            }
        }
    }

    @objc func close() {
        dismiss(animated: true)
    }

    func setCorrectAnswerButton() {
        guard let question = question else {
            return
        }

        correctAnswerButton = view.viewWithTag(question.correctIndex + 1) as? UIButton
    }
}

extension QuizViewController: IVSPlayer.Delegate {
    func player(_ player: IVSPlayer, didChangeState state: IVSPlayer.State) {
        if state == .ready {
            player.play()
        }
    }

    func player(_ player: IVSPlayer, didOutputCue cue: IVSCue) {
        #if !TESTS
        if let textMetadataCue = cue as? IVSTextMetadataCue {
            if let data = textMetadataCue.text.data(using: .utf8) {
                let decoder = JSONDecoder()
                if let question = try? decoder.decode(Question.self, from: data) {
                    self.question = question
                } else {
                    self.question = nil
                }
            }
        }
        #endif
    }
}
//MARK: - Extension for Testing
extension QuizViewController {
    var mockQuestions: [Question] {
        [
            Question(question: "First Mock Question" , answers: ["Right Answer", "Wrong Answer 1", "Wrong Answer 2", "Wrong Answer 3"], correctIndex: 0),
            Question(question: "Second Mock Question", answers: ["Second Wrong Answer 1", "Second Wrong Answer 2", "Second Wrong Answer 3", "Second Right Answer"], correctIndex: 3),
            Question(question: "Third Mock Question", answers: ["Third Wrong Answer 1", "Third Right Answer", "Third Wrong Answer 2", "Third Wrong Answer 3"], correctIndex: 1),
        ]
    }
    
    func mockLoadingQuestionData(completion: @escaping (Question) -> Void) {
        var index = 2
        
        Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            index = self.generateNewRandomIndex(previousIndex: index)
            
            completion(self.mockQuestions[index])
        }
    }
    
    private func generateNewRandomIndex(previousIndex: Int) -> Int {
        var newIndex = Int.random(in: 0...2)
        while previousIndex == newIndex {
            newIndex = Int.random(in: 0...2)
        }
        return newIndex
    }
}

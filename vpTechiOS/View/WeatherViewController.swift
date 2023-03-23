//
//  WeatherViewController.swift
//  vpTechiOStask
//
//  Created by KOVIGROUP on 20/03/2023.
//
import UIKit
import Combine
import CoreData
import Network


class WeatherViewController: UIViewController {
    
    private var cancellables: Set<AnyCancellable> = []
    private let weatherService: WeatherService = WeatherService()
    private var latitude: Double = 0
    private var longitude: Double = 0
    private let monitor = NWPathMonitor()
    
    var viewModel: WeatherViewModel
    @IBOutlet weak var collectionView: UICollectionView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    required init?(coder aDecoder: NSCoder) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.viewModel = WeatherViewModel(city: "", managedObjectContext: context)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = WeatherViewModel(city: "Paris", managedObjectContext: context)
        configureCollectionView()
        configureViewModel()
        getLocation()
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
    }
    
    func getLocation() {
        latitude = 48.8534
        longitude = 2.3488
        self.fetchWeatherForecast()
        
        monitor.pathUpdateHandler = { [self] path in
            if path.status == .satisfied {
                print("We're connected!")
                self.fetchWeatherForecast()
            } else {
                print("No connection.")
            }
            print(path.isExpensive)
        }
    }
    
    private func configureViewModel() {
        viewModel.$forecast
            .sink(receiveValue: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            })
            .store(in: &cancellables)
        
        viewModel.fetchWeatherForecast()
    }
    
    func fetchWeatherForecast() {
        weatherService.fetchWeatherForecast(latitude: latitude, longitude: longitude)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    self.presentErrorAlert(withTitle: "No Internet Connection", message: "You are in offline mode. The data will be updated when you connect to the network.")
                case .finished:
                    print("Weather forecast fetch complete.")
                }
            }, receiveValue: { weatherForecast in
                self.viewModel.forecast = weatherForecast.list
                self.collectionView.reloadData()
            })
            .store(in: &cancellables)
    }
    
    func presentErrorAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Private methods
    
    private func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "WeatherCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WeatherCell")
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 20
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    private func presentErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource

extension WeatherViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherCell", for: indexPath) as! WeatherCollectionViewCell
        if let forecast = viewModel.forecast(for: indexPath) {
            cell.configure(with: forecast)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension WeatherViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let height: CGFloat = 100
        return CGSize(width: width, height: height)
    }
}

extension WeatherViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let weatherDetailViewController = storyboard.instantiateViewController(withIdentifier: "WeatherDetailViewController") as? WeatherDetailViewController,
              let forecast = viewModel.forecast(for: indexPath) else {
            return
        }
        weatherDetailViewController.forecast = forecast
        weatherDetailViewController.modalPresentationStyle = .pageSheet
        present(weatherDetailViewController, animated: true, completion: nil)
    }
}

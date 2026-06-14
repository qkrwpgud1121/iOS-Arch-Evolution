//
//  ViewController.swift
//  MovieApp
//
//  Created by 박제형 on 5/23/26.
//

import UIKit

struct MovieResponse: Codable {
    let results: [Movie]
}

struct Movie: Codable {
    let title: String
    let overview: String?
    let releaseDate: String?
    let posterPath: String?
    
    enum CodingKeys: String, CodingKey {
        case title, overview
        case releaseDate = "release_date"
        case posterPath = "poster_path"
    }
}

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var movieTableView: UITableView!
    
    private let apiKey = Secrets.tmdbApiKey
    private let token = Secrets.tmdbToken
    
    private var mainBannerMovies: Movie?
    private var popularMovies: [Movie] = []
    private var topRatedMovies: [Movie] = []
    private var animationMovies: [Movie] = []
    private var actionMovies: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.backgroundColor = .black
        movieTableView.backgroundColor = .black
        
        movieTableView.dataSource = self
        movieTableView.delegate = self
        
        fetchAllData()
    }
    
    private func fetchAllData() {
        
        fetchMovies(url: "https://api.themoviedb.org/3/movie/popular?language=ko-KR&page=1") { [weak self] movies in
            self?.mainBannerMovies = movies.randomElement()
            DispatchQueue.main.async {
                self?.movieTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
        }
        
        fetchMovies(url: "https://api.themoviedb.org/3/movie/popular?language=ko-KR&page=1") { [weak self] movies in
            self?.popularMovies = movies
            DispatchQueue.main.async {
                self?.movieTableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            }
        }
        
        fetchMovies(url: "https://api.themoviedb.org/3/movie/top_rated?language=ko-KR&page=1") { [weak self] movies in
            self?.topRatedMovies = movies
            DispatchQueue.main.async {
                self?.movieTableView.reloadSections(IndexSet(integer: 2), with: .automatic)
            }
        }
        
        fetchMovies(url: "https://api.themoviedb.org/3/discover/movie?language=ko-KR&with_genres=16") { [weak self] movies in
            self?.animationMovies = movies
            DispatchQueue.main.async {
                self?.movieTableView.reloadSections(IndexSet(integer: 3), with: .automatic)
            }
        }
        
        fetchMovies(url: "https://api.themoviedb.org/3/discover/movie?language=ko-KR&with_genres=28") { [weak self] movies in
            self?.actionMovies = movies
            DispatchQueue.main.async {
                self?.movieTableView.reloadSections(IndexSet(integer: 4), with: .automatic)
            }
        }
    }
    
    private func fetchMovies(url urlString: String, completion: @escaping ([Movie]) -> Void) {
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["accept": "application/json", "Authorization": "Bearer \(token)"]
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data, let decodedResponse = try? JSONDecoder().decode(MovieResponse.self, from: data) else { return }
            completion(decodedResponse.results)
        }.resume()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return switch section {
        case 1: "인기 영화"
        case 2: "명작"
        case 3: "애니메이션"
        case 4: "액션"
        default: nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = .white
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BannerCell", for: indexPath) as? BannerCell else {
                return UITableViewCell()
            }
            
            cell.bannerImageView.image = nil
            if let posterPath = mainBannerMovies?.posterPath {
                loadImage(path: posterPath, into: cell.bannerImageView)
            }
            
            return cell
            
        } else {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieRowCell", for: indexPath) as? MovieRowCell else {
                return UITableViewCell()
            }
            
            cell.collectionView.dataSource = self
            cell.collectionView.delegate = self
            cell.collectionView.tag = indexPath.section
            cell.collectionView.reloadData()
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 0 ? 500 : 180
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return switch collectionView.tag {
        case 1: popularMovies.count
        case 2: topRatedMovies.count
        case 3: animationMovies.count
        case 4: actionMovies.count
            default : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as? PosterCell else {
            return UICollectionViewCell()
        }
        
        let movie: Movie
        switch collectionView.tag {
        case 1: movie = popularMovies[indexPath.item]
        case 2: movie = topRatedMovies[indexPath.item]
        case 3: movie = animationMovies[indexPath.item]
        case 4: movie = actionMovies[indexPath.item]
        default: return cell
        }
        
        cell.posterImageView.image = nil
        if let posterPath = movie.posterPath {
            loadImage(path: posterPath, into: cell.posterImageView)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110, height: 160)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie: Movie
        switch collectionView.tag {
        case 1: selectedMovie = popularMovies[indexPath.item]
        case 2: selectedMovie = topRatedMovies[indexPath.item]
        case 3: selectedMovie = animationMovies[indexPath.item]
        case 4: selectedMovie = actionMovies[indexPath.item]
        default: return
        }
        
        print("selected Movie : \(selectedMovie)")
    }
    
    private func loadImage(path: String, into imageView: UIImageView?) {
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500\(path)") else { return }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView?.image = image
                }
            }
        }
    }
}

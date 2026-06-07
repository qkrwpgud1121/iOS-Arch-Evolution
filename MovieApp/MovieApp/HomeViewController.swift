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
    let overview: String
    let releaseDate: String
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
    
    private var popularMovies: [Movie] = []
    private var nowPlayingMovies: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        movieTableView.dataSource = self
        movieTableView.delegate = self
        movieTableView.rowHeight = UITableView.automaticDimension
        movieTableView.estimatedRowHeight = 150
        
        self.navigationItem.title = "현재 상영작"
        
        fetchPopularMovies()
        fetchNowPlayingMovies()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let destination = segue.destination as? MovieDetailViewController,
               let indexPath = movieTableView.indexPathForSelectedRow {
                destination.movie = nowPlayingMovies[indexPath.row]
            }
        }
    }
    
    private func fetchPopularMovies() {
        
        let urlString = "https://api.themoviedb.org/3/movie/popular?language=ko-KR&page=1"
        performRequest(with: urlString) { movies in
            self.popularMovies = movies
            DispatchQueue.main.async { self.movieTableView.reloadSections(IndexSet(integer: 0), with: .automatic) }
        }
    }
    
    private func fetchNowPlayingMovies() {
        
        let urlString = "https://api.themoviedb.org/3/movie/now_playing?language=ko-KR&page=1"
        performRequest(with: urlString) { movies in
            self.nowPlayingMovies = movies
            DispatchQueue.main.async { self.movieTableView.reloadSections(IndexSet(integer: 1), with: .automatic) }
        }
    }
    
    private func performRequest(with urlString: String, completion: @escaping ([Movie]) -> Void) {
        
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = ["accept": "application/json", "Authorization": "Bearer \(token)"]
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else { return }
            if let decodedResponse = try? JSONDecoder().decode(MovieResponse.self, from: data) {
                completion(decodedResponse.results)
            }
        }.resume()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "인기 영화" : "현재 상영 영화"
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : nowPlayingMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieRowCell", for: indexPath) as? MovieRowCell else {
                return UITableViewCell()
            }
            
            cell.collectionView.dataSource = self
            cell.collectionView.delegate = self
            cell.collectionView.tag = 0
            cell.collectionView.reloadData()
            
            return cell
            
        } else {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as? MovieCell else {
                return UITableViewCell()
            }
            
            let movie = nowPlayingMovies[indexPath.row]
            
            cell.titleLabel.text = movie.title
            cell.dateLabel.text = movie.releaseDate
            cell.overviewLabel.text = movie.overview
            
            cell.posterImageView.image = nil
            
            if let posterPath = movie.posterPath {
                if let imageUrl = URL(string: "https://image.tmdb.org/t/p/w200\(posterPath)") {
                    DispatchQueue.global().async {
                        if let data = try? Data(contentsOf: imageUrl), let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                cell.posterImageView.image = image
                            }
                        }
                    }
                }
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 0 ? 220 : 180
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as? PosterCell else {
            return UICollectionViewCell()
        }
        
        let movie = popularMovies[indexPath.row]
        cell.posterImageView.image = nil
        
        if let posterPath = movie.posterPath {
            if let imageUrl = URL(string: "https://image.tmdb.org/t/p/w200\(posterPath)") {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: imageUrl), let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            cell.posterImageView.image = image
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130, height: 190)
    }
    
}

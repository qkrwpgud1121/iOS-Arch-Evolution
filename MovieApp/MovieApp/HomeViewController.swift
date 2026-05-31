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

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var movieTableView: UITableView!
    
    private let apiKey = "f231596c72a43dbd30de5fa821eb7b4d"
    private var movies: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        movieTableView.dataSource = self
        movieTableView.delegate = self
        
        fetchPopularMovies()
    }
    
    private func fetchPopularMovies() {
        
        guard let baseUrl = URL(string: "https://api.themoviedb.org/3/movie/popular") else { return }
        var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)
        
        components?.queryItems = [
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1")
        ]
        
        guard let url = components?.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        
        let token = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmMjMxNTk2YzcyYTQzZGJkMzBkZTVmYTgyMWViN2I0ZCIsIm5iZiI6MTcyNTg0OTA2MS43MjUsInN1YiI6IjY2ZGU1ZGU1ODU0YWM5YjhiMjNhZDI5NSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.c92tln1Wv1Oue44ufRTiboivuWCE7abIQgATx4eXVgs"
        
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer \(token)"
        ]
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            
            if let error = error {
                print("네트워크 오류: \(error)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self?.movies = decodedResponse.results
                    self?.movieTableView.reloadData() 
                }
            } catch {
                print("디코딩 오류: \(error)")
            }
        }
        task.resume()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
        let movie = movies[indexPath.row]
        
        cell.textLabel?.text = movie.title
        cell.detailTextLabel?.text = movie.releaseDate
        
        return cell
    }
}

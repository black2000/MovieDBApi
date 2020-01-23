//
//  TMDBClient.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

class TMDBClient {
    
    static let apiKey = "94052eb2cea2f2866cb93bd1d76b7968"
    
    struct Auth {
        static var accountId = 0
        static var requestToken = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        
        static let base = "https://api.themoviedb.org/3"
        static let apiKeyParam = "?api_key=\(TMDBClient.apiKey)"
        
        case makeWatchlist
        case markFavourite
        case search(String)
        case getWatchlist
        case getFavourites
        case getRequestToken
        case login
        case createSessionId
        case webAuth
        case logout
        
        var stringValue: String {
            switch self {
            case .getWatchlist: return Endpoints.base + "/account/\(Auth.accountId)/watchlist/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
                
            case .getFavourites :
                return Endpoints.base +
                "/account/\(Auth.accountId)/favorite/movies" +
                Endpoints.apiKeyParam +
                "&session_id=\(Auth.sessionId)"
                
            case .search(let query) :
                return Endpoints.base +
                "/search/movie" +
                Endpoints.apiKeyParam +
                "&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                
            case .makeWatchlist :
                return Endpoints.base +
                "/account/\(Auth.accountId)/watchlist" +
                Endpoints.apiKeyParam +
                "&session_id=\(Auth.sessionId)"
                
            
            case .markFavourite :
                return Endpoints.base +
                    "/account/\(Auth.accountId)/favorite" +
                    Endpoints.apiKeyParam +
                "&session_id=\(Auth.sessionId)"
                
            case .getRequestToken :
                return Endpoints.base + "/authentication/token/new" + Endpoints.apiKeyParam
                
                
            case .login :
                return Endpoints.base + "/authentication/token/validate_with_login" + Endpoints.apiKeyParam
              
            case .createSessionId :
                return Endpoints.base +
                "/authentication/session/new" +
                Endpoints.apiKeyParam
            case .webAuth :
                return "https://www.themoviedb.org/authenticate/" +
                Auth.requestToken +
                "?redirect_to=themoviemanager:authenticate" 
            case .logout :
                return Endpoints.base +
                "authentication/session" +
                Endpoints.apiKeyParam
                
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    
    
    
    
    class func markFavourite(movieId : Int , favourite : Bool , completion : @escaping (Bool , Error?) -> Void) {
        
        let body = MarkFavourite(mediaType: "movie", mediaId: movieId, favorite: favourite)
        
        taskForPostRequest(url: Endpoints.markFavourite.url, responseType: TMDBResponse.self, body: body) { (response, error) in
            
            if let response = response {
                completion(response.statusCode == 1 ||
                    response.statusCode == 12  ||
                    response.statusCode == 13 , nil)
            }else {
                completion(false , error)
            }
            
        }
        
    }
    
    
    class func markWatchlist(movieId : Int , watchlist : Bool , completion : @escaping (Bool , Error?) -> Void) {
        
        let body = MarkWatchList(mediaType: "movie", mediaId: movieId, watchlist: watchlist)
        
        taskForPostRequest(url: Endpoints.makeWatchlist.url, responseType: TMDBResponse.self, body: body) { (response, error) in
            
            if let response = response {
                completion(response.statusCode == 1 ||
                           response.statusCode == 12  ||
                           response.statusCode == 13 , nil)
            }else {
                completion(false , error)
            }
            
        }
        
    }
    
    
    class func search(query : String , completion : @escaping ([Movie] , Error?) -> Void ) {
        
        print(Endpoints.search(query).url)
        
        taskForGetRequest(url: Endpoints.search(query).url, response: MovieResults.self) { (response, error) in
            
            if let response = response {
                completion(response.results , nil)
            }else {
                completion([] , error)
            }
            
            
        }
        
    }
    
    class func logout(completion : @escaping () -> Void ) {
        
        
        var request = URLRequest(url: Endpoints.logout.url)
        
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = LogoutRequest(sessionId: Auth.sessionId)
        
        request.httpBody = try! JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            Auth.requestToken = ""
            Auth.sessionId = ""
            completion()
        }
        task.resume()
        
    }
    
    
    
    
    class func createSessionId(completion: @escaping (Bool, Error?) -> Void) {
        
         let body = PostSession(requestToken: Auth.requestToken)
        
        taskForPostRequest(url: Endpoints.createSessionId.url, responseType: SessionResponse.self, body: body) { (response, error) in
            
            if let response = response {
                 Auth.sessionId = response.sessionId
                completion(true , nil)
            }else {
                completion(false , error)
            }
            
        }
    }
    
 
    
    
    class func login(username : String , password : String,completion: @escaping (Bool, Error?) -> Void) {
        
         let body = LoginRequest(username: username, password: password, requestToken: Auth.requestToken)
        
        taskForPostRequest(url: Endpoints.login.url, responseType: RequestTokenResponse.self, body: body) { (response, error) in
            
            if let response = response {
                Auth.requestToken = response.requestToken
                completion(response.success , nil)
            }else {
                completion(false , error)
            }
            
        }
    }
    
    
    class func getRequestToken(completion: @escaping (Bool, Error?) -> Void) {
        
        
        taskForGetRequest(url: Endpoints.getRequestToken.url, response: RequestTokenResponse.self) { (response, error) in
            
            if let response = response {
                 Auth.requestToken = response.requestToken
                completion(response.success , nil)
            }else {
                completion(false , error)
            }
        }
        
    }
    
    
    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
        
        
        taskForGetRequest(url: Endpoints.getWatchlist.url, response: MovieResults.self) { (response, error) in
            
            
            if let response = response {
                completion(response.results , nil )
            }else {
                completion([] , error)
            }
            
        }
        
    }
    
    
    class func getFavourites(completion: @escaping ([Movie], Error?) -> Void) {
     
        taskForGetRequest(url: Endpoints.getFavourites.url, response: MovieResults.self) { (response, error) in
            
            
            if let response = response {
                print(response)
                completion(response.results , nil )
            }else {
                completion([] , error )
            }
            
        }
        
    }
    
    
    
    
    
    class func taskForPostRequest<RequestType : Encodable , ResponseType : Decodable>(url : URL , responseType : ResponseType.Type , body : RequestType ,completion : @escaping (ResponseType? , Error?) -> Void) {
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = body
        
        request.httpBody = try! JSONEncoder().encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil , error )
                }
                
                return
            }
            
            do {
                
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode(ResponseType.self, from: data)
            DispatchQueue.main.async {
                completion(responseObject , nil)
                }
            }catch {
              DispatchQueue.main.async {
                completion(nil , error)
                }
            }
            
            
        }
        task.resume()
        
        
    }
    
    
    class func taskForGetRequest<ResponseType : Decodable>(url : URL , response : ResponseType.Type , completion : @escaping (ResponseType? , Error?) -> Void) {
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            
            print(json)
            
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
                
            } catch {
                DispatchQueue.main.async {
                  completion(nil, error)
                }
                
            }
        }
        task.resume()
        
    }
    
}

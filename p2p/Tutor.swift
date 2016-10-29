//
//  Tutor.swift
//  p2p
//
//  Created by Amar Ramachandran on 10/16/16.
//  Copyright © 2016 sfhacks. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire

enum subjects {
    case English
    case Math(String)
    case Science(String)
    case Language(String)
    
    var description: String {
        switch self {
        case .English:
            return "English"
        case .Math(let subject):
            return subject
        case .Science(let subject):
            return subject
        case .Language(let subject):
            return subject
        }
    }
}

class Tutor: User {
    fileprivate(set) public var reviews: [Review]?
    fileprivate(set) public var subjects: [String]?
    fileprivate(set) public var stars: Double?
    fileprivate(set) public var bio: String?
    fileprivate(set) public var school: String?
    fileprivate(set) public var city: String?
    fileprivate(set) public var location: (longitude: Double, latitude: Double) = (0, 0)
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        let SubjectsTransform = TransformOf<[String], String>(fromJSON: { (value: String?) -> [String]? in
            return value?.characters.split{$0 == ","}.map(String.init)
            }, toJSON: { (value: [String]?) -> String? in
                return value!.joined(separator: ",")
        })
        
        reviews                 <- map["reviews"]
        subjects                <- (map["subjects"], SubjectsTransform)
        stars                   <- map["stars"]
        location.longitude      <- map["location.0"]
        location.latitude       <- map["location.1"]
        bio                     <- map["bio"]
        school                  <- map["school"]
        city                    <- map["city"]
    }
}

extension Tutor {
    static func create(username: String, password: String, name: String, school: String, bio: String, city: String, completion: @escaping P2PObjectCompletionBlock) {
        
    }
    
    static func get(tutor id: String, completion: @escaping P2PObjectCompletionBlock) {
        P2PManager.sharedInstance.sessionManager.request(TutorRouter.get(id: id)).responseObject { (response: DataResponse<Tutor>) in
            completion(response.result.value, response.result.error);
        }
    }
    
    static func getAll(at location: (Double, Double), for subject: String, completion: @escaping P2PArrayCompletionBlock) {
        P2PManager.sharedInstance.sessionManager.request(TutorRouter.getAllAt(location: location, subject: subject)).responseArray { (response: DataResponse<[Tutor]>) in
            completion(response.result.value, response.result.error);
        }
    }
    
    static func getAll(in city: String, for subject: String, completion: @escaping P2PArrayCompletionBlock) {
        P2PManager.sharedInstance.sessionManager.request(TutorRouter.getAllIn(city: city, subject: subject)).responseArray { (response: DataResponse<[Tutor]>) in
            completion(response.result.value, response.result.error);
        }
    }
    
    static func getReviews(for tutor: String, completion: @escaping P2PArrayCompletionBlock) {
        P2PManager.sharedInstance.sessionManager.request(TutorRouter.getReviews(id: tutor)).responseArray { (response: DataResponse<[Review]>) in
            completion(response.result.value, response.result.error);
        }
    }
    
    func getReviews(completion: @escaping P2PCompletionBlock) {
        Tutor.getReviews(for: self.id!) { (reviews, error) in
            if error != nil {
                completion(error)
                return
            }
            
            self.reviews = reviews as! [Review]?
            
            completion(error)
        }
        
            
    }
    
    private enum TutorRouter: URLRequestConvertible {
        case create(username: String, password: String, name: String, school: String, bio: String, city: String)
        case get(id: String)
        case getAllAt(location: (Double, Double), subject: String)
        case getAllIn(city: String, subject: String)
        case getReviews(id: String)
        
        var method: HTTPMethod {
            switch self {
            case .create:
                return .post
            case .get:
                return .get
            case .getAllAt:
                return .get
            case .getAllIn:
                return .get
            case .getReviews:
                return .get
            }
        }
        
        var path: String {
            switch self {
            case .create:
                return "/tutors/create"
            case .get(let id):
                return "/tutors/\(id)"
            case .getAllAt:
                return "/tutors"
            case .getAllIn:
                return "/tutors"
            case .getReviews(let id):
                return "/tutors/\(id)/reviews"
            }
        }
        
        // MARK: URLRequestConvertible
        
        func asURLRequest() throws -> URLRequest {
            let url = try P2PBaseURL.asURL()
            
            var urlRequest = URLRequest(url: url.appendingPathComponent(path))
            urlRequest.httpMethod = method.rawValue
            
            switch self {
            case .create(let username, let password, let name, let school, let bio, let city):
                urlRequest = try URLEncoding.default.encode(urlRequest, with: ["username": username, "password": password, "fullname": name, "school": school, "bio": bio, "city": city])
            case .getAllAt(let location, let subject):
                urlRequest = try URLEncoding.queryString.encode(urlRequest, with: ["long": location.0, "lat": location.1, "subjects": subject, "range": 0.0005])
                urlRequest.setValue("Bearer \(P2PManager.sharedInstance.token!)", forHTTPHeaderField: "Authorization")
            case .getAllIn(let city, let subject):
                urlRequest = try URLEncoding.queryString.encode(urlRequest, with: ["city": city, "subjects": subject])
                urlRequest.setValue("Bearer \(P2PManager.sharedInstance.token!)", forHTTPHeaderField: "Authorization")
            default:
                break
            }
            
            return urlRequest
        }
    }
}

 

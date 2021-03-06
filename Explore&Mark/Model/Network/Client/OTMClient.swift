//
//  OTMClient.swift
//  Explore&Mark
//
//  Created by 邱浩庭 on 15/1/2021.
//

import Foundation
import Alamofire

/**
 This class is responsible for sending OpenTripMap API request
 */
class OTMClient {
    private static let apiKey = "5ae2e3f221c38a28845f05b6091dd76d8bdafd297f2bfe6df5739ecb"
    
    enum Endpoints {
        static private let getObjectListBase = "https://api.opentripmap.com/0.1"
        
        case getObjectListByBbox(String, Int, Int, Int, Int, String, String)
        case getObjectListByRadius(String)
        case getObjectProperty(String, String)
        
        private var stringValue: String {
            switch self {
            case .getObjectListByBbox(let lang, let lonMin, let lonMax, let latMin, let latMax, let kinds, let rate):
                return Endpoints.getObjectListBase + "/\(lang)/places/bbox?" + "lon_min=\(lonMin)&lon_max=\(lonMax)&lat_min=\(latMin)&lat_max=\(latMax)&kinds=\(kinds)&rate=\(rate)&apiKey=\(OTMClient.apiKey)"
            case .getObjectListByRadius(let lang):
                return Endpoints.getObjectListBase + "/\(lang)/places/radius"
            case .getObjectProperty(let lang, let xid):
                return Endpoints.getObjectListBase + "/\(lang)/places/xid/\(xid)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    // get object property
    class func getObjectPerpertyByXid(lang: String = "en", xid: String, completion: @escaping (OTMObjectProperty?, Error?) -> Void) {
        let headers: HTTPHeaders = [
            .accept("application/json")
        ]
        let parameters: [String: Any] = [
            "apikey": apiKey
        ]

        AF.request(Endpoints.getObjectProperty(lang, xid).url, method: .get, parameters: parameters, headers: headers).responseDecodable(of: OTMObjectProperty.self) { (response) in
            switch response.result {
            case .success:
                completion(response.value!, nil)
            case .failure:
                completion(nil, response.error!)
            }
        }
    }
    
    // get object list by radius
    class func getObjectsByRadius(lang: String = "en", radius: Double, lon: Double, lat: Double, format: String = "json", kinds: String = "interesting_places", rate: String? = nil, limit: Int = 50, completion: @escaping ([OTMObject]?, Error?) -> Void) {
        let headers: HTTPHeaders = [
            .accept("application/json")
        ]
        
        var parameters: [String: Any] = [
            "radius": radius,
            "lon": lon,
            "lat": lat,
            "kinds": kinds,
            "format": format,
            "apikey": apiKey,
            "limit": limit
        ]
        
        if let rate = rate {
            parameters["rate"] = rate
        }
        
        AF.request(Endpoints.getObjectListByRadius(lang).url, method: .get, parameters: parameters, headers: headers).validate(statusCode: 200..<300).responseDecodable(of: [OTMObject].self) { (response) in
            switch response.result {
            case .success:
                completion(response.value!, nil)
            case .failure:
                completion(nil, response.error!)
            }
        }
    }

}

//
//  DriftAPIURLRouter.swift
//  Pods
//
//  Created by Eoin O'Connell on 29/05/2017.
//
//

import Alamofire

public enum APIBase: String {
    case Customer = "https://customer.api.drift.com/"
    case Conversation = "https://conversation.api.drift.com/conversations/"
}


public enum DriftRouter: URLRequestConvertible {
    
    case getEmbed(embedId: String, refreshRate: Int?)
    case postIdentify(params: [String: Any])
    
    var request: (method: Alamofire.HTTPMethod, url: URL, parameters: [String: Any]?, encoding: ParameterEncoding){
        switch self {
        case .getEmbed(let embedId, let refreshRate):
            
            let refreshString = Int(Date().timeIntervalSince1970.truncatingRemainder(dividingBy: Double((refreshRate ?? 30000))))

            return (.get, URL(string:"https://js.drift.com/embeds/\(refreshString)/\(embedId).json")!, nil, URLEncoding.default)
            
        case .postIdentify(let params):
            return (.post, URL(string: "https://event.api.drift.com/identify")!, params, JSONEncoding.default)
            
        }
    }
    
    public func asURLRequest() throws -> URLRequest {

        
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        let encoding = request.encoding
        var req = try encoding.encode(urlRequest, with: request.parameters)
        
        req.url = URL(string: (req.url?.absoluteString.replacingOccurrences(of: "%5B%5D=", with: "="))!)
        
        let mutableReq = (req.urlRequest! as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        
        return mutableReq as URLRequest
    }

    
}

public enum DriftCustomerRouter: URLRequestConvertible {
    
    case getAuth(email: String, userId: String, redirectURL: String, orgId: Int, clientId: String)
    case getUser(orgId: Int, userId: Int)
    case getEndUser(endUserId: Int)
    
    var request: (method: Alamofire.HTTPMethod, path: String, parameters: [String: Any]?, encoding: ParameterEncoding){
        switch self {
        case .getAuth(let email, let userId, let redirectURL, let orgId, let clientId):
            
            let params: [String : Any] = [
                
                "email": email ,
                "org_id": orgId,
                "user_id": userId,
                "grant_type": "sdk",
                "redirect_uri":redirectURL,
                "client_id": clientId
            ]
            
            return (.post, "oauth/token", params, URLEncoding.default)
        case .getUser(let orgId, let userId):
            
            let params: [String: Any] =
                [   "avatar_w": 102,
                    "avatar_h": 102,
                    "avatar_fit": "1",
                    "userId": userId
            ]
            
            return (.get, "organizations/\(orgId)/users", params, URLEncoding.default)
        case .getEndUser(let endUserId):
            return (.get, "end_users/\(endUserId)", nil, URLEncoding.default)
        }
    }
    
    public func asURLRequest() throws -> URLRequest {
        var components = URLComponents.init(string: APIBase.Customer.rawValue)
        
        if let accessToken = DriftDataStore.sharedInstance.auth?.accessToken{
            let authItem = URLQueryItem.init(name: "access_token", value: accessToken)
            components?.queryItems = [authItem]
        }
        
        var urlRequest = URLRequest(url: (components?.url!.appendingPathComponent(request.path))!)
        urlRequest.httpMethod = request.method.rawValue
        let encoding = request.encoding
        var req = try encoding.encode(urlRequest, with: request.parameters)
        
        req.url = URL(string: (req.url?.absoluteString.replacingOccurrences(of: "%5B%5D=", with: "="))!)
        
        let mutableReq = (req.urlRequest! as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        
        return mutableReq as URLRequest
    }
    
}

public enum DriftConversationRouter: URLRequestConvertible {
    
    case getConversationsForEndUser(endUserId: Int)
    case getMessagesForConversation(conversationId: Int)
    case postMessageToConversation(conversationId: Int, data: [String: Any])
    case createConversation(body: String)
    
    
    var request: (method: Alamofire.HTTPMethod, path: String, parameters: [String: Any]?, encoding: ParameterEncoding){
        switch self {
        case .getConversationsForEndUser(let endUserId):
            return (.get, "conversations/end_users/\(endUserId)", nil, URLEncoding.default)
        case .getMessagesForConversation(let conversationId):
            return (.get, "conversations/\(conversationId)/messages", nil, URLEncoding.default)
        case .postMessageToConversation(let conversationId, let data):
            return (.post, "conversations/\(conversationId)/messages", data, JSONEncoding.default)
        case .createConversation(let body):
            return (.post, "messages", ["body":body], JSONEncoding.default)
        }
    }
    
    
    public func asURLRequest() throws -> URLRequest {
        var components = URLComponents.init(string: APIBase.Conversation.rawValue)
        if let accessToken = DriftDataStore.sharedInstance.auth?.accessToken{
            let authItem = URLQueryItem.init(name: "access_token", value: accessToken)
            components?.queryItems = [authItem]
        }
        var urlRequest = URLRequest(url: (components?.url!.appendingPathComponent(request.path))!)
        urlRequest.httpMethod = request.method.rawValue
        let encoding = request.encoding
        var req = try encoding.encode(urlRequest, with: request.parameters)
        
        req.url = URL(string: (req.url?.absoluteString.replacingOccurrences(of: "%5B%5D=", with: "="))!)
        
        let mutableReq = (req.urlRequest! as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        
        if let bodyData = req.httpBody {
            URLProtocol.setProperty(bodyData, forKey: "NFXBodyData", in: mutableReq)
        }
        
        return mutableReq as URLRequest
    }
}

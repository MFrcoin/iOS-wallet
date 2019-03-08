//
//  JsonStructs.swift
//  MFCoin
//
//  Created by Admin on 19.02.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import Foundation
import RealmSwift

//{\"jsonrpc\": \"2.0\", \"result\": {\"confirmed\": 0, \"unconfirmed\": 0}, \"id\": \"BTC\"}
struct GetBalance: Codable {
    var jsonrpc: String
    var id: String
    
    struct Result: Codable {
        var confirmed: Int?
        var unconfirmed: Int?
        private enum ResultKeys: String, CodingKey {
            case confirmed = "confirmed"
            case unconfirmed = "unconfirmed"
        }
    }
    
    enum answerKeys: String, CodingKey{
        case jsonrpc = "jsonrpc"
        case id = "id"
    }
    let result: Result
}

//{"jsonrpc": "2.0", "result": [{"tx_hash": "416172f81e3fb180cd4ea6f19251c17e89ddd330e9fc558b1e8909bda42b713d", "tx_pos": 1, "height": 159894, "value": 10000000000}], "id": "MFC"}
struct Listunspent: Codable {
    var jsonrpc: String
    var id: String
    
    struct Result: Codable {
        var tx_hash: String?
        var tx_pos: Int?
        var height: Int?
        var value: Int?
        private enum ResultKeys: String, CodingKey {
            case tx_hash = "tx_hash"
            case tx_pos = "tx_pos"
            case height = "height"
            case value = "value"
        }
    }
    
    enum answerKeys: String, CodingKey{
        case jsonrpc = "jsonrpc"
        case id = "id"
    }
    let result: [Result]
}


struct GetHistory: Codable {
    var jsonrpc: String
    var id: String
    
    struct Result: Codable {
        var txhash: String?
        var height: Int?
        private enum ResultKeys: String, CodingKey {
            case txhash = "tx_hash"
            case height = "height"
        }
    }
    
    enum answerKeys: String, CodingKey{
        case jsonrpc = "jsonrpc"
        case id = "id"
    }
    let result: Result
}

struct Broadcast: Codable {
    var jsonrpc: String
    var id: String
    
    struct Result: Codable {
        var answer: String
    }
    
    enum answerKeys: String, CodingKey{
        case jsonrpc = "jsonrpc"
        case id = "id"
    }
    let result: Result
}

struct JsonError: Codable {
    var jsonrpc: String
    var id: String
    
    struct ErrorResult: Codable {
        var code: Int?
        var message: String?
        private enum ResultKeys: String, CodingKey {
            case code = "code"
            case message = "message"
        }
    }
    
    enum answerKeys: String, CodingKey {
        case jsonrpc = "jsonrpc"
        case id = "id"
    }
    let result: ErrorResult
}

//"response {\"jsonrpc\": \"2.0\", \"error\": {\"code\": -32602, \"message\": \"0 arguments passed to method \\\"blockchain.scripthash.get_balance\\\" but it requires 1\"}, \"id\": \"BTC\"}\n"



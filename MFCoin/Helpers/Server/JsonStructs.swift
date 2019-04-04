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
    
    struct Result: Codable {
        var confirmed: Int?
        var unconfirmed: Int?
    }

    let result: Result
}

//{"jsonrpc": "2.0", "result": [{"tx_hash": "416172f81e3fb180cd4ea6f19251c17e89ddd330e9fc558b1e8909bda42b713d", "tx_pos": 1, "height": 159894, "value": 10000000000}], "id": "MFC"}
struct Listunspent: Codable {
    
    struct Result: Codable {
        var tx_hash: String?
        var tx_pos: Int?
        var height: Int?
        var value: Int?
    }
    let result: [Result]
}


struct GetHistory: Codable {
    
    struct Result: Codable {
        var tx_hash: String?
        var height: Int?
    }

    let result: [Result]
}

struct GetMempool: Codable {
    
    struct Result: Codable {
        var tx_hash: String?
        var height: Int?
        var fee: Int?
    }
    let result: [Result]
}

struct GetTxHistory: Codable {
    
    struct Result: Codable {
        var blockhash: String
        var confirmations: Int
        var time: Int
        var hex: String
        var txid: String
        var version: Int
        var locktime: Int
        
        struct Vin: Codable {
            var txid: String
            var vout: Int
        }
        
        struct Vout: Codable {
            var value: Float
            var n: Int
            struct ScriptPubKey: Codable {
                var addresses: [String]
            }
            let scriptPubKey: ScriptPubKey
        }
        let vin: [Vin]
        let vout: [Vout]
    }

    let result: Result
}

struct Broadcast: Codable {
    var result: String
}

struct Version: Codable {
    
    struct Result: Codable {
        
    }
    let result: Result?
}

struct JsonError: Codable {
    
    struct ErrorResult: Codable {
        var code: Int?
        var message: String?
    }
    let result: ErrorResult
}

//"response {\"jsonrpc\": \"2.0\", \"error\": {\"code\": -32602, \"message\": \"0 arguments passed to method \\\"blockchain.scripthash.get_balance\\\" but it requires 1\"}, \"id\": \"BTC\"}\n"



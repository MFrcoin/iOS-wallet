//
//  ServerConnect.swift
//  MFCoin
//
//  Created by Admin on 28.01.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//
import SwiftSocket

struct jsonAnswer: Decodable {
   
}

class ServerConnect {
   static let shared = ServerConnect()
   var requestFlag = false
   
   func sendRequest(coin: CoinModel, command: toServer, altInfo: String, id: String, _ completion: @escaping (_ completion: Any?) -> ()) {
      let host:String = "\(coin.host)"
      let port:Int = Int(coin.port)
      let date = Date().timeIntervalSince1970.description
      
      let client = TCPClient(address: host, port: Int32(port))
      let resultConnect = client.connect(timeout: 2)
      switch resultConnect {
      case .success:
         let message = "{\"jsonrpc\": \"2.0\", \"method\": \"\(command.rawValue)\", \"params\": [\(altInfo)], \"id\": \"\(coin.shortName)\(date)\"}\n"
         let resultSend = client.send(string: message )
         switch resultSend {
         case .success:
            var time = 4096
            if command == .getTransactions {
               time = 1024000
            }
            if let wert = client.read(time, timeout: 1) {
               let data = Data(bytes: wert)
               let answer = self.parseJSON(data, command)
               completion(answer)
            }
         case .failure(let error):
            completion(error)
         }
      case .failure(let error):
         if !requestFlag {
            requestFlag = true
            sendRequest(coin: coin, command: command, altInfo: altInfo, id: id) { (response) in
               completion(response)
            }
         }
         completion(error)
      }
   }
   
   private func parseJSON(_ data: Data, _ command: toServer) -> Any? {
      do {
         let decoder = JSONDecoder()
         switch command{
         case .getBalanceScrH:
            let response = try decoder.decode(GetBalance.self, from: data)
            return response
         case .listunspent:
            let response = try decoder.decode(Listunspent.self, from: data)
            return response
         case .getHistory:
            let response = try decoder.decode(GetHistory.self, from: data)
            return response
         case .getTransactions:
            let response = try decoder.decode(GetTxHistory.self, from: data)
            return response
         case .broadcast:
            let response = try decoder.decode(Broadcast.self, from: data)
            return response
         case .version:
            let response = try decoder.decode(Version.self, from: data)
            return response
         default:
            //let response = try decoder.decode(JsonError.self, from: data)
            return nil
         }
      } catch { print(" Catch Error \(error)") }
      return nil
   }
}





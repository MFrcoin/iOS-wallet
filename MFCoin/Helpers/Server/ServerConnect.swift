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
   //let block = "https://blockchain.info/tx/%s"

   func sendRequest(coin: CoinModel, command: toServer, altInfo: String, id: String, _ completion: @escaping (_ completion: Any?) -> ()) {
      
      let host:String = "\(coin.host)"
      let port:Int = Int(coin.port)
      let date = Date().timeIntervalSince1970.description
      
         let client = TCPClient(address: host, port: Int32(port))
         let resultConnect = client.connect(timeout: 2)
         switch resultConnect {
         case .success:
            let message = "{\"jsonrpc\": \"2.0\", \"method\": \"\(command.rawValue)\", \"params\": [\(altInfo)], \"id\": \"\(coin.shortName)\(date)\"}\n"
            print(message)
            let resultSend = client.send(string: message )
            switch resultSend {
            case .success:
               if let wert = client.read(2048, timeout: 2) {
                  let data = Data(bytes: wert)
                  let answer = self.parseJSON(data, command)
                  print (answer)
                  completion(answer)
               }
            case .failure(let error):
               debugPrint("error1 \(error.localizedDescription)")
               completion(error)
            }
         case .failure(let error):
            debugPrint("error2 \(error.localizedDescription)")
            completion(error)
         }
   }
   
   private func parseJSON(_ data: Data, _ command: toServer) -> Any? {
      do {
         let pr = String.init(data: data, encoding: .utf8)
         print (pr!)
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
         case .broadcast:
            let response = try decoder.decode(Broadcast.self, from: data)
            return response
         default:
            let response = try decoder.decode(JsonError.self, from: data)
            print ("ERROR JSON Request \(response)")
            return nil
         }
      } catch { print(error) }
      return nil
   }
}





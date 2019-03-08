//
//  ServerCommands.swift
//  MFCoin
//
//  Created by Admin on 15.02.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import Foundation

enum toServer: String {
    
    //https://electrumx.readthedocs.io/en/latest/protocol-methods.html
    
    case ping = "server.ping"
    case version = "server.version"
    
    //blockchain.scripthash.get_balance(scripthash)
    //Return the confirmed and unconfirmed balances of a script hash.
    case getBalanceScrH = "blockchain.scripthash.get_balance"
    
    //blockchain.address.get_balance(address)
    //Return the confirmed and unconfirmed balances of a address.
    //Does not support of MFCoin servers
    case getBalanceAd = "blockchain.address.get_balance"
    
    //blockchain.scripthash.listunspent(scripthash)
    //? Return an ordered list of UTXOs sent to a script hash.
    // {"jsonrpc": "2.0", "result": [{"tx_hash": "416172f81e3fb180cd4ea6f19251c17e89ddd330e9fc558b1e8909bda42b713d", "tx_pos": 1, "height": 159894, "value": 10000000000}], "id": "MFC"}
    case listunspent = "blockchain.scripthash.listunspent"
    
    //blockchain.scripthash.get_history(scripthash)
    //?Return the confirmed and unconfirmed history of a script hash.
    //{"jsonrpc": "2.0", "result": [{"tx_hash": "416172f81e3fb180cd4ea6f19251c17e89ddd330e9fc558b1e8909bda42b713d", "height": 159894}], "id": "getHistory MFC"}
    case getHistory = "blockchain.scripthash.get_history"
    
    //Return the minimum fee a low-priority transaction must pay in order to be accepted to the daemon’s memory pool.
    //{"jsonrpc": "2.0", "result": 1e-05, "id": "relayfee BTC"}
    case relayfee = "blockchain.relayfee"
    
    //blockchain.estimatefee(The number of blocks to target for confirmation.)
    //Return the estimated transaction fee per kilobyte for a transaction to be confirmed within a certain number of blocks.
    //{"jsonrpc": "2.0", "result": 0.00012912, "id": "estimatefee BTC"}
    case estimatefee = "blockchain.estimatefee"
    
    //Описание внизу
    //blockchain.transaction.get(tx_hash, verbose=false, merkle=false)
    //Return a raw transaction.
    case getTransaction = "blockchain.transaction.get"
    
    //height = 0
    //{"jsonrpc": "2.0", "error": {"code": 1, "message": "tx hash 416172f81e3fb180cd4ea6f19251c17e89ddd330e9fc558b1e8909bda42b713d not in block 5ca17b85ce10702fd5ce8f63a5657905ae8ba41c7b7a886e8d13b317386dda06 at height 0"}, "id": "1551110795.042002"}
    // {"jsonrpc": "2.0", "result": {"block_height": 159894, "merkle": ["6dfe08d9ce1c116aa61628b6f4860b888294d60abf8591ab037cb5a94aef2fb4", "6fb4c032cb3a3789f87bfc2ae08760feee5dd23224c085fd93058a239c0a39bc", "92ace03f2aa89153e5546bec2b38d86ea110b9be1ae403352b6de0adabb4615e"], "pos": 3}, "id": "1551114239.77843"}
    //blockchain.transaction.get_merkle(tx_hash, height)
    //Return the merkle branch to a confirmed transaction given its hash and height.
    case getMerkle = "blockchain.transaction.get_merkle"
    
    //blockchain.scripthash.subscribe(scripthash)
    //? Subscribe to a script hash.
    //{"jsonrpc": "2.0", "result": "50c435752191aa92f978aa1967fa67361816df519a2d52a27d18690c170f0fbf", "id": "subscribeScrH MFC"}
    //{"jsonrpc": "2.0", "result": null, "id": "subscribeScrH BTC"}
    case subscribeScrH = "blockchain.scripthash.subscribe"
    
    //{"jsonrpc": "2.0", "result": ""tx_hash, "id": "BTC"}
    //blockchain.transaction.broadcast(raw_tx)
    //Broadcast a transaction to the network.
    case broadcast = "blockchain.transaction.broadcast"//?
    
    
    
    
   
    
    //blockchain.scripthash.utxos(scripthash, start_height)
    //? Return some confirmed UTXOs sent to a script hash.
    case utxos = "blockchain.scripthash.utxos"
    
    
    
    //?Subscribe to receive block headers when a new block is found.
    case subscribeHeaders = "blockchain.headers.subscribe"
    
    //blockchain.scripthash.get_mempool(scripthash)
    //? Return the unconfirmed transactions of a script hash.
    case getMempool = "blockchain.scripthash.get_mempool"
    
   
    
    //blockchain.scripthash.history(scripthash, start_height)
    //Return part of the confirmed history of a script hash
    case history = "blockchain.scripthash.history"
    

    
    //blockchain.block.headers(start_height, count, cp_height=0)
    //Return a concatenated chunk of block headers from the main chain.
    case headers = "blockchain.block.headers"
    
    //blockchain.block.header(height, cp_height=0)
    //Return the block header at the given height
    case header = "blockchain.block.header"
    
    
    
    //blockchain.transaction.id_from_pos(height, tx_pos, merkle=false)
    //Return a transaction hash and optionally a merkle proof, given a block height and a position in the block.
    case idFromPos = "blockchain.transaction.id_from_pos"
}

//blockchain.transaction.get(tx_hash, false) получаем hex
//{"jsonrpc": "2.0", "result": "0100000002bc014e39ffd36bbc85167c6426d6a0ede816aceae0d81d55134600b6a1cad8b4010000006a473044022044c698693546d685f410990be5e71c18303c8b919c2507a9ef66a32279ee3f49022010250302ca4f6d80a206b01a666f4059221e6b522f32f14b05a1a38f8af15d6f0121021f48bd635706a401bb0ac2082afdd00729f11bcb6a755d6fb5c4ba4f23aaac44ffffffff67a93f4e19e18d3dbb8795be169d1ee43ae04e5c18d084c7107e5f1ea682c996000000006a4730440220435b09e040090c6413036996cc43111283142ec31fc5ba0d3b81a2c5690e1a8802204fbc4814a24e692a967dbf3fa307c1f07352305946e0524a01d17360930357880121038178f1fd0a29c8d2ccd47033f6c053f1788daf3e6d5ec653d822c10e557bf797ffffffff0231e70f00000000001976a914f1d26d7e82ae448e0caa07ebca18c0d00d12495688ac00e40b54020000001976a9142ca82158e7309566656440badb0d868e9149f49788ac00000000", "id": "1551110318.087028"}

//blockchain.transaction.get(tx_hash, verbose=false, merkle=false)
//blockchain.transaction.get(tx_hash, true)
//{"jsonrpc": "2.0", "result": {"hex": "0100000002bc014e39ffd36bbc85167c6426d6a0ede816aceae0d81d55134600b6a1cad8b4010000006a473044022044c698693546d685f410990be5e71c18303c8b919c2507a9ef66a32279ee3f49022010250302ca4f6d80a206b01a666f4059221e6b522f32f14b05a1a38f8af15d6f0121021f48bd635706a401bb0ac2082afdd00729f11bcb6a755d6fb5c4ba4f23aaac44ffffffff67a93f4e19e18d3dbb8795be169d1ee43ae04e5c18d084c7107e5f1ea682c996000000006a4730440220435b09e040090c6413036996cc43111283142ec31fc5ba0d3b81a2c5690e1a8802204fbc4814a24e692a967dbf3fa307c1f07352305946e0524a01d17360930357880121038178f1fd0a29c8d2ccd47033f6c053f1788daf3e6d5ec653d822c10e557bf797ffffffff0231e70f00000000001976a914f1d26d7e82ae448e0caa07ebca18c0d00d12495688ac00e40b54020000001976a9142ca82158e7309566656440badb0d868e9149f49788ac00000000",
// "txid": "416172f81e3fb180cd4ea6f19251c17e89ddd330e9fc558b1e8909bda42b713d",
//"version": 1,
//"locktime": 0,
//"vin": [{"txid": "b4d8caa1b6004613551dd8e0eaac16e8eda0d626647c1685bc6bd3ff394e01bc", "vout": 1, "scriptSig": {"asm": "3044022044c698693546d685f410990be5e71c18303c8b919c2507a9ef66a32279ee3f49022010250302ca4f6d80a206b01a666f4059221e6b522f32f14b05a1a38f8af15d6f01 021f48bd635706a401bb0ac2082afdd00729f11bcb6a755d6fb5c4ba4f23aaac44",
//"hex": "473044022044c698693546d685f410990be5e71c18303c8b919c2507a9ef66a32279ee3f49022010250302ca4f6d80a206b01a666f4059221e6b522f32f14b05a1a38f8af15d6f0121021f48bd635706a401bb0ac2082afdd00729f11bcb6a755d6fb5c4ba4f23aaac44"}, "sequence": 4294967295},
//{"txid": "96c982a61e5f7e10c784d0185c4ee03ae41e9d16be9587bb3d8de1194e3fa967", "vout": 0, "scriptSig": {"asm": "30440220435b09e040090c6413036996cc43111283142ec31fc5ba0d3b81a2c5690e1a8802204fbc4814a24e692a967dbf3fa307c1f07352305946e0524a01d173609303578801 038178f1fd0a29c8d2ccd47033f6c053f1788daf3e6d5ec653d822c10e557bf797",
    //"hex": "4730440220435b09e040090c6413036996cc43111283142ec31fc5ba0d3b81a2c5690e1a8802204fbc4814a24e692a967dbf3fa307c1f07352305946e0524a01d17360930357880121038178f1fd0a29c8d2ccd47033f6c053f1788daf3e6d5ec653d822c10e557bf797"}, "sequence": 4294967295}],
//"vout": [{"value": 0.01042225, "n": 0, "scriptPubKey": {"asm": "OP_DUP OP_HASH160 f1d26d7e82ae448e0caa07ebca18c0d00d124956 OP_EQUALVERIFY OP_CHECKSIG", "hex": "76a914f1d26d7e82ae448e0caa07ebca18c0d00d12495688ac", "reqSigs": 1, "type": "pubkeyhash", "addresses": ["MuHQ9YV2cvuMojcyTp4VvKwuHDVTmbSJop"]}}, {"value": 100.0, "n": 1, "scriptPubKey": {"asm": "OP_DUP OP_HASH160 2ca82158e7309566656440badb0d868e9149f497 OP_EQUALVERIFY OP_CHECKSIG", "hex": "76a9142ca82158e7309566656440badb0d868e9149f49788ac", "reqSigs": 1, "type": "pubkeyhash", "addresses": ["MbJtMsgyx9DegEuWGgiLCSdie8NisPvPDm"]}}], "blockhash": "ac39d224287ba8e365a8ff7bceb775ae31d3e6b5be68d50185712014b7afec25", "confirmations": 1988, "time": 1550507154, "blocktime": 1550507154}, "id": "1551110170.946999"}

//
//  TxHistory.swift
//  MFCoin
//
//  Created by Admin on 29.03.2019.
//  Copyright © 2019 Egor Vdovin. All rights reserved.
//

import RealmSwift

class TxHistory: Object {
    @objc dynamic var confirmation = 0 // 11029 confirmation
    @objc dynamic var date = 0 // 1550507154 (+000) currentmillis
    @objc dynamic var nowDate = 0
    @objc dynamic var lockTime = 0
    @objc dynamic var value:Float = -1 //coins
    @objc dynamic var received = true //получено или отправлено
    @objc dynamic var address = "" //куда получили или куда отправили
    @objc dynamic var coinFullName = "" //MFCoin
    @objc dynamic var fee = 0 //transaction fee
    @objc dynamic var txid = ""
    
    convenience init(coin: CoinModel, tx: GetTxHistory, address: String, change: Int) {
        self.init()
        self.coinFullName = coin.fullName
        self.date = tx.result.time ?? 0
        self.nowDate = {
            guard let time = tx.result.time else { return 0 }
            if time == 0 {
                return 0
            }
            return (time - Int(Date.timeIntervalBetween1970AndReferenceDate*1000))
        }()
        self.lockTime = tx.result.locktime
        self.txid = tx.result.txid
        self.confirmation = tx.result.confirmations ?? 0
        self.value = {
            if change == 0 {
                for vout in tx.result.vout {
                    let addr = vout.scriptPubKey.addresses[0]
                    if addr == address {
                        self.received = true
                        self.address = address
                        return vout.value
                    }
                }
            }
            var newAddress = ""
            var value: Float = -1
            let filteredAddresses = coin.derPaths.filter({$0.change == 1 }).map({ return $0.address })
            for vout in tx.result.vout {
                var flag = false
                let vAddress = vout.scriptPubKey.addresses[0]
                for filteredAddress in filteredAddresses {
                    if vAddress == filteredAddress {
                        flag = true
                    }
                }
                if !flag {
                    newAddress = vAddress
                    value = vout.value
                }
            }
            self.received = false
            self.address = newAddress
            return value
            }()
    }

}


//external
//"jsonrpc": "2.0", "result": {
    //"hex": "010000000102d1827adaca30e5b5cb12efec8a75c9cdd6d57d2b1b1a324f1831497ce02176010000006a473044022053acd2990a7f4bb47e2a544cb8b436cf439fa56b814ed438a5ad16b178b84b5e022007492ed2471f9e74666c19ec7520c8ac8ee2179d631e95b0c12def2d270174be012103cf07bb95a4de7316205cf56381c97074b0e989cd350625ea9851938cb76ae2a8ffffffff0200c2eb0b000000001976a9142ca82158e7309566656440badb0d868e9149f49788acf804c7c6010000001976a91460e791c730fc79d13e47bb09e0dfb5f2f104151388ac00000000",
    //"txid": "7fd041e516380b5a08be6c49c12fd285fce9c711588973968c74d540ebe1547a",
    //"version": 1,
    //"locktime": 0,
    //"vin": [{
        //"txid": "7621e07c4931184f321a1b2b7dd5d6cdc9758aecef12cbb5e530cada7a82d102",
        //"vout": 1,
        //"scriptSig": {
            //"asm": "3044022053acd2990a7f4bb47e2a544cb8b436cf439fa56b814ed438a5ad16b178b84b5e022007492ed2471f9e74666c19ec7520c8ac8ee2179d631e95b0c12def2d270174be01 03cf07bb95a4de7316205cf56381c97074b0e989cd350625ea9851938cb76ae2a8",
            //"hex": "473044022053acd2990a7f4bb47e2a544cb8b436cf439fa56b814ed438a5ad16b178b84b5e022007492ed2471f9e74666c19ec7520c8ac8ee2179d631e95b0c12def2d270174be012103cf07bb95a4de7316205cf56381c97074b0e989cd350625ea9851938cb76ae2a8"},
        //"sequence": 4294967295}],
    //"vout": [{
        //"value": 2.0,
        //"n": 0,
        //"scriptPubKey": {
            //"asm": "OP_DUP OP_HASH160 2ca82158e7309566656440badb0d868e9149f497 OP_EQUALVERIFY OP_CHECKSIG",
            //"hex": "76a9142ca82158e7309566656440badb0d868e9149f49788ac",
            //"reqSigs": 1,
            //"type": "pubkeyhash",
            //"addresses": ["MbJtMsgyx9DegEuWGgiLCSdie8NisPvPDm"]}},
        //{"value": 76.29899,
        //"n": 1, "scriptPubKey": {
            //"asm": "OP_DUP OP_HASH160 60e791c730fc79d13e47bb09e0dfb5f2f1041513 OP_EQUALVERIFY OP_CHECKSIG",
            //"hex": "76a91460e791c730fc79d13e47bb09e0dfb5f2f104151388ac",
            //"reqSigs": 1,
            //"type": "pubkeyhash",
            //"addresses": ["Mg59VgVLGhAGb7GX7LdGyFce8RXEEXvgKr"]}}],
    //"blockhash": "0b6fe4f95bedb3a57704aff14c8022042052cdebaf2ee148422d9fc459e5251a",
    //"confirmations": 6100,
    //"time": 1551990801,
    //"blocktime": 1551990801},
//"id": "MFC1553838641.647321"}

//internal
//{"jsonrpc": "2.0", "result": {
    //"hex": "0100000002bc014e39ffd36bbc85167c6426d6a0ede816aceae0d81d55134600b6a1cad8b4010000006a473044022044c698693546d685f410990be5e71c18303c8b919c2507a9ef66a32279ee3f49022010250302ca4f6d80a206b01a666f4059221e6b522f32f14b05a1a38f8af15d6f0121021f48bd635706a401bb0ac2082afdd00729f11bcb6a755d6fb5c4ba4f23aaac44ffffffff67a93f4e19e18d3dbb8795be169d1ee43ae04e5c18d084c7107e5f1ea682c996000000006a4730440220435b09e040090c6413036996cc43111283142ec31fc5ba0d3b81a2c5690e1a8802204fbc4814a24e692a967dbf3fa307c1f07352305946e0524a01d17360930357880121038178f1fd0a29c8d2ccd47033f6c053f1788daf3e6d5ec653d822c10e557bf797ffffffff0231e70f00000000001976a914f1d26d7e82ae448e0caa07ebca18c0d00d12495688ac00e40b54020000001976a9142ca82158e7309566656440badb0d868e9149f49788ac00000000",
    //"txid": "416172f81e3fb180cd4ea6f19251c17e89ddd330e9fc558b1e8909bda42b713d",
    //"version": 1,
    //"locktime": 0,
    //"vin": [{
        //"txid": "b4d8caa1b6004613551dd8e0eaac16e8eda0d626647c1685bc6bd3ff394e01bc",
        //"vout": 1,
        //"scriptSig": {
            //"asm": "3044022044c698693546d685f410990be5e71c18303c8b919c2507a9ef66a32279ee3f49022010250302ca4f6d80a206b01a666f4059221e6b522f32f14b05a1a38f8af15d6f01 021f48bd635706a401bb0ac2082afdd00729f11bcb6a755d6fb5c4ba4f23aaac44",
            //"hex": "473044022044c698693546d685f410990be5e71c18303c8b919c2507a9ef66a32279ee3f49022010250302ca4f6d80a206b01a666f4059221e6b522f32f14b05a1a38f8af15d6f0121021f48bd635706a401bb0ac2082afdd00729f11bcb6a755d6fb5c4ba4f23aaac44"},
            //"sequence": 4294967295},
        //{"txid": "96c982a61e5f7e10c784d0185c4ee03ae41e9d16be9587bb3d8de1194e3fa967",
        //"vout": 0,
        //"scriptSig": {
            //"asm": "30440220435b09e040090c6413036996cc43111283142ec31fc5ba0d3b81a2c5690e1a8802204fbc4814a24e692a967dbf3fa307c1f07352305946e0524a01d173609303578801 038178f1fd0a29c8d2ccd47033f6c053f1788daf3e6d5ec653d822c10e557bf797",
            //"hex": "4730440220435b09e040090c6413036996cc43111283142ec31fc5ba0d3b81a2c5690e1a8802204fbc4814a24e692a967dbf3fa307c1f07352305946e0524a01d17360930357880121038178f1fd0a29c8d2ccd47033f6c053f1788daf3e6d5ec653d822c10e557bf797"},
            //"sequence": 4294967295}],
    //"vout": [{
        //"value": 0.01042225,
        //"n": 0,
        //"scriptPubKey": {
            //"asm": "OP_DUP OP_HASH160 f1d26d7e82ae448e0caa07ebca18c0d00d124956 OP_EQUALVERIFY OP_CHECKSIG",
            //"hex": "76a914f1d26d7e82ae448e0caa07ebca18c0d00d12495688ac",
            //"reqSigs": 1,
            //"type": "pubkeyhash",
            //"addresses": ["MuHQ9YV2cvuMojcyTp4VvKwuHDVTmbSJop"]}},
        //{"value": 100.0,
        //"n": 1,
        //"scriptPubKey": {
            //"asm": "OP_DUP OP_HASH160 2ca82158e7309566656440badb0d868e9149f497 OP_EQUALVERIFY OP_CHECKSIG",
            //"hex": "76a9142ca82158e7309566656440badb0d868e9149f49788ac",
            //"reqSigs": 1,
            //"type": "pubkeyhash",
            //"addresses": ["MbJtMsgyx9DegEuWGgiLCSdie8NisPvPDm"]}}],
    //"blockhash": "ac39d224287ba8e365a8ff7bceb775ae31d3e6b5be68d50185712014b7afec25",
    //"confirmations": 11029,
    //"time": 1550507154,
    //"blocktime": 1550507154},
//"id": "MFC1553838636.217914"}


//{"jsonrpc": "2.0", "result": {
        //"hex": "0100000001ff4b7d0ac14accf0e0e5c95644268c456b27ce60f3db192757a9caa5842fed84010000006a473044022009976c722a981bc8d9d2ee201c4ce96305d1c5033d6d88256dd7c6a8596f9eec02203266c1695f7343c33097b9e1ee3899a79f07cf6e426b8997ab1fb552c7af8241012103cf07bb95a4de7316205cf56381c97074b0e989cd350625ea9851938cb76ae2a8ffffffff0200e1f505000000001976a9141d3f830921c53813aa346d412c3da046118a36f688acb09a7805000000001976a91495e9dcbc0b4feb4fc44470ea2834d0c35c7435f788ac00000000",
        //"txid": "cfaa8d0d52d765061896fa93f8ae12745759adf0f7a7285456fe56f0b4404015",
        //"version": 1,
        //"locktime": 0,
        //"vin": [{
                //"txid": "84ed2f84a5caa9572719dbf360ce276b458c264456c9e5e0f0cc4ac10a7d4bff",
                //"vout": 1,
                //"scriptSig": {
                        //"asm": "3044022009976c722a981bc8d9d2ee201c4ce96305d1c5033d6d88256dd7c6a8596f9eec02203266c1695f7343c33097b9e1ee3899a79f07cf6e426b8997ab1fb552c7af824101 03cf07bb95a4de7316205cf56381c97074b0e989cd350625ea9851938cb76ae2a8",
                        //"hex": "473044022009976c722a981bc8d9d2ee201c4ce96305d1c5033d6d88256dd7c6a8596f9eec02203266c1695f7343c33097b9e1ee3899a79f07cf6e426b8997ab1fb552c7af8241012103cf07bb95a4de7316205cf56381c97074b0e989cd350625ea9851938cb76ae2a8"},
                //"sequence": 4294967295}],
        //"vout": [{
                //"value": 1.0,
                //"n": 0,
                //"scriptPubKey": {
                        //"asm": "OP_DUP OP_HASH160 1d3f830921c53813aa346d412c3da046118a36f6 OP_EQUALVERIFY OP_CHECKSIG",
                        //"hex": "76a9141d3f830921c53813aa346d412c3da046118a36f688ac",
                        //"reqSigs": 1,
                        //"type": "pubkeyhash",
                        //"addresses": ["MZuQtyyULCaZvMtXvSrevYZN8UuP44NQBU"]}},
                //{"value": 0.9179,
                //"n": 1,
                //"scriptPubKey": {
                        //"asm": "OP_DUP OP_HASH160 95e9dcbc0b4feb4fc44470ea2834d0c35c7435f7 OP_EQUALVERIFY OP_CHECKSIG",
                        //"hex": "76a91495e9dcbc0b4feb4fc44470ea2834d0c35c7435f788ac",
                        //"reqSigs": 1,
                        //"type": "pubkeyhash",
                        //"addresses": ["MkuS49x3BVt2MKtLUnbvN7K4z2586cvq3g"]}}
        //]},
//"id": "MFC1555152641.646181"}

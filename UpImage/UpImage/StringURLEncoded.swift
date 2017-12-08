//
//  StringURLEncoded.swift
//  UpImage
//
//  Created by 卓明 on 2017/12/8.
//  Copyright © 2017年 卓明. All rights reserved.
//

import Foundation
extension String {
    
    //将原始的url编码为合法的url
    func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
    
    //将编码后的url转换回原始的url
    func urlDecoded() -> String {
        return self.removingPercentEncoding ?? ""
    }
}

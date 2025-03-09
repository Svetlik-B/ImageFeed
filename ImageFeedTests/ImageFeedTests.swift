//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Svetlana Bochkareva on 21.12.2024.
//

import Testing
@testable import ImageFeed

struct ImageFeedTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    @Test("Правильно извлекать код из URL")
    func codeFromUrlString_extract() {
        let urlString = "https://unsplash.com/oauth/authorize/native?code=YDMl20b37sKUYAgVH-Yq5Yh3zOrnt53OaWDiKpvfOAQ"
        #expect(AuthHelper().code(from: urlString) == "YDMl20b37sKUYAgVH-Yq5Yh3zOrnt53OaWDiKpvfOAQ")
    }
    @Test("Должна проверять путь oauth/authorize/native")
    func codeFromUrlString_checkPath() {
        let urlString = "https://unsplash.com/oauth_/authorize/native?code=YDMl20b37sKUYAgVH-Yq5Yh3zOrnt53OaWDiKpvfOAQ"
        #expect(AuthHelper().code(from: urlString) == nil)
    }

}

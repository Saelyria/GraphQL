// Generated using Sourcery 1.5.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import XCTest
@testable import Artemis

// MARK: - Tests to ensure single selections of TestObject and [TestObject] render as expected

extension TestInterface4_TestObject_TypeTests {
    func testSingleRender() {
        let query: _Operation<Query, SelectionType.Result> = .query {
            $0.i4_testObject { $0.int }
        }
        let response = Data("""
        {
            "data": {
                "i4_testObject": { "int": 321 }
            }
        }
        """.utf8)

        XCTAssertEqual(query.render(), "{i4_testObject{int}}")
        let res = try? query.createResult(from: response)
        XCTAssertEqual(res?.int, 321)
    }

    func testSingleArgsRender() {
        let query: _Operation<Query, SelectionType.Result> = .query {
            $0.i4_testObjectArgs(arguments: .testDefault) { $0.int }
        }
        let response = Data("""
        {
            "data": {
                "i4_testObjectArgs": { "int": 321 }
            }
        }
        """.utf8)

        XCTAssertEqual(query.render(), "{i4_testObjectArgs\(testArgs){int}}")
        let res = try? query.createResult(from: response)
        XCTAssertEqual(res?.int, 321)
    }

    func testArrayRender() {
        let query: _Operation<Query, [SelectionType.Result]> = .query {
            $0.i4_testObjects { $0.int }
        }
        let response = Data("""
        {
            "data": {
                "i4_testObjects": [{ "int": 321 }, { "int": 123 }]
            }
        }
        """.utf8)

        XCTAssertEqual(query.render(), "{i4_testObjects{int}}")
        let res = try? query.createResult(from: response)
        XCTAssertEqual(res?.count, 2)
        XCTAssertEqual(res?[safe: 0]?.int, 321)
        XCTAssertEqual(res?[safe: 1]?.int, 123)
    }

    func testOptionalRender() {
        let query: _Operation<Query, SelectionType.Result> = .query {
            $0.i4_testObjectOptional { $0.int }
        }
        let response = Data("""
        {
            "data": {
                "i4_testObjectOptional": { "int": 321 }
            }
        }
        """.utf8)

        XCTAssertEqual(query.render(), "{i4_testObjectOptional{int}}")
        let res = try? query.createResult(from: response)
        XCTAssertEqual(res?.int, 321)
    }
}

// MARK: - Tests to ensure single selections of TestObject and [TestObject] with aliases render as expected

extension TestInterface4_TestObject_TypeTests {
    func testSingleAliasRender() {
        let query: _Operation<Query, SelectionType.Result> = .query {
            $0.i4_testObject(alias: "alias") { $0.int }
        }
        let response = Data("""
        {
            "data": {
                "alias": { "int": 321 }
            }
        }
        """.utf8)

        XCTAssertEqual(query.render(), "{alias:i4_testObject{int}}")
        let res = try? query.createResult(from: response)
        XCTAssertEqual(res?.int, 321)
    }

    func testSingleArgsAliasRender() {
        let query: _Operation<Query, SelectionType.Result> = .query {
            $0.i4_testObjectArgs(alias: "alias", arguments: .testDefault) { $0.int }
        }
        let response = Data("""
        {
            "data": {
                "alias": { "int": 321 }
            }
        }
        """.utf8)

        XCTAssertEqual(query.render(), "{alias:i4_testObjectArgs\(testArgs){int}}")
        let res = try? query.createResult(from: response)
        XCTAssertEqual(res?.int, 321)
    }
}

// MARK: - Tests to ensure selections render as expected on selections of TestObject and [TestObject] on an Object

extension TestInterface4_TestObject_TypeTests {
    func testSingleOnObjectRender() {
        let query: _Operation<Query, Partial<TestObject>> = .query {
            $0.testObject {
                $0.i4_testObject { $0.int }
            }
        }
        let response = Data("""
        {
            "data": {
                "testObject": {
                    "i4_testObject": { "int": 321 }
                }
            }
        }
        """.utf8)

        XCTAssertEqual(query.render(), "{testObject{i4_testObject{int}}}")
        let res: Partial<TestObject>? = try? query.createResult(from: response)
        XCTAssertEqual(res?.values.count, 1)
        XCTAssertEqual(res?.i4_testObject?.int, 321)
    }

    func testSingleArgsOnObjectRender() {
        let query: _Operation<Query, Partial<TestObject>> = .query {
            $0.testObject {
                $0.i4_testObjectArgs(arguments: .testDefault) { $0.int }
            }
        }
        let response = Data("""
        {
            "data": {
                "testObject": {
                    "i4_testObjectArgs": { "int": 321 }
                }
            }
        }
        """.utf8)

        XCTAssertEqual(query.render(), "{testObject{i4_testObjectArgs\(testArgs){int}}}")
        let res: Partial<TestObject>? = try? query.createResult(from: response)
        XCTAssertEqual(res?.values.count, 1)
        XCTAssertEqual(res?.i4_testObjectArgs?.int, 321)
    }

    func testArrayOnObjectRender() {
        let query: _Operation<Query, Partial<TestObject>> = .query {
            $0.testObject {
                $0.i4_testObjects { $0.int }
            }
        }
        let response = Data("""
        {
            "data": {
                "testObject": {
                    "i4_testObjects": [{ "int": 321 }, { "int": 123 }]
                }
            }
        }
        """.utf8)

        XCTAssertEqual(query.render(), "{testObject{i4_testObjects{int}}}")
        let res: Partial<TestObject>? = try? query.createResult(from: response)
        XCTAssertEqual(res?.values.count, 1)
        XCTAssertEqual(res?.i4_testObjects?.count, 2)
        XCTAssertEqual(res?.i4_testObjects?[safe: 0]?.int, 321)
        XCTAssertEqual(res?.i4_testObjects?[safe: 1]?.int, 123)
    }

    func testOptionalOnObjectRender() {
        let query: _Operation<Query, Partial<TestObject>> = .query {
            $0.testObject {
                $0.i4_testObjectOptional { $0.int }
            }
        }
        let response = Data("""
        {
            "data": {
                "testObject": {
                    "i4_testObjectOptional": { "int": 321 }
                }
            }
        }
        """.utf8)

        XCTAssertEqual(query.render(), "{testObject{i4_testObjectOptional{int}}}")
        let res: Partial<TestObject>? = try? query.createResult(from: response)
        XCTAssertEqual(res?.values.count, 1)
        XCTAssertEqual(res?.i4_testObjectOptional?.int, 321)
    }
}

// MARK: - Tests to ensure an alias of TestObject and [TestObject] on an Object can be used to pull values out of a result

extension TestInterface4_TestObject_TypeTests {
    func testSingleAliasOnObject() throws {
        let query: _Operation<Query, Partial<TestObject>> = .query {
            $0.testObject {
                $0.i4_testObject(alias: "alias") { $0.int }
            }
        }
        let response = Data("""
        {
            "data": {
                "testObject": {
                    "alias": { "int": 321 }
                }
            }
        }
        """.utf8)

        XCTAssertEqual(query.render(), "{testObject{alias:i4_testObject{int}}}")
        let res: Partial<TestObject>? = try? query.createResult(from: response)
        XCTAssertEqual(res?.values.count, 1)
        let aliased = res?.get(\.i4_testObject, alias: "alias")
        XCTAssertEqual(aliased?.int, 321)
    }

    func testSingleArgsAliasOnObject() throws {
        let query: _Operation<Query, Partial<TestObject>> = .query {
            $0.testObject {
                $0.i4_testObjectArgs(alias: "alias", arguments: .testDefault) { $0.int }
            }
        }
        let response = Data("""
        {
            "data": {
                "testObject": {
                    "alias": { "int": 321 }
                }
            }
        }
        """.utf8)

        XCTAssertEqual(query.render(), "{testObject{alias:i4_testObjectArgs\(testArgs){int}}}")
        let res: Partial<TestObject>? = try? query.createResult(from: response)
        XCTAssertEqual(res?.values.count, 1)
        let aliased = res?.get(\.i4_testObjectArgs, alias: "alias")
        XCTAssertEqual(aliased?.int, 321)
    }
}

// MARK: - Tests to ensure fragments on Query selecting TestObject and [TestObject] can be used at the top level of an operation

extension TestInterface4_TestObject_TypeTests {
    func testSingleOnFragmentRender() {
        let fragment = Fragment("fragName", on: Query.self) {
            $0.i4_testObject { $0.int }
        }
        let query: _Operation<Query, SelectionType.Result> = .query {
            fragment
        }
        let response = Data("""
        {
            "data": {
                "i4_testObject": { "int": 321 }
            }
        }
        """.utf8)

        XCTAssertEqual(query.render(), "{...fragName},fragment fragName on Query{i4_testObject{int}}")
        let res = try? query.createResult(from: response)
        XCTAssertEqual(res?.int, 321)
    }

    func testSingleArgsOnFragmentRender() {
        let fragment = Fragment("fragName", on: Query.self) {
            $0.i4_testObjectArgs(arguments: .testDefault) { $0.int }
        }
        let query: _Operation<Query, SelectionType.Result> = .query {
            fragment
        }
        let response = Data("""
        {
            "data": {
                "i4_testObjectArgs": { "int": 321 }
            }
        }
        """.utf8)

        XCTAssertEqual(query.render(), "{...fragName},fragment fragName on Query{i4_testObjectArgs\(testArgs){int}}")
        let res = try? query.createResult(from: response)
        XCTAssertEqual(res?.int, 321)
    }

    func testArrayOnFragmentRender() {
        let fragment = Fragment("fragName", on: Query.self) {
            $0.i4_testObjects { $0.int }
        }
        let query: _Operation<Query, [SelectionType.Result]> = .query {
            fragment
        }
        let response = Data("""
        {
            "data": {
                "i4_testObjects": [{ "int": 321 }, { "int": 123 }]
            }
        }
        """.utf8)

        XCTAssertEqual(query.render(), "{...fragName},fragment fragName on Query{i4_testObjects{int}}")
        let res = try? query.createResult(from: response)
        XCTAssertEqual(res?.count, 2)
        XCTAssertEqual(res?[safe: 0]?.int, 321)
        XCTAssertEqual(res?[safe: 1]?.int, 123)
    }

    func testOptionalOnFragmentRender() {
        let fragment = Fragment("fragName", on: Query.self) {
            $0.i4_testObjectOptional { $0.int }
        }
        let query: _Operation<Query, SelectionType.Result> = .query {
            fragment
        }
        let response = Data("""
        {
            "data": {
                "i4_testObjectOptional": { "int": 321 }
            }
        }
        """.utf8)

        XCTAssertEqual(query.render(), "{...fragName},fragment fragName on Query{i4_testObjectOptional{int}}")
        let res = try? query.createResult(from: response)
        XCTAssertEqual(res?.int, 321)
    }
}

// MARK: - Tests to ensure fragments on Query selecting TestObject and [TestObject] can be used at the top level of an operation with aliases

extension TestInterface4_TestObject_TypeTests {
    func testSingleAliasOnFragment() {
        let fragment = Fragment("fragName", on: Query.self) {
            $0.i4_testObject(alias: "alias") { $0.int }
        }
        let query: _Operation<Query, SelectionType.Result> = .query {
            fragment
        }
        let response = Data("""
        {
            "data": {
                "alias": { "int": 321 }
            }
        }
        """.utf8)

        XCTAssertEqual(query.render(), "{...fragName},fragment fragName on Query{alias:i4_testObject{int}}")
        let res = try? query.createResult(from: response)
        XCTAssertEqual(res?.int, 321)
    }

    func testSingleArgsAliasOnFragment() {
        let fragment = Fragment("fragName", on: Query.self) {
            $0.i4_testObjectArgs(alias: "alias", arguments: .testDefault) { $0.int }
        }
        let query: _Operation<Query, SelectionType.Result> = .query {
            fragment
        }
        let response = Data("""
        {
            "data": {
                "alias": { "int": 321 }
            }
        }
        """.utf8)

        XCTAssertEqual(query.render(), "{...fragName},fragment fragName on Query{alias:i4_testObjectArgs\(testArgs){int}}")
        let res = try? query.createResult(from: response)
        XCTAssertEqual(res?.int, 321)
    }
}
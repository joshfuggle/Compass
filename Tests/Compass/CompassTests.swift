import Foundation
import XCTest
import Compass

class CompassTests: XCTestCase {

  override func setUp() {
    Compass.scheme = "compassTests"
    Compass.routes = [
      "profile:{user}",
      "profile:admin",
      "login",
      "callback",
      "user:list:{userId}:{kind}",
      "user:list",
      "{appId}:user:list:{userId}:{kind}"
    ].shuffle()
  }

  func testScheme() {
    XCTAssertEqual(Compass.scheme, "compassTests://")
  }

  func testRoutes() {
    XCTAssert(!Compass.routes.isEmpty)
    XCTAssert(Compass.routes.count == 7)
  }

  func testParseArguments() {
    let url = NSURL(string: "compassTests://profile:testUser")!

    guard let location = Compass.parse(url) else {
      XCTFail("Compass parsing failed")
      return
    }

    XCTAssertEqual("profile:{user}", location.path)
    XCTAssertEqual(location.arguments["user"], "testUser")
  }

  func testParseFragments() {
    let url = NSURL(string: "compassTests://profile:testUser")!

    guard let location = Compass.parse(url, fragments: ["meta" : "foo"]) else {
      XCTFail("Compass parsing failed")
      return
    }

    XCTAssertEqual("profile:{user}", location.path)
    XCTAssertEqual(location.arguments["user"], "testUser")
    XCTAssertEqual("foo" , location.fragments["meta"] as? String)
  }

  func testParseRouteConcreateMatchCount() {
    let url = NSURL(string: "compassTests://profile:admin")!

    guard let location = Compass.parse(url) else {
      XCTFail("Compass parsing failed")
      return
    }

    XCTAssertEqual("profile:admin", location.path)
    XCTAssert(location.arguments.isEmpty)
  }

  func testParseRouteWildcardMatchCount() {
    let url = NSURL(string: "compassTests://profile:jack")!

    guard let location = Compass.parse(url) else {
      XCTFail("Compass parsing failed")
      return
    }

    XCTAssertEqual("profile:{user}", location.path)
    XCTAssertEqual(location.arguments["user"], "jack")
  }

  func testParseRouteSamePrefix() {
    let url = NSURL(string: "compassTests://user:list")!

    guard let location = Compass.parse(url) else {
      XCTFail("Compass parsing failed")
      return
    }

    XCTAssertEqual("user:list", location.path)
    XCTAssert(location.arguments.isEmpty)
  }

  func testParseMultipleArguments() {
    let url = NSURL(string: "compassTests://user:list:1:admin")!

    guard let location = Compass.parse(url) else {
      XCTFail("Compass parsing failed")
      return
    }

    XCTAssertEqual("user:list:{userId}:{kind}", location.path)
    XCTAssertEqual(location.arguments["userId"], "1")
    XCTAssertEqual(location.arguments["kind"], "admin")
  }

  func testParseMultipleArgumentsWithFirstWildcard() {
    let url = NSURL(string: "compassTests://12:user:list:1:admin")!

    guard let location = Compass.parse(url) else {
      XCTFail("Compass parsing failed")
      return
    }

    XCTAssertEqual("{appId}:user:list:{userId}:{kind}", location.path)
    XCTAssertEqual(location.arguments["appId"], "12")
    XCTAssertEqual(location.arguments["userId"], "1")
    XCTAssertEqual(location.arguments["kind"], "admin")
  }

  func testParseWithoutArguments() {
    let url = NSURL(string: "compassTests://login")!

    guard let location = Compass.parse(url) else {
      XCTFail("Compass parsing failed")
      return
    }

    XCTAssertEqual("login", location.path)
    XCTAssert(location.arguments.isEmpty)
  }

  func testParseRegularURLWithFragments() {
    let url = NSURL(string: "compassTests://callback/#access_token=IjvcgrkQk1p7TyJxKa26rzM1wBMFZW6XoHK4t5Gkt1xQLTN8l7ppR0H3EZXpoP0uLAN49oCDqTHsvnEV&token_type=Bearer&expires_in=3600")!

    guard let location = Compass.parse(url) else {
      XCTFail("Compass parsing failed")
      return
    }

    XCTAssertEqual(location.path, "callback")
    XCTAssertEqual(location.arguments.count, 3)
    XCTAssertEqual(location.arguments["access_token"], "IjvcgrkQk1p7TyJxKa26rzM1wBMFZW6XoHK4t5Gkt1xQLTN8l7ppR0H3EZXpoP0uLAN49oCDqTHsvnEV")
    XCTAssertEqual(location.arguments["expires_in"], "3600")
    XCTAssertEqual(location.arguments["token_type"], "Bearer")
  }

  func testParseRegularURLWithFragmentsAndGoogleOAuth2AccessToken() {
    let url = NSURL(string: "compassTests://callback/#access_token=ya29.Ci8nA1pNVMFffHkS5-sXooNGvTB9q8QPtoM56sWpipRyjhwwEiKyZxvRQTR8saqWzQ&token_type=Bearer&expires_in=3600")!

    guard let location = Compass.parse(url) else {
      XCTFail("Compass parsing failed")
      return
    }

    XCTAssertEqual(location.path, "callback")
    XCTAssertEqual(location.arguments.count, 3)
    XCTAssertEqual(location.arguments["access_token"], "ya29.Ci8nA1pNVMFffHkS5-sXooNGvTB9q8QPtoM56sWpipRyjhwwEiKyZxvRQTR8saqWzQ")
    XCTAssertEqual(location.arguments["expires_in"], "3600")
    XCTAssertEqual(location.arguments["token_type"], "Bearer")
  }

  func testParseRegularURLWithFragmentsAndAlternativeAccessToken() {
    let url = NSURL(string: "compassTests://callback/#access_token=ya29.Ci8nA1pNVMFffHkS5-sXooNGvTB9q8QPtoM56sWpipRyjhwwEiKyZxvRQTR8saqWzQ=&token_type=Bearer&expires_in=3600")!

    guard let location = Compass.parse(url) else {
      XCTFail("Compass parsing failed")
      return
    }

    XCTAssertEqual(location.path, "callback")
    XCTAssertEqual(location.arguments.count, 3)
    XCTAssertEqual(location.arguments["access_token"], "ya29.Ci8nA1pNVMFffHkS5-sXooNGvTB9q8QPtoM56sWpipRyjhwwEiKyZxvRQTR8saqWzQ=")
    XCTAssertEqual(location.arguments["expires_in"], "3600")
    XCTAssertEqual(location.arguments["token_type"], "Bearer")
  }

  func testParseRegularURLWithSlashQuery() {
    let url = NSURL(string: "compassTests://callback/?access_token=Yo0OMrVZbRWNmgA6BT99hyuTUTNRGvqEEAQyeN1eslclzhFD0M8AidB4Z7Vs2NU8WoSNW0vYb961O38l&token_type=Bearer&expires_in=3600")!

    guard let location = Compass.parse(url) else {
      XCTFail("Compass parsing failed")
      return
    }

    XCTAssertEqual(location.path, "callback")
    XCTAssertEqual(location.arguments.count, 3)
    XCTAssertEqual(location.arguments["access_token"], "Yo0OMrVZbRWNmgA6BT99hyuTUTNRGvqEEAQyeN1eslclzhFD0M8AidB4Z7Vs2NU8WoSNW0vYb961O38l")
    XCTAssertEqual(location.arguments["expires_in"], "3600")
    XCTAssertEqual(location.arguments["token_type"], "Bearer")
  }

  func testParseRegularURLWithSlashQueryAndGoogleOAuth2AccessToken() {
    let url = NSURL(string: "compassTests://callback/?access_token=ya29.Ci8nA1pNVMFffHkS5-sXooNGvTB9q8QPtoM56sWpipRyjhwwEiKyZxvRQTR8saqWzQ&token_type=Bearer&expires_in=3600")!

    guard let location = Compass.parse(url) else {
      XCTFail("Compass parsing failed")
      return
    }

    XCTAssertEqual(location.path, "callback")
    XCTAssertEqual(location.arguments.count, 3)
    XCTAssertEqual(location.arguments["access_token"], "ya29.Ci8nA1pNVMFffHkS5-sXooNGvTB9q8QPtoM56sWpipRyjhwwEiKyZxvRQTR8saqWzQ")
    XCTAssertEqual(location.arguments["expires_in"], "3600")
    XCTAssertEqual(location.arguments["token_type"], "Bearer")
  }

  func testParseRegularURLWithSlashQueryAndAlternativeAccessToken() {
    let url = NSURL(string: "compassTests://callback/?access_token=ya29.Ci8nA1pNVMFffHkS5-sXooNGvTB9q8QPtoM56sWpipRyjhwwEiKyZxvRQTR8saqWzQ=&token_type=Bearer&expires_in=3600")!

    guard let location = Compass.parse(url) else {
      XCTFail("Compass parsing failed")
      return
    }

    XCTAssertEqual(location.path, "callback")
    XCTAssertEqual(location.arguments.count, 3)
    XCTAssertEqual(location.arguments["access_token"], "ya29.Ci8nA1pNVMFffHkS5-sXooNGvTB9q8QPtoM56sWpipRyjhwwEiKyZxvRQTR8saqWzQ=")
    XCTAssertEqual(location.arguments["expires_in"], "3600")
    XCTAssertEqual(location.arguments["token_type"], "Bearer")
  }

  func testParseRegularURLWithQuery() {
    let url = NSURL(string: "compassTests://callback?access_token=Yo0OMrVZbRWNmgA6BT99hyuTUTNRGvqEEAQyeN1eslclzhFD0M8AidB4Z7Vs2NU8WoSNW0vYb961O38l&token_type=Bearer&expires_in=3600")!

    guard let location = Compass.parse(url) else {
      XCTFail("Compass parsing failed")
      return
    }

    XCTAssertEqual(location.path, "callback")
    XCTAssertEqual(location.arguments.count, 3)
    XCTAssertEqual(location.arguments["access_token"], "Yo0OMrVZbRWNmgA6BT99hyuTUTNRGvqEEAQyeN1eslclzhFD0M8AidB4Z7Vs2NU8WoSNW0vYb961O38l")
    XCTAssertEqual(location.arguments["expires_in"], "3600")
    XCTAssertEqual(location.arguments["token_type"], "Bearer")
  }

  func testParseRegularURLWithQueryAndGoogleOAuth2AccessToken() {
    let url = NSURL(string: "compassTests://callback?access_token=ya29.Ci8nA1pNVMFffHkS5-sXooNGvTB9q8QPtoM56sWpipRyjhwwEiKyZxvRQTR8saqWzQ&token_type=Bearer&expires_in=3600")!

    guard let location = Compass.parse(url) else {
      XCTFail("Compass parsing failed")
      return
    }

    XCTAssertEqual(location.path, "callback")
    XCTAssertEqual(location.arguments.count, 3)
    XCTAssertEqual(location.arguments["access_token"], "ya29.Ci8nA1pNVMFffHkS5-sXooNGvTB9q8QPtoM56sWpipRyjhwwEiKyZxvRQTR8saqWzQ")
    XCTAssertEqual(location.arguments["expires_in"], "3600")
    XCTAssertEqual(location.arguments["token_type"], "Bearer")
  }

  func testParseRegularURLWithQueryAndAlternativeAccessToken() {
    let url = NSURL(string: "compassTests://callback?access_token=ya29.Ci8nA1pNVMFffHkS5-sXooNGvTB9q8QPtoM56sWpipRyjhwwEiKyZxvRQTR8saqWzQ=&token_type=Bearer&expires_in=3600")!

    guard let location = Compass.parse(url) else {
      XCTFail("Compass parsing failed")
      return
    }

    XCTAssertEqual(location.path, "callback")
    XCTAssertEqual(location.arguments.count, 3)
    XCTAssertEqual(location.arguments["access_token"], "ya29.Ci8nA1pNVMFffHkS5-sXooNGvTB9q8QPtoM56sWpipRyjhwwEiKyZxvRQTR8saqWzQ=")
    XCTAssertEqual(location.arguments["expires_in"], "3600")
    XCTAssertEqual(location.arguments["token_type"], "Bearer")
  }
}

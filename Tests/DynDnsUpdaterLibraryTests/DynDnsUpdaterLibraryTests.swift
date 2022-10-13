import XCTest
@testable import DynDnsUpdaterLibrary

class MockStringContentsOf {
    var url: URL?

    init(contentsOf url: URL) throws {
        self.url = url
        //...
    }
}

final class DynDnsUpdaterLibraryTests: XCTestCase {
    func testInit() throws {
        let d = DynDnsUpdaterLib(forIsCli: true)
        XCTAssertEqual(d.isCli, true)
    }
    
    func testReportErrorAndExitNoCli() throws {
        var d = DynDnsUpdaterLib(forIsCli: false)
        XCTAssertEqual(d.reportError("Evil error"), d.RED + d.BOLD + "ERROR " + d.RESET + "Evil error")
    }
    
    func testReportErrorAndExitCli() throws {
        var d = DynDnsUpdaterLib(forIsCli: true)
        d.reportError("Evil Error")
        
        XCTAssertEqual(d.capturedOutput, d.RED + d.BOLD + "ERROR " + d.RESET + "Evil Error -- exiting\r\n")
    }
    
    func testWriteToStderrNoCli() throws {
        var d = DynDnsUpdaterLib(forIsCli: false)

        d.writeToStderr("Evil Error")
        
        XCTAssertEqual(d.capturedOutput, "")
    }
    
    func testWriteSuccessCli() throws {
        var d = DynDnsUpdaterLib(forIsCli: true)

        d.writeSuccess("What a wonderful world")
        
        XCTAssertEqual(d.capturedOutput, d.GREEN + d.BOLD + "OK " + d.RESET + "What a wonderful world\r\n")
    }

    func testWriteSuccessNoCli() throws {
        var d = DynDnsUpdaterLib(forIsCli: false)

        d.writeSuccess("Evil Error")
        
        XCTAssertEqual(d.capturedOutput, "")
    }
}

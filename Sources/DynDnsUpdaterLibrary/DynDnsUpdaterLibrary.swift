import Foundation

public struct DynDnsUpdaterLib {
    internal enum DynDnyUpaterError: Error {
        case getContent(message: String)
        case badUrl(message: String)
    }
    
    public let BLACK   = "\u{001B}[30m"
    public let RED     = "\u{001B}[31m"
    public let GREEN   = "\u{001B}[32m"
    public let YELLOW  = "\u{001B}[33m"
    public let BLUE    = "\u{001B}[34m"
    public let MAGENTA = "\u{001B}[35m"
    public let CYAN    = "\u{001B}[36m"
    public let WHITE   = "\u{001B}[37m"

    public let RESET  = "\u{001B}[0m"

    public let BOLD      = "\u{001B}[1m"
    public let ITALIC    = "\u{001B}[3m"
    public let UNDERLINE = "\u{001B}[4m"
    public let FLASH     = "\u{001B}[5m"

    public let STD_ERR = FileHandle.standardError
    public let STD_OUT = FileHandle.standardOutput

    public let ipURI = "https://ipecho.net/plain"
    public let updateURI = "https://carol.selfhost.de/update?username=478129&password=frefMeunn9&textmodi=1"

    public private(set) var isCli = true
    public private(set) var externalIP = ""
    public private(set) var uri = ""
    public private(set) var response = ""
    
    public private(set) var thrownError = ""

    public init(forIsCli isCli: Bool) {
        self.isCli = isCli
    }
    

    public mutating func update()-> Bool {
        do {
            self.externalIP = try curl(ipURI)
        } catch {
            self.thrownError = "\(error)"
            return false
        }
        
        self.uri = updateURI + "&myip=" + externalIP
        
        do {
            self.response = try curl(uri)
        } catch {
            self.thrownError = "\(error)"
            return false
        }

        if(self.isCli == true) {
            writeSuccess("Dyn DNS Update: \(self.response)")
        }
        
        return true
    }

    public func curl(_ uri: String)throws ->(String) {
        var contents = ""

        if let url = URL(string: uri) {

            do {
                contents = try String(contentsOf: url)
            } catch {
                var message = "Exception by get the content: \(error)"
                
                if(self.isCli == true) {
                    self.reportErrorAndExit(message)
                }
                else {
                    throw DynDnyUpaterError.getContent(message: message)
                }
            }

        } else {
            var message = "Bad URL: \(uri)"
            
            if(self.isCli == true) {
                self.reportErrorAndExit(message)
            }
            else
            {
                throw DynDnyUpaterError.badUrl(message: message)
            }
        }

        return contents
    }

    public func writeToStdout(_ message: String) {
        let messageAsString = message + "\r\n"
        if let messageAsData: Data = messageAsString.data(using: .utf8) {
            self.STD_OUT.write(messageAsData)
        }
    }

    public func writeSuccess(_ message: String) {
        if self.isCli == true {
            writeToStdout(self.GREEN + self.BOLD + "OK " + self.RESET + message)
        }
    }

    public func writeToStderr(_ message: String) {
        if self.isCli == true {
            let messageAsString = message + "\r\n"
            if let messageAsData: Data = messageAsString.data(using: .utf8) {
                self.STD_ERR.write(messageAsData)
            }
        }
    }

    public func reportErrorAndExit(_ message: String, _ code: Int32 = EXIT_FAILURE) {
        if self.isCli == true {
            writeToStderr(self.RED + self.BOLD + "ERROR " + self.RESET + message + " -- exiting")
            exit(code)
        }
    }
}


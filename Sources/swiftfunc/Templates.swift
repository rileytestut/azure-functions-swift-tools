//
//  Templates.swift
//  SwiftFunc
//
//  Created by Saleh on 11/14/19.
//

import Foundation

struct Templates {
    
    struct Functions {
        
        static func template(forType: String) -> String {
            switch forType {
            case "http":
                return http
            case "blob":
                return blob
            case "timer":
                return timer
            default:
                return ""
            }
        }
        
        static let http = """
        //
        //  {{ name }}.swift
        //  {{ project }}
        //
        //  Created on {{ date }}.
        //

        import Foundation
        import AzureFunctions

        class {{ name }}: Function {
            
            required init() {
                super.init()
                self.name = "{{ name }}"
                self.trigger = HttpRequest(name: "req", methods: ["GET", "POST"])
            }
            
            override func exec(request: HttpRequest, context: inout Context, callback: @escaping callback) throws {
                
                context.log("Function executing!")
                
                let res = HttpResponse()
                res.statusCode = 200
                res.body  = "Hello!"
                res.headers = ["Content-Type": "plain/text"]
                
                return callback(res);
            }
        }
        """
        
        static let blob = """
            //
            //  {{ name }}.swift
            //  {{ project }}
            //
            //  Created on {{ date }}.
            //

            import Foundation
            import AzureFunctions

            class {{ name }}: Function {
                
                required init() {
                    super.init()
                    self.name = "{{ name }}"
                    self.trigger = Blob(name: "myBlob", path: "samples-workitems/{fileName}", connection: "<YourStorageAccountConnectionString>")
                }
                
                override func exec(blob: Blob, context: inout Context, callback: @escaping callback) throws {
                       context.log("Got bloby blob!")
                       callback(true)
                   }
                
            }
        """
        
        static let timer = """
            //
            //  {{ name }}.swift
            //  {{ project }}
            //
            //  Created on {{ date }}.
            //

            import Foundation
            import AzureFunctions

            class {{ name }}: Function {
                
                required init() {
                    super.init()
                    self.name = "{{ name }}"
                    self.trigger = Timer.initTrigger(name: "myTimer", schedule: "*/5 * * * * *")
                }
                
                override func exec(timer: Timer, context: inout Context, callback: @escaping callback) throws {
                    context.log("It is time!")
                    callback(true)
                }
                
            }

        """
        
    }
    
    struct ProjectFiles {
        
        static let functionJson = """
            {{ bindings }}
        """
        
        static let hostJson = """
            {
                "version": "2.0",
                "extensionBundle": {
                    "id": "Microsoft.Azure.Functions.ExtensionBundle",
                    "version": "[1.*, 2.0.0)"
                }
            }
        """
        
        static let workerConfigJson = """
            {
                "description": {
                    "arguments": [
                        "run"
                    ],
                    "defaultExecutablePath": "{{ execPath }}",
                    "extensions": [
                        ".swift"
                    ],
                    "language": "swift"
                }
            }
        """
        
        static let localSettingsJson = """
        {
            "IsEncrypted": false,
            "Values": {
                "FUNCTIONS_WORKER_RUNTIME": "swift",
                "languageWorkers:workersDirectory": "workers"
            }
        }
        """
        
        static let mainSwift = """
        //
        //  main.swift
        //  {{ name }}
        //
        //  Auto Generated by SwiftFunctionsSDK
        //
        //  Do Not modify/change code outside the marked area.
        //  Only register/remove Functions. Do Not add other code
        //

        import AzureFunctions

        let registry = FunctionRegistry()

        // ****** register/remove your functions ******
        //registry.AzureWebJobsStorage = "your debug AzureWebJobsStorage" //Remove before deploying. Do not commit or push any Storage Account keys

        //registry.register(name: "name", function: MyFunction.self)

        // ******

        AzureFunctionsWorker.shared.main(registry: registry)

        """
        
        static let mainSwiftWithFunctions =
            """
        //
        //  main.swift
        //  {{ name }}
        //
        //  Auto Generated by SwiftFunctionsSDK
        //
        //  Do Not modify/change code outside the marked area.
        //  Only register/remove Functions. Do Not add other code
        //

        import SwiftFunc

        let registry = FunctionRegistry()

        //registry.AzureWebJobsStorage = "your debug AzureWebJobsStorage" //Remove before deploying. Do not commit or push any Storage Account keys

        {{ functions }}

        AzureFunctionsWorker.shared.main(registry: registry)
        """
        
        static let packageSwift = """
            // swift-tools-version:5.0
            // The swift-tools-version declares the minimum version of Swift required to build this package.

            import PackageDescription

            let package = Package(
                name: "{{ name }}",
                products: [
                    .executable(name: "functions", targets: ["{{ name }}"]),
                 ],
                dependencies: [
                    // Dependencies declare other packages that this package depends on.
                    // .package(url: /* package url */, from: "1.0.0"),
                     .package(url: "https://github.com/SalehAlbuga/azure-functions-swift", from: "0.0.1"),
                ],
                targets: [
                    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
                    // Targets can depend on other targets in this package, and on products in packages which this package depends on.
                    .target(
                        name: "{{ name }}",
                        dependencies: [])
                ]
            )
            """
        
        static let gitignore = """
        .DS_Store
        /.build
        /Packages
        /*.xcodeproj
        xcuserdata/
        """
        
        static let dockerfile = """
        FROM swift:5.0.0 AS build-image

        WORKDIR /src
        COPY . .
        RUN swift build -c release
        WORKDIR /home/site/wwwroot
        RUN [ "/src/.build/release/functions", "export", "--source", "/src", "--root", "/home/site/wwwroot" ]

        FROM mcr.microsoft.com/azure-functions/base:2.0 as functions-image

        FROM salehalbuga/azure-functions-swift-runtime:0.0.10

        COPY --from=functions-image [ "/azure-functions-host", "/azure-functions-host" ]

        COPY --from=build-image ["/home/site/wwwroot", "/home/site/wwwroot/"]

        CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]

        """
        
        static let dockerignore = """
        .build
        .vscode
        .git
        """
        
    }
}
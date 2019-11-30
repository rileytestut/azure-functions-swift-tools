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
            case "queue":
                return queue
            case "timer":
                return timer
            case "servicebus":
                return servicebus
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
                var name: String?
                
                if let data = request.body, let bodyObj: [String: Any] = try? JSONSerialization.jsonObject(with: data, options: .init(rawValue: 0)) as? [String: Any] {
                    name = bodyObj["name"] as? String
                } else {
                    name = request.query["name"] 
                }
                res.body  = "Hello \\(name ?? "buddy")!".data(using: .utf8)
                
                return callback(res);
            }
        }
        """

        static let queue = """
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
                self.trigger = Queue(name: "myQueueTrigger", queueName: "queueName", connection: "AzureWebJobsStorage")
            }

            override func exec(string: String, context: inout Context, callback: @escaping callback) throws {
                context.log("Got queue item: \\(string)")
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
                self.trigger = TimerTrigger(name: "myTimer", schedule: "*/5 * * * * *")
            }
            
            override func exec(timer: TimerTrigger, context: inout Context, callback: @escaping callback) throws {
                context.log("It is time!")
                callback(true)
            }
            
        }
        """

        static let servicebus = """
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
                self.trigger = ServiceBusMessage(name: "sbTrigger", topicName: "mytopic", subscriptionName: "mysubscription", connection: "ServiceBusConnection")
            }

        override func exec(sbMessage: ServiceBusMessage, context: inout Context, callback: @escaping callback) throws {
            if let msg: String = sbMessage.message as? String {
                context.log("Got topic message: \\(msg)")
            } 

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
        
        static let mainSwiftEmpty = """
        //
        //  main.swift
        //  {{ name }}
        //
        //  Auto Generated by SwiftFunctionsSDK
        //
        //  Only set env vars or register/remove Functions. Do Not modify/add other code
        //

        import AzureFunctions

        let registry = FunctionRegistry()

        // ****** optional: set debug AzureWebJobsStorage or other vars ******
        //registry.AzureWebJobsStorage = "yourDebugConnection" //Remove before deploying. Do not commit or push any Storage Account keys
        //registry.EnvironmentVariables = ["fooConnection": "bar"]

        // ******

        AzureFunctionsWorker.shared.main(registry: registry)

        """
        
        static let mainSwiftWithFunctions = """
        //
        //  main.swift
        //  {{ name }}
        //
        //  Auto Generated by SwiftFunctionsSDK
        //
        //  Only set env vars or register/remove Functions. Do Not modify/add other code
        //

        import AzureFunctions

        let registry = FunctionRegistry()

        // ****** optional: set debug AzureWebJobsStorage or other vars ******
        //registry.AzureWebJobsStorage = "yourDebugConnection" //Remove before deploying. Do not commit or push any Storage Account keys
        //registry.EnvironmentVariables = ["fooConnection": "bar"]

        // ******

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
                        dependencies: ["AzureFunctions"])
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
        FROM swift:5.0 AS build-image

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

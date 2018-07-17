//
//  main.swift
//  ServeML
//
//  Created by Parker Erway on 7/15/18.
//  Copyright © 2018 Parker Erway. All rights reserved.
//

import Foundation
import NaturalLanguage
import CoreML

do {
    let path = Bundle.main.path(forResource: "RecQuestionClassifier", ofType: "mlmodel")!
    let url = URL(string: path)!
    let classifier = try! NLModel(contentsOf: MLModel.compileModel(at: url));
    
    let server = HttpServer()
    server["/"] = { request in
        let bodyParams = request.queryParams.filter({ (arg0) -> Bool in
            let (key, _) = arg0
            return key == "body";
        });
        
        if bodyParams.count == 1
        {
            let body = bodyParams[0]
            
            print(body)
            
            if let prediction: String = classifier.predictedLabel(for: body.1) {
                print(prediction)
                return .ok(.json([ "prediction": prediction ] as AnyObject))
            }
            else {
                print("Not-rec")
                return .ok(.json([ "prediction": "" ] as AnyObject))
            }
        }
        
        return .badRequest(nil)
    }
    
    try server.start(6543)
    
    print("Server has started ( port = \(try server.port()) ). Try to connect now...")
    
    RunLoop.main.run()
    
} catch {
    print("Server start error: \(error)")
}

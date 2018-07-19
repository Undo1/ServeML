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
    let reqClassifierPath = Bundle.main.path(forResource: "RecQuestionClassifier", ofType: "mlmodel")!
    let reqClassifierUrl = URL(string: reqClassifierPath)!
    let reqQuestionClassifier = try! NLModel(contentsOf: MLModel.compileModel(at: reqClassifierUrl));

    let commentClassifierPath = Bundle.main.path(forResource: "SmellDetectorComments", ofType: "mlmodel")!
    let commentClassifierUrl = URL(string: commentClassifierPath)!
    let commentClassifier = try! NLModel(contentsOf: MLModel.compileModel(at: commentClassifierUrl))

    let server = HttpServer()

    server["/comments"] = { request in
        let bodyParams = request.queryParams.filter({ (arg0) -> Bool in
            let (key, _) = arg0
            return key == "body"
        })

        if bodyParams.count == 1
        {
            let body = bodyParams[0]

            print("comment")
            print(body)

            if let prediction: String = commentClassifier.predictedLabel(for: body.1) {
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

    server["/"] = { request in
        let bodyParams = request.queryParams.filter({ (arg0) -> Bool in
            let (key, _) = arg0
            return key == "body"
        })
        
        if bodyParams.count == 1
        {
            let body = bodyParams[0]
            
            print("post")
            print(body)
            
            if let prediction: String = reqQuestionClassifier.predictedLabel(for: body.1) {
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

//
//  LogFileReader.swift
//  Staff Mobility
//
//  Created by mspiveylocal on 2/13/17.
//  Copyright © Awarepoint 2017. All rights reserved.
//

import Foundation

class LogFileReader
{
    
    public func getFiles() -> [String : String] {
        let path = NSHomeDirectory().appending("/Library/Caches/Logs")
        var files: [String] = [String]()
        var filepaths: [String: String] = [String: String]()
        do {
            files = try FileManager.default.contentsOfDirectory(atPath: path)
        }
        catch {
            
        }
        
        if files.count > 0 {
            for fileName in files {
                filepaths.updateValue(path + "/" + fileName, forKey: fileName)
            }
        }
        
        return filepaths
    }
    
  
    
}

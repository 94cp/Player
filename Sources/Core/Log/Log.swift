//
//  Log.swift
//  Player
//
//  Created by chenp on 2018/9/18.
//  Copyright © 2018 chenp. All rights reserved.
//

import Foundation

public enum LogLevel: Int, CustomStringConvertible {
    case none, debug, info, warn, error
    
    public var description: String {
        switch self {
        case .none:
            return "⭕️⭕️"
        case .debug:
            return "🔹🔹"
        case .info:
            return "ℹ️ℹ️"
        case .warn:
            return "⚠️⚠️"
        case .error:
            return "‼️‼️"
        }
    }
}

/// 自定义log
public struct Log {
    
    public static var logLevel: LogLevel = .debug
    
    public static var cachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("cp.swift.Player.log")
    
    private static let dateFormatter: DateFormatter = {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-dd-MM HH:mm:ss.SSS"
        return dateFormatter
    }()
    
    public static func log(_ msg: Any..., level: LogLevel = .debug, file: String = #file, funcName: String = #function, lineNum: Int = #line) {
        guard logLevel != .none else { return }
        
        guard logLevel.rawValue <= level.rawValue else { return }
        
        let dateTime = dateFormatter.string(from: Date())
        
        var date = dateTime
        var time = dateTime
        
        let splitTime = dateTime.split(separator: " ")
        if splitTime.count == 2 {
            date = String(splitTime[0])
            time = String(splitTime[1])
        }
        
        let text = "\(time) \(level.description) \(file.components(separatedBy: "/").last ?? file) [\(funcName):\(lineNum)] | \(msg.map({ String(describing: $0) }).joined(separator: "，"))"
        print(text)
        
        //将内容同步写到文件中去（Caches文件夹下）
        appendText(file: "\(date)-log.txt", string: "\(date) \(text)")
    }
    
    public static func debug(_ msg: Any..., file: String = #file, funcName: String = #function, lineNum: Int = #line) {
        log(msg, level: .debug, file: file, funcName: funcName, lineNum: lineNum)
    }
    
    public static func info(_ msg: Any..., file: String = #file, funcName: String = #function, lineNum: Int = #line) {
        log(msg, level: .info, file: file, funcName: funcName, lineNum: lineNum)
    }
    
    public static func warn(_ msg: Any..., file: String = #file, funcName: String = #function, lineNum: Int = #line) {
        log(msg, level: .warn, file: file, funcName: funcName, lineNum: lineNum)
    }
    
    public static func error(_ msg: Any..., file: String = #file, funcName: String = #function, lineNum: Int = #line) {
        log(msg, level: .error, file: file, funcName: funcName, lineNum: lineNum)
    }
    
    // 在文件末尾追加新内容
    private static func appendText(file: String, string: String) {
        do {
            let fileURL = cachePath.appendingPathComponent(file)
            
            let fm = FileManager.default
            // 检查文件夹是否创建
            if !fm.fileExists(atPath: cachePath.path) {
                try fm.createDirectory(at: cachePath, withIntermediateDirectories: true)
            }
            
            // 检查文件是否创建
            if !fm.fileExists(atPath: fileURL.path) {
                fm.createFile(atPath: fileURL.path, contents: nil)
            }
            
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            let stringToWrite = "\n" + string
            
            // 找到末尾位置并添加
            fileHandle.seekToEndOfFile()
            fileHandle.write(stringToWrite.data(using: String.Encoding.utf8)!)
            
        } catch let error as NSError {
            print("failed to append: \(error)")
        }
    }
}

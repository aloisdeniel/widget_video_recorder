//
//  VideoData.swift
//  Spitfire
//
//  Created by seanmcneil on 8/17/19.
//  Modified by Aloïs Deniel on 23/03/21.
//
import Foundation
import AVFoundation
import VideoToolbox;

struct VideoData {
    let fps: Int32
    let size: CGSize
    let url: URL
    
    var videoSettings: [String : Any] {
        return
            [AVVideoCodecKey  : AVVideoCodecType.hevcWithAlpha,
             AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: 960000,
                AVVideoQualityKey: 1.0,
                AVVideoMaxKeyFrameIntervalKey: 1,
                AVVideoProfileLevelKey: kVTProfileLevel_HEVC_Main_AutoLevel,
                kVTCompressionPropertyKey_AlphaChannelMode: kVTAlphaChannelMode_StraightAlpha,
             ],
             
             AVVideoWidthKey : size.width,
             AVVideoHeightKey : size.height]
    }
    
    var sourceBufferAttributes: [String : Any] {
        return
            [(kCVPixelBufferPixelFormatTypeKey as String): Int(kCVPixelFormatType_32ARGB),
             (kCVPixelBufferWidthKey as String): Float(size.width),
             (kCVPixelBufferHeightKey as String): Float(size.height)]
    }
}

//
//  Writer.swift
//  Spitfire
//
//  Created by seanmcneil on 8/17/19.
//  Modified by Aloïs Deniel on 23/03/21.
import AVFoundation
import VideoToolbox
import Accelerate
import UIKit

final class Writer {
    private let videoWriter: AVAssetWriter
    private let pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor
    private let videoWriterInput: AVAssetWriterInput
    
    private let writeQueue = DispatchQueue(label: "writequeue", qos: .background)
    
    /// Initializes writer object with objects for handling video writing work
    ///
    /// - Parameters:
    ///   - videoWriter: Service for writing to new file
    ///   - pixelBufferAdaptor: Provides interface for appending samples to AVAssetWriterInput
    ///   - videoWriterInput: Provides interface for appending samples to AVAssetWriter
    init(videoWriter: AVAssetWriter,
         pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor,
         videoWriterInput: AVAssetWriterInput) {
        self.videoWriter = videoWriter
        self.pixelBufferAdaptor = pixelBufferAdaptor
        self.videoWriterInput = videoWriterInput
    }
    
    /// Starts process of writing frames to file
    ///
    /// - Parameters:
    ///   - images: [UIImage] for creating video
    ///   - videoData: Contains information for configuring video
    ///   - delegate: Delegate to handle status updates
    func write(images: [String],
               videoData: VideoData,
               delegate: SpitfireDelegate?) {
        videoWriter.startSession(atSourceTime: .zero)
        assert(pixelBufferAdaptor.pixelBufferPool != nil)
        
        videoWriterInput.requestMediaDataWhenReady(on: writeQueue,
                                                   using: { [weak self] in
                                                    self?.writeFrames(images: images,
                                                                      videoData: videoData,
                                                                      delegate: delegate)
        })
    }
    
    /// Handles writing of frames to video file
    ///
    /// - Parameters:
    ///   - images: [UIImage] for creating video
    ///   - videoData: Contains information for configuring video
    ///   - delegate: Delegate to handle status updates
    private func writeFrames(images: [String],
                             videoData: VideoData,
                             delegate: SpitfireDelegate?) {
        let currentProgress = Progress(totalUnitCount: Int64(images.count))
        var frameCount: Int64 = 0
        
        while(Int(frameCount) < images.count) {
            // Will continue to loop until the video writer is able to write, which effectively handles buffer backups
            if videoWriterInput.isReadyForMoreMediaData {
                assert(!Thread.isMainThread)
                let presentationTime = CMTimeMake(value: frameCount, timescale: videoData.fps)
                let imagePath = images[Int(frameCount)]
                let imageURL = URL(fileURLWithPath: imagePath);
                do {
                    let imageData = try Data(contentsOf: imageURL);
                    let nsImage = UIImage(data: imageData);
                    var image = nsImage!.cgImage!;
                    guard image.width == Int(videoData.size.width) && image.height == Int(videoData.size.height) else {
                        delegate?.videoFailed(error: .imageDimensionsMatchFailure)
                        
                        return
                    }
                    
                    if append(pixelBufferAdaptor: pixelBufferAdaptor,
                              with: &image,
                              at: presentationTime,
                              delegate: delegate) {
                        frameCount += 1
                        currentProgress.completedUnitCount = frameCount
                        delegate?.videoProgress(progress: currentProgress)
                    }
                    else {
                        return;
                    }
                } catch {
                    print("Error loading image : \(error)")
                    delegate?.videoFailed(error: .imageDimensionsMatchFailure)
                    return
                }
            }
        }
        
        videoWriterInput.markAsFinished()
        videoWriter.finishWriting {
            delegate?.videoCompleted(url: videoData.url)
        }
    }
    
    /// Set up pixel buffer to add a frame at specified time
    ///
    /// - Parameters:
    ///   - adaptor: Provides interface for appending samples to AVAssetWriterInput
    ///   - image: UIImage to write, passed in by reference
    ///   - presentationTime: Time value for marking position in video
    ///   - delegate: Delegate to handle status updates
    /// - Returns: Bool that indicates if operation was successful
    private func append(pixelBufferAdaptor adaptor: AVAssetWriterInputPixelBufferAdaptor,
                        with image: inout CGImage,
                        at presentationTime: CMTime,
                        delegate: SpitfireDelegate?)  -> Bool {
        if let pixelBufferPool = adaptor.pixelBufferPool {
            let pixelBufferPointer = UnsafeMutablePointer<CVPixelBuffer?>.allocate(capacity: 1)
            let status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, pixelBufferPointer)
            guard var pixelBuffer = pixelBufferPointer.pointee else {
                delegate?.videoFailed(error: .pixelBufferPointeeFailure)
                
                return false
            }
            
            guard status == 0 else {
                delegate?.videoFailed(error: .invalidStatusCode(Int(status)))
                
                return false
            }
            
            do {
                try fill(pixelBuffer: &pixelBuffer, with: &image)
                if adaptor.append(pixelBuffer, withPresentationTime: presentationTime) {
                    pixelBufferPointer.deinitialize(count: 1)
                    pixelBufferPointer.deallocate()
                    return true
                } else {
                    if(videoWriter.status == AVAssetWriter.Status.failed) {
                        print("Error append image : \(videoWriter.error!)")
                    }
                    if(videoWriter.status == AVAssetWriter.Status.cancelled) {
                        print("Cancelled")
                    }
                    delegate?.videoFailed(error: .pixelBufferApendFailure)
                    return false
                }
            } catch {
                delegate?.videoFailed(error: .pixelBufferApendFailure)
            }
            
            
            
        }
        
        return false
    }
    
    /// Populates the pixel buffer with the contents of the current image
    ///
    /// - Parameters:
    ///   - buffer: Memory storage for pixel buffer, passed in by reference
    ///   - image: UIImage to write, passed in by reference
    private func fill(pixelBuffer buffer: inout CVPixelBuffer,
                      with image: inout CGImage) throws {
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        
        var sourceFormat = vImage_CGImageFormat(cgImage: image)
        var sourceBuffer = try vImage_Buffer(cgImage: image)
    
        let vformat = vImageCVImageFormat_Create(kCVPixelFormatType_32ARGB,
                                                                    nil,
                                                                    kCVImageBufferChromaLocation_Center,
                                                                    image.colorSpace,
                                                                    0);
        
        vImageBuffer_CopyToCVPixelBuffer(&sourceBuffer, &sourceFormat!, buffer, vformat?.takeRetainedValue(),  nil, vImage_Flags(kvImageNoFlags));
        
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        
        sourceBuffer.free();
    }
}

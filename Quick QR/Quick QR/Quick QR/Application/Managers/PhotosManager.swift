//
//  PhotosManager.swift
//  Quick QR
//
//  Created by Umair Afzal on 05/09/2025.
//

import Foundation
import UIKit
import Photos

final class PhotosManager {

    static let shared = PhotosManager()
    private init() {}

    enum PhotosError: Error {
        case authorizationDenied
        case authorizationRestricted
        case notDetermined
        case creationFailed
        case albumCreationFailed
        case unknown(Error)
    }

    // MARK: - Public methods

    func save(image: UIImage, completion: @escaping (Result<PHObjectPlaceholder, Error>) -> Void) {
        requestAddAuthorization { [weak self] authStatus in
            guard let self = self else { return }

            switch authStatus {
            case .authorized, .limited:
                self.performSave(image: image, completion: completion)
            case .denied:
                self.log("Authorization denied while trying to save image")
                DispatchQueue.main.async { completion(.failure(PhotosError.authorizationDenied)) }
            case .restricted:
                self.log("Authorization restricted while trying to save image")
                DispatchQueue.main.async { completion(.failure(PhotosError.authorizationRestricted)) }
            @unknown default:
                self.log("Unknown authorization status: \(authStatus.rawValue)")
                DispatchQueue.main.async { completion(.failure(PhotosError.authorizationDenied)) }
            }
        }
    }

    func save(image: UIImage, toAlbumNamed albumName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        requestAddAuthorization { [weak self] authStatus in
            guard let self = self else { return }

            switch authStatus {
            case .authorized, .limited:
                self.save(image: image, intoAlbumNamed: albumName, completion: completion)
            case .denied:
                self.log("Authorization denied while saving to album: \(albumName)")
                DispatchQueue.main.async { completion(.failure(PhotosError.authorizationDenied)) }
            case .restricted:
                self.log("Authorization restricted while saving to album: \(albumName)")
                DispatchQueue.main.async { completion(.failure(PhotosError.authorizationRestricted)) }
            case .notDetermined:
                self.log("Authorization notDetermined while saving to album: \(albumName)")
                DispatchQueue.main.async { completion(.failure(PhotosError.notDetermined)) }
            @unknown default:
                self.log("Unknown authorization status: \(authStatus.rawValue)")
                DispatchQueue.main.async { completion(.failure(PhotosError.authorizationDenied)) }
            }
        }
    }

    // MARK: - Private helpers

    private func requestAddAuthorization(_ completion: @escaping (PHAuthorizationStatus) -> Void) {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                self.log("Authorization request result: \(status.rawValue)")
                completion(status)
            }
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                self.log("Authorization request result (legacy): \(status.rawValue)")
                completion(status)
            }
        }
    }

    private func performSave(image: UIImage, completion: @escaping (Result<PHObjectPlaceholder, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.9) else {
            self.log("Image conversion to JPEG failed")
            DispatchQueue.main.async { completion(.failure(PhotosError.creationFailed)) }
            return
        }

        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetCreationRequest.forAsset()
            let options = PHAssetResourceCreationOptions()
            creationRequest.addResource(with: .photo, data: imageData, options: options)
        }, completionHandler: { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.log("Failed to save image: \(error.localizedDescription)")
                    completion(.failure(PhotosError.unknown(error)))
                } else if success {
                    self.log("Image successfully saved to Photos")
                    completion(.success(PHObjectPlaceholder()))
                } else {
                    self.log("Save operation completed with unknown failure")
                    completion(.failure(PhotosError.creationFailed))
                }
            }
        })
    }

    private func save(image: UIImage, intoAlbumNamed albumName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        getOrCreateAlbum(named: albumName) { result in
            switch result {
            case .success(let collection):
                guard let imageData = image.jpegData(compressionQuality: 0.9) else {
                    self.log("Image conversion failed for album: \(albumName)")
                    DispatchQueue.main.async { completion(.failure(PhotosError.creationFailed)) }
                    return
                }

                PHPhotoLibrary.shared().performChanges({
                    let assetRequest = PHAssetCreationRequest.forAsset()
                    let options = PHAssetResourceCreationOptions()
                    assetRequest.addResource(with: .photo, data: imageData, options: options)
                    if let placeholder = assetRequest.placeholderForCreatedAsset,
                       let albumChangeRequest = PHAssetCollectionChangeRequest(for: collection) {
                        albumChangeRequest.addAssets([placeholder] as NSArray)
                    }
                }, completionHandler: { success, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.log("Failed to save image to album '\(albumName)': \(error.localizedDescription)")
                            completion(.failure(PhotosError.unknown(error)))
                        } else if success {
                            self.log("Image successfully saved to album '\(albumName)'")
                            completion(.success(()))
                        } else {
                            self.log("Unknown failure saving to album '\(albumName)'")
                            completion(.failure(PhotosError.creationFailed))
                        }
                    }
                })

            case .failure(let error):
                self.log("Failed to get or create album '\(albumName)': \(error.localizedDescription)")
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    private func getOrCreateAlbum(named title: String, completion: @escaping (Result<PHAssetCollection, Error>) -> Void) {
        if let existing = fetchAlbum(named: title) {
            log("Album '\(title)' found")
            completion(.success(existing))
            return
        }

        var placeholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title)
            placeholder = createAlbumRequest.placeholderForCreatedAssetCollection
        }, completionHandler: { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.log("Failed to create album '\(title)': \(error.localizedDescription)")
                    completion(.failure(PhotosError.unknown(error)))
                    return
                }
                guard success, let placeholder = placeholder else {
                    self.log("Album creation failed with no error for '\(title)'")
                    completion(.failure(PhotosError.albumCreationFailed))
                    return
                }
                let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                guard let collection = fetchResult.firstObject else {
                    self.log("Created album not found in fetch for '\(title)'")
                    completion(.failure(PhotosError.albumCreationFailed))
                    return
                }
                self.log("Album '\(title)' created successfully")
                completion(.success(collection))
            }
        })
    }

    private func fetchAlbum(named title: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "localizedTitle = %@", title)
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: fetchOptions)
        return collections.firstObject
    }

    // MARK: - Logging helper
    private func log(_ message: String) {
        print("[PhotosManager] \(message)")
    }
}

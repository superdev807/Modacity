//
//  UIImageViewExtensions.swift
//  Swiftpass
//
//  Created by Benjamin Chris on 5/24/19.
//  Copyright © 2019 Swiftpass Inc. All rights reserved.
//

import UIKit

final class ImageCache {
    
    static let shared = ImageCache()
    
    let sharedKeyPrefix = "image-cache-"
    
    func data(for url: String) -> Data? {
        return UserDefaults.standard.data(forKey: sharedKeyPrefix + url)
    }
    
    func save(for url: String, data: Data) {
        UserDefaults.standard.set(data, forKey: sharedKeyPrefix + url)
    }
    
}

extension UIImageView {
    
    func forceShowSpinner() {
        self.startIndicatorAnimating()
    }
    
    func stopSpinner() {
        self.stopIndicatorAnimating()
    }
    
    func showImage(url: String?, placeholder: UIImage? = nil, fromCache: Bool = true, contentModeAfterDownload: ContentMode = .scaleAspectFill, placeholderContentMode: ContentMode = .center) {
        
        guard let urlString = url else {
            self.image = placeholder
            self.contentMode = placeholderContentMode
            return
        }
        
        guard let URL = URL(string: urlString) else {
            self.image = placeholder
            self.contentMode = placeholderContentMode
            return
        }
        
        if fromCache {
            if let cachedData = ImageCache.shared.data(for: urlString) {
                self.image = UIImage(data: cachedData)
                self.contentMode = contentModeAfterDownload
                return
            }
        }
        
        self.image = nil
        self.startIndicatorAnimating()
        
        let urlRequest = URLRequest(url: URL)
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, _, _) in
            if let data = data, let image = UIImage(data: data) {
                ImageCache.shared.save(for: urlString, data: data)
                DispatchQueue.main.async {
                    self.stopIndicatorAnimating()
                    self.image = image
                    self.contentMode = contentModeAfterDownload
                }
            } else {
                DispatchQueue.main.async {
                    self.stopIndicatorAnimating()
                    self.image = placeholder
                    self.contentMode = placeholderContentMode
                }
            }
        }
        task.resume()
        
    }
    
    private func startIndicatorAnimating() {
        
        if let indicator = self.viewWithTag(0x10000) as? UIActivityIndicatorView {
            self.bringSubview(toFront: indicator)
            indicator.startAnimating()
            return
        }
        
        let indicatorSize: CGFloat = 30
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.tag = 0x10000
        self.addSubview(activityIndicator)
        self.bringSubview(toFront: activityIndicator)
        
        activityIndicator.heightAnchor.constraint(equalToConstant: indicatorSize).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: indicatorSize).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activityIndicator.startAnimating()
    
    }
    
    private func stopIndicatorAnimating() {
        if let indicator = self.viewWithTag(0x10000) as? UIActivityIndicatorView {
            indicator.stopAnimating()
            indicator.removeFromSuperview()
        }
    }
    
}

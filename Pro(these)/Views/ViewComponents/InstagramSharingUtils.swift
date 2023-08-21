//
//  InstagramSharingUtils.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 16.08.23.
//
import Foundation
import SwiftUI

struct InstagramShareView: View {

    var imageToShare: UIImage

    var body: some View {
        VStack {
            if InstagramSharingUtils.canOpenInstagramStories {
                Button(action: {
                    InstagramSharingUtils.shareToInstagramStories(imageToShare)
                }) {
                    Image("instagram")
                        .scaleEffect(1.2)
                    
                    Text("Instagram")
                }
            }
        }
    }
}


struct InstagramSharingUtils {

  // Returns a URL if Instagram Stories can be opened, otherwise returns nil.
  private static var instagramStoriesUrl: URL? {
      if let url = URL(string: "instagram-stories://share?source_application=" + Bundle.main.bundleIdentifier!) {
      if UIApplication.shared.canOpenURL(url) {
        return url
      }
    }
    return nil
  }

  // Convenience wrapper to return a boolean for `instagramStoriesUrl`
  static var canOpenInstagramStories: Bool {
    return instagramStoriesUrl != nil
  }

  // If Instagram Stories is available, writes the image to the pasteboard and
  // then opens Instagram.
  static func shareToInstagramStories(_ image: UIImage) {

    // Check that Instagram Stories is available.
    guard let instagramStoriesUrl = instagramStoriesUrl else {
      return
    }

    // Convert the image to data that can be written to the pasteboard.
    let imageDataOrNil = UIImage.pngData(image)
    guard let imageData = imageDataOrNil() else {
      print("🙈 Image data not available.")
      return
    }
    let pasteboardItem = ["com.instagram.sharedSticker.backgroundImage": imageData]
    let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)]

    // Add the image to the pasteboard. Instagram will read the image from the pasteboard when it's opened.
    UIPasteboard.general.setItems([pasteboardItem], options: pasteboardOptions)

    // Open Instagram.
    UIApplication.shared.open(instagramStoriesUrl, options: [:], completionHandler: nil)
  }
}

//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by David Crow on 6/8/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    @State var chosenPalette: String = ""
    
    init(document: EmojiArtDocument) {
        self.document = document
        _chosenPalette = State(wrappedValue: self.document.defaultPalette)
    }
    
    var body: some View {
        VStack {
            HStack {
                PaletteChooser(document: document, chosenPalette: $chosenPalette)
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(chosenPalette.map { String($0) }, id: \.self) { emoji in
                            Text(emoji)
                                .font(Font.system(size: self.defaultEmojiSize))
                                .onDrag { NSItemProvider(object: emoji as NSString) }
                        }
                    }
                }
                                
                Image(systemName: "trash.circle")
                    .foregroundColor(.red)
                    .font(Font.system(size: self.defaultEmojiSize))
                    .opacity(self.emojisAreSelected ? 1 : 0)
                    .gesture(
                        self.singleTapToDeleteSelectedEmojis()
                            .exclusively(before: self.singleTapToSelect(nil))
                    )
            }
            .padding(.trailing)
            
            GeometryReader { geometry in
                ZStack {
                    Color.white
                        .overlay(
                            OptionalImage(uiImage: self.document.backgroundImage)
                                .scaleEffect(self.zoomScale)
                                .offset(self.panOffset)
                        )
                        .gesture(
                            self.doubleTapToZoom(in: geometry.size)
                                .exclusively(before: self.singleTapToSelect(nil))
                        )
                    
                    if self.isLoading {
                        Image(systemName: "hourglass").imageScale(.large).spinning()
                    } else {
                        ForEach(self.document.emojis) { emoji in
                            Text(emoji.text)
                                .font(animatableWithSize: emoji.fontSize * self.zoomScale(for: emoji))
                                .position(self.position(for: emoji, in: geometry.size))
                                .shadow(color: self.isEmojiSelected(emoji) ? .blue : .clear, radius: self.emojiShadowSize * self.zoomScale(for: emoji))
                                .gesture(self.singleTapToSelect(emoji))
                                .gesture(self.longPressToDeleteEmoji(emoji))
                                .gesture(self.dragEmoji(for: emoji))
                        }
                    }
                }
                .clipped()
                .gesture(self.panGesture())
                .gesture(self.zoomGesture())
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onReceive(self.document.$backgroundImage) { image in
                    self.zoomToFit(image, in: geometry.size)
                }
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    // SwiftUI bug (as of 13.4)? the location is supposed to be in our coordinate system
                    // however, the y coordinate appears to be in the global coordinate system
                    var location = CGPoint(x: location.x, y: geometry.convert(location, from: .global).y)
                    location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                    location = CGPoint(x: location.x - self.panOffset.width, y: location.y - self.panOffset.height)
                    location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
                    return self.drop(providers: providers, at: location)
                }
                .navigationBarItems(leading: self.pickImage, trailing: Button(action: {
                    if let url = UIPasteboard.general.url, url != self.document.backgroundURL {
                        self.confirmBackgroundPaste = true
                    } else {
                        self.explainBackgroundPaste = true
                    }
                }, label: {
                    Image(systemName: "doc.on.clipboard")
                        .imageScale(.large)
                        .alert(isPresented: self.$explainBackgroundPaste) {
                            Alert(
                                title: Text("Paste Background"),
                                message: Text("Copy the URL of an image to the clipboard and touch this button to set the background of your document."),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                }))
            }
            .zIndex(-1)
        }
        .alert(isPresented: self.$confirmBackgroundPaste) {
            Alert(
                title: Text("Paste Background"),
                message: Text("Replace your background with \(UIPasteboard.general.url?.absoluteString ?? "nothing")?"),
                primaryButton: .default(Text("OK")) {
                    self.document.backgroundURL = UIPasteboard.general.url
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    @State private var showImagePicker = false
    @State private var imagePickerSourceType = UIImagePickerController.SourceType.photoLibrary
    
    private var pickImage: some View {
        HStack {
            Image(systemName: "photo").imageScale(.large).foregroundColor(.accentColor).onTapGesture {
                self.imagePickerSourceType = .photoLibrary
                self.showImagePicker = true
            }
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Image(systemName: "camera").imageScale(.large).foregroundColor(.accentColor).onTapGesture {
                    self.imagePickerSourceType = .camera
                    self.showImagePicker = true
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: self.imagePickerSourceType) { image in
                if image != nil {
                    DispatchQueue.main.async {
                        self.document.backgroundURL = image!.storeInFilesystem()
                    }
                }
                self.showImagePicker = false
            }
        }
    }
    
    @State private var explainBackgroundPaste = false
    @State private var confirmBackgroundPaste = false
    
    var isLoading: Bool {
        document.backgroundURL != nil && document.backgroundImage == nil
    }
    
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    private var zoomScale: CGFloat {
        document.steadyStateZoomScale * (emojisAreSelected ? 1 : gestureZoomScale)
    }
    
    private func zoomScale(for emoji: EmojiArt.Emoji) -> CGFloat {
        isEmojiSelected(emoji) ? document.steadyStateZoomScale * gestureZoomScale : zoomScale
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { finalGestureScale in
                if self.emojisAreSelected {
                    for emoji in self.selectedEmojis {
                        self.document.scaleEmoji(emoji, by: finalGestureScale)
                    }
                } else {
                    self.document.steadyStateZoomScale *= finalGestureScale
                }
            }
    }
    
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (document.steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transaction in
                gesturePanOffset = latestDragGestureValue.translation / self.zoomScale
            }
            .onEnded { finalDragGestureValue in
                self.document.steadyStatePanOffset = self.document.steadyStatePanOffset + (finalDragGestureValue.translation / self.zoomScale)
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    self.zoomToFit(self.document.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            self.document.steadyStatePanOffset = .zero
            self.document.steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        if gestureDraggedEmoji.singleEmoji == emoji || (gestureDraggedEmoji.singleEmoji == nil && isEmojiSelected(emoji)) {
            location = CGPoint(x: location.x + gestureDraggedEmoji.offset.width, y: location.y + gestureDraggedEmoji.offset.height)
        }
        return location
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            self.document.backgroundURL = url
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
            }
        }
        return found
    }
    
    @State private var selectedEmojis = Set<EmojiArt.Emoji>()
    
    private var emojisAreSelected: Bool {
        !selectedEmojis.isEmpty
    }
    
    private func isEmojiSelected(_ emoji: EmojiArt.Emoji) -> Bool {
        selectedEmojis.contains(matching: emoji)
    }
    
    func selectEmoji(_ emoji: EmojiArt.Emoji) {
        selectedEmojis.toggleMatching(emoji)
    }
    
    func deselectAllEmojis() {
        selectedEmojis.removeAll()
    }
    
    private func singleTapToSelect(_ emoji: EmojiArt.Emoji?) -> some Gesture {
        TapGesture(count: 1)
            .onEnded {
                if emoji != nil {
                    self.selectEmoji(emoji!)
                } else {
                    self.deselectAllEmojis()
                }
            }
    }
    
    private func deleteEmoji(_ emoji: EmojiArt.Emoji) {
        self.document.deleteEmoji(emoji)
        self.selectedEmojis.remove(emoji)
    }
    
    private func longPressToDeleteEmoji(_ emoji: EmojiArt.Emoji) -> some Gesture {
        LongPressGesture()
            .onEnded { _ in
                self.deleteEmoji(emoji)
            }
    }
        
    private func singleTapToDeleteSelectedEmojis() -> some Gesture {
        TapGesture(count: 1)
            .onEnded {
                for emoji in self.selectedEmojis {
                    self.deleteEmoji(emoji)
                }
            }
    }
    
    @GestureState private var gestureDraggedEmoji: (offset: CGSize, singleEmoji: EmojiArt.Emoji?) = (.zero, nil)

    private func dragEmoji(for emoji: EmojiArt.Emoji) -> some Gesture {
        DragGesture()
            .updating($gestureDraggedEmoji) { latestDragGestureValue, gestureDraggedEmoji, transaction in
                gestureDraggedEmoji = (latestDragGestureValue.translation, self.isEmojiSelected(emoji) ? nil : emoji)
            }
            .onEnded { finalDragGestureValue in
                let translation = finalDragGestureValue.translation / self.zoomScale
                if self.isEmojiSelected(emoji) {
                    for emoji in self.selectedEmojis {
                        self.document.moveEmoji(emoji, by: translation)
                    }
                } else {
                    self.document.moveEmoji(emoji, by: translation)
                }
            }
    }
    
    // MARK: - Drawing Constant(s)
    
    private let defaultEmojiSize: CGFloat = 40
    private let emojiShadowSize: CGFloat = 10
}

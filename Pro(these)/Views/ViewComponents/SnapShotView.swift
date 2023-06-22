//
//  SnapShotView.swift
//  Pro(these)
//
//  Created by Frederik Kohler on 30.05.23.
//

import SwiftUI


struct SnapShotView: View {
    @Environment(\.displayScale) var displayScale
    @State private var renderedImageV1 = Image("SnapShotV1")
    @State private var renderedImageV2 = Image("SnapShotV2")
    @State private var renderedImageV3 = Image("SnapShotV3")
    
    @Binding var sheet: Bool
    
    var steps: String
    var distance: String
    var date: Date
    
    @State var saved = false
    @State var visible1 = false
    @State var visible2 = false
    
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width - 40
            VStack {
                
                SheetHeader("Teile deinen Fortschritt", action: {
                    sheet.toggle()
                })
                
                Spacer()
                
                TabView {
                    PreViewShot(image: renderedImageV1, width: width, tag: "V1").padding(.horizontal)
                    
                    PreViewShot(image: renderedImageV2, width: width, tag: "V2").padding(.horizontal)
                    
                    PreViewShot(image: renderedImageV3, width: width, tag: "V3").padding(.horizontal)
                }
                .tabViewStyle(.page)
                
                Spacer()
            }
            .background(.ultraThinMaterial)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .onAppear {
                render(width: width, steps: steps, distance: distance, date: date)
                
                withAnimation(.easeOut(duration: 0.4)){
                    visible1 = true
                }
                withAnimation(.easeOut(duration: 0.4).delay(0.5)){
                    visible2 = true
                }
                
            }
        }
    }
    
    @ViewBuilder
    func PreViewShot(image: Image, width: CGFloat, tag: String) -> some View {
        ZStack{
            
            VStack {
                HStack {
                    Spacer()
                    
                    ShareLink(item: image, preview: SharePreview("Mein Fortschritt mit der Pro Prothese App. \nhttps://www.prothese.pro/store", image: image), label: {
                        Label("Teilen", systemImage: "square.and.arrow.up")
                            
                    })
                    .foregroundColor(.white)
                    .opacity(visible2 ? 1 : 0)
                }
                
                // background
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: width)
                    .cornerRadius(20)
                    .opacity(visible1 ? 1 : 0)
                    .opacity(saved ? 0 : 1)
                    .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/.opacity(0.5), radius: 10, x: 0, y: 10)
            }
            
            // button
            CaptureButton(screen: width, image: image)
                .offset(x: 10 , y: -20)
                .opacity(visible2 ? 1 : 0)
                .opacity(saved ? 0 : 1)
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.white)
                .opacity(saved ? 1 : 0)
                .modifier(Shake(animatableData: CGFloat(saved ? 1 : 0 )))
            
        }
        .tag(tag)
    }
    
    @ViewBuilder
    func CaptureButton(screen: CGFloat, image: Image) -> some View {
        ZStack {
            VStack(alignment: .leading){
                HStack(alignment:.top) {
                    Image(systemName: "camera.fill")
                        .foregroundColor(.black)
                        .font(.system(size: screen / 12, design: .default))
                        .background(
                            Circle()
                                .fill(.white.shadow(.inner(color: .black.opacity(0.25), radius: 5)).shadow(.drop(color: .black.opacity(0.25), radius: 5)))
                                .frame(width:screen / 6, height: screen / 6)
                        )
                        .onTapGesture {
                            let image = image.asImage()

                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

                            withAnimation(.easeInOut(duration: 0.3)){
                                saved.toggle()
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                                withAnimation(.easeOut.delay(0.5)) {
                                    sheet.toggle()
                                }
                            })
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                                withAnimation(.easeOut.delay(1)) {
                                    saved.toggle()
                                }
                            })
                        }
                    
                    Spacer()
                }
                Spacer()
            }
        }
        .frame(width: screen, height: screen)
    }
    
    
    // Reander View to an Image when the App Appear
    @MainActor func render(width: CGFloat, steps: String, distance: String, date: Date) {
        let rendererV1 = ImageRenderer(content: renderViewV1(width: width, steps: steps,distance: distance, date: date))
        rendererV1.scale = displayScale
        if let uiImageV1 = rendererV1.uiImage {
           renderedImageV1 = Image(uiImage: uiImageV1)
        }
        
        
        let rendererV2 = ImageRenderer(content: renderViewV2(width: width, steps: steps,distance: distance, date: date))
        rendererV2.scale = displayScale
        
        if let uiImageV2 = rendererV2.uiImage {
            renderedImageV2 = Image(uiImage: uiImageV2)
        }
        
        let rendererV3 = ImageRenderer(content: renderViewV3(width: width, steps: steps,distance: distance, date: date))
        rendererV3.scale = displayScale
        
        if let uiImageV3 = rendererV3.uiImage {
            renderedImageV3 = Image(uiImage: uiImageV3)
        }
   }
}


// Generate the Image for the Screenshot 
struct renderViewV1: View {
    var width: CGFloat
    var steps: String
    var distance: String
    var date: Date
    var body: some View {
        ZStack{
            
            // background
            Image("SnapShotV1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: width, height: width)
            
            VStack{
                HStack{
                    Text("\(steps) Schritte")
                    
                    Spacer()
                    
                    Text("\(distance)")
                }
                .foregroundColor(.white)
                .font(.title2.bold())
            }
            .padding(20)
            .frame(width: width, height: width, alignment: .top)
            
        }
        .frame(width: width, height: width)
    }
}

struct renderViewV2: View {
    var width: CGFloat
    var steps: String
    var distance: String
    var date: Date
    var body: some View {
        ZStack{
            
            // background
            Image("SnapShotV2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: width, height: width)
            
            VStack{
                HStack{
                    Text("\(steps) Schritte")
                    
                    Spacer()
                    
                    Text("\(distance)")
                }
                .foregroundColor(.white)
                .font(.title2.bold())
            }
            .padding(20)
            .frame(width: width, height: width, alignment: .top)
            
        }
        .frame(width: width, height: width)
    }
}

struct renderViewV3: View {
    var width: CGFloat
    var steps: String
    var distance: String
    var date: Date
    var body: some View {
        ZStack{
            
            // background
            Image("SnapShotV3")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: width, height: width)
            
            VStack{
                HStack{
                    Text("\(steps) Schritte")
                    
                    Spacer()
                    
                    Text("\(distance)")
                }
                .foregroundColor(.white)
                .font(.title2.bold())
            }
            .padding(20)
            .frame(width: width, height: width, alignment: .top)
            
        }
        .frame(width: width, height: width)
    }
}

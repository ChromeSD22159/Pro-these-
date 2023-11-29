//
//  SnapShotView.swift
//  Pro-these-
//
//  Created by Frederik Kohler on 27.09.23.
//

import SwiftUI
import PhotosUI
import Charts

struct SnapShotView: View {
    @EnvironmentObject var appConfig: AppConfig
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.displayScale) var displayScale
    
    init(isSheet: Binding<Bool>) {
        self._isSheet = isSheet
        
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(currentTheme.backgroundColor)
        UISegmentedControl.appearance().backgroundColor = UIColor(currentTheme.backgroundColor)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(currentTheme.hightlightColor)], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(currentTheme.text)], for: .normal)
    }
    
    private var enviromentAppState: Bool {
        AppConfig.shared.hasPro || AppConfig.shared.appState == .dev ? true : false
    }
    
    private var currentTheme: Theme {
        return ThemeManager().currentTheme()
    }
    
    private var viewport: CGRect {
        UIScreen.main.bounds
    }
    
    private var images: [String] {
        ["SnapShotV1", "SnapShotV2", "SnapShotV3", "SnapShotV4"]
    }
    
    @Binding var isSheet: Bool
    @State var isShopSheep: Bool = false
    
    @State var TL: SnapShot.SnapshotViews = .stepsToday
    @State var TR: SnapShot.SnapshotViews = .dateToday
    @State var BL: SnapShot.SnapshotViews = .logo
    @State var BR: SnapShot.SnapshotViews = .stepDistance
    
    @State var editView: SnapShot.SnapshotBackground = .background
    @State var contentEditView: SnapShot.SnapshotEdge = .topLeft
    
    @State var datePicker = Date()
    @State var dynamicSheet:CGSize = .zero
    
    @State var fontWeight: Font.Weight = .bold
    @State var textSizeSteps: Double = 30
    @State var textSizeDate: Double = 30
    
    @State var selectedBackgroundImage: String? = "SnapShotV1"
    @State var renderedImage: Image? = nil
    @State var renderedUIImage: UIImage? = nil
    @State var topGradient: Bool = false
    @State var topGradientOpacity = 0.2
    @State var bottomGradient: Bool = false
    @State var bottomGradientOpacity = 0.2
    @State var showLogo = true
    @State var showBgOverlay = true
    @State var stepCount:Double = 0
    @State var stepDistance:Double = 0
    @State var weekStepData: [ChartDataSnapShotWeekCompair] = []
    
    @State var widgetSize:CGSize = .zero
    @State var saved = false
    
    var body: some View {
        
        VStack(spacing: 10) {
            
            SheetHeader(title: "SnapShot", action: {
                isSheet.toggle()
            })
            .padding(.top, 40)
            
            Spacer()

            ZStack {
                HStack {
                    Spacer()

                    ZStack {
                        Widget(size: 500)
                            .cornerRadius(20)
                            .saveSize(in: $widgetSize)
                            .opacity(saved ? 0 : 1)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(currentTheme.text)
                            .opacity(saved ? 1 : 0)
                            .modifier(Shake(animatableData: CGFloat(saved ? 1 : 0 )))
                    }
                    
                    Spacer()
                }
                
                HStack {
                    Spacer()

                    
                    IconList()
                        .frame(height: widgetSize.height)
                        .opacity(saved ? 0 : 1)
                        .padding(.trailing)
                }
            }
            
            Spacer()
            
            VStack {
                Switcher()
                    .foregroundColor(currentTheme.textGray)
            }
            .padding(.bottom, 40)
            .padding()
            .background(currentTheme.text.ignoresSafeArea())
            .cornerRadius(25)
            
        }
        .frame(minWidth: viewport.width, minHeight: viewport.height)
        .onAppear {
            loadSteps()
           
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                render(view: Widget(size: 500))
            })
        }
    }
    
    @ViewBuilder func Widget(size: CGFloat) -> some View {
        ZStack {
            
            if let image = selectedBackgroundImage {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            
            if showBgOverlay {
                Image("SnapShotBGOverlay")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .blendMode(.plusLighter)
                    .opacity(0.5)
            }
            
            if topGradient {
                LinearGradient(colors: [.black.opacity(topGradientOpacity),.clear, .clear], startPoint: .top, endPoint: .bottom)
            }
            
            if bottomGradient {
                LinearGradient(colors: [.clear, .clear, .black.opacity(bottomGradientOpacity)], startPoint: .top, endPoint: .bottom)
            }

            VStack {
                
                HStack {
                    
                    SnapShotItem(view: TL, date: $datePicker, stepText: $textSizeSteps, stepDistance: $stepDistance, dateText: $textSizeDate, fontWeight: $fontWeight, weekStepData: $weekStepData, stepCount: $stepCount )
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    
                    SnapShotItem(view: TR, date: $datePicker, stepText: $textSizeSteps, stepDistance: $stepDistance, dateText: $textSizeDate, fontWeight: $fontWeight, weekStepData: $weekStepData, stepCount: $stepCount )
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    
                }
                
                HStack {
                    SnapShotItem(view: BL, date: $datePicker, stepText: $textSizeSteps, stepDistance: $stepDistance, dateText: $textSizeDate, fontWeight: $fontWeight, weekStepData: $weekStepData, stepCount: $stepCount )
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    
                    SnapShotItem(view: BR, date: $datePicker, stepText: $textSizeSteps, stepDistance: $stepDistance, dateText: $textSizeDate, fontWeight: $fontWeight, weekStepData: $weekStepData, stepCount: $stepCount )
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                }
                
                
            }
            .padding()
        }
        .background(.ultraThinMaterial)
        .frame(width: size / 2, height: size / 2)
    }
    
    @ViewBuilder func CaptureButton(screen: CGFloat, image: Image) -> some View {
        ZStack {
            VStack(alignment: .leading){
                HStack(alignment:.top) {
                    Image(systemName: "camera.fill")
                        .foregroundColor(currentTheme.textBlack)
                        .font(.system(size: screen / 12, design: .default))
                        .background(
                            Circle()
                                .fill(currentTheme.text.shadow(.inner(color: currentTheme.textBlack.opacity(0.25), radius: 5)).shadow(.drop(color: currentTheme.textBlack.opacity(0.25), radius: 5)))
                                .frame(width:screen / 6, height: screen / 6)
                        )
                        .onTapGesture {
                            let image = image.asImage()

                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

                            withAnimation(.easeInOut(duration: 0.3)){
                                saved.toggle()
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                withAnimation(.easeOut.delay(0.5)) {
                                    //sheet.toggle()
                                }
                            })
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                withAnimation(.easeOut) {
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
    
    @ViewBuilder func IconList() -> some View {
        VStack(spacing: 25) {
            Spacer()
            
            Button(action: {
                render(view: Widget(size: 500))
                
                if let img = renderedUIImage {
                    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
                }
                
                withAnimation(.easeInOut(duration: 0.3)){
                    saved.toggle()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                    withAnimation(.easeOut.delay(1)) {
                        saved.toggle()
                    }
                })
            }, label: {
                Image(systemName: "square.and.arrow.down")
                    .font(.title)
            })
            
            if let ui = renderedUIImage {
               
                
                if InstagramSharingUtils.canOpenInstagramStories {
                    Button(action: {
                        render(view: Widget(size: 500))
                        
                        InstagramSharingUtils.shareToInstagramStories(ui)
                    }) {
                        Image("instagram")
                            .font(.title)
                            .scaleEffect(1.2)
                    }
                }
            }
            
            if let img = renderedImage {
                ShareLink(item: img, preview: SharePreview("My progress with the Pro Prosthesis App. https://www.prothese.pro/store", image: img), label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title)
                })
                .onSubmit {
                    render(view: Widget(size: 500))
                }
            }
           
        }.foregroundColor(currentTheme.text)
    }
    
    @MainActor func render(view: some View) {
        let renderer = ImageRenderer(content: view )
        renderer.scale = displayScale
        if let uiImage = renderer.uiImage {
           renderedImage = Image(uiImage: uiImage)
            renderedUIImage = uiImage
        }
   }
    
    private func loadSteps() {
        HealthStoreProvider().queryDayCountbyType(date: datePicker, type: .stepCount, completion: { stepCount in
            DispatchQueue.main.async {
                self.stepCount = stepCount
            }
        })
        
        HealthStoreProvider().queryDayCountbyType(date: datePicker, type: .distanceWalkingRunning, completion: { distance in
            DispatchQueue.main.async {
                stepDistance = distance
            }
        })

        
        for i in 0...4 {
            
            let newDate = Calendar.current.date(byAdding: .day, value: -i, to: datePicker)!
            
            HealthStoreProvider().queryDayCountbyType(date: newDate, type: .stepCount, completion: { stepCount in
                DispatchQueue.main.async {
                    weekStepData.append(ChartDataSnapShotWeekCompair(date: newDate, stepCount: stepCount))
                }
            })
        }
        
        
    }
}


struct SnapShotItem: View {
    private var currentTheme: Theme {
        return ThemeManager().currentTheme()
    }

    var view: SnapShot.SnapshotViews
    
    @Binding var date: Date
    @Binding var stepText: Double
    @Binding var stepDistance: Double
    @Binding var dateText: Double
    @Binding var fontWeight: Font.Weight
    @Binding var weekStepData: [ChartDataSnapShotWeekCompair]
 
    @Binding var stepCount: Double
    
    var body: some View {
        switch view {
            case .stepsToday: WidgetContentStepsStringView(font: .system(size: CGFloat(stepText / 2)), fontWeight: fontWeight, date: $date, stepCount: stepCount)
            case .stepDistance: WidgetContentStepDistanceStringView(font: .system(size: CGFloat(stepText / 2)), stepDistance: stepDistance)
            case .stepsWeek: WidgetContentSnapShotWeek(weekStepData: weekStepData)
            case .dateToday: WidgetContentDateStringView(font: .system(size: CGFloat(dateText / 2)), fontWeight: fontWeight, date: $date)
            case .logo: WidgetContentLogoView()
            case .none: Text("").opacity(0)
        }
    }
}

// WIDGETCONTENTVIEW
struct WidgetContentStepsStringView: View {
    private var currentTheme: Theme {
        return ThemeManager().currentTheme()
    }
    
    var font: Font? = nil
    var fontWeight: Font.Weight? = nil
    var color: Color? = nil
    @Binding var date: Date
    
    var stepCount: Double
    
    var body: some View {
        Text(String(format: NSLocalizedString("%.0f Steps", comment: ""), stepCount))
            .font( font ?? .system(size: 20 / 2) )
            .fontWeight(fontWeight ?? .regular)
            .foregroundColor(color ?? currentTheme.text)
    }
}

struct WidgetContentStepDistanceStringView: View {
    private var currentTheme: Theme {
        return ThemeManager().currentTheme()
    }
    
    var font: Font? = nil
    var fontWeight: Font.Weight? = nil
    var color: Color? = nil
    
    var stepDistance: Double
    
    var test: Bool {
        print("DISTANCE \(stepDistance)")
        return true
    }
    
    var body: some View {
        if stepDistance < 1000.0 {
            Text(String(format: NSLocalizedString("%.0f m", comment: ""), stepDistance))
                .font( .system(size: 40 / 2) )
                .fontWeight(.bold)
                .foregroundColor(color ?? currentTheme.text)
        } else {
            Text(String(format: NSLocalizedString("%.1f km", comment: ""), stepDistance / 1000))
                .font( .system(size: 40 / 2) )
                .fontWeight(.bold)
                .foregroundColor(color ?? currentTheme.text)
        }
    }
}

struct WidgetContentDateStringView: View {
    private var currentTheme: Theme {
        return ThemeManager().currentTheme()
    }
    
    var font: Font? = nil
    var fontWeight: Font.Weight? = nil
    var color: Color? = nil
    @Binding var date: Date
    
    var body: some View {
        Text(date.dateFormatte(date: "dd.MM.yyyy", time: "").date)
            .font( font ?? .system(size: 20 / 2) )
            .fontWeight(fontWeight ?? .regular)
            .foregroundColor(color ?? currentTheme.text)
    }
}

struct WidgetContentSnapShotWeek: View {
    
    private var currentTheme: Theme {
        return ThemeManager().currentTheme()
    }
    
    var weekStepData: [ChartDataSnapShotWeekCompair]
    
    var body: some View {
        Chart() {
            ForEach(weekStepData.sorted(by: {$0.date > $1.date}), id: \.id) { day in
                LineMark(x: .value("Date", day.date), y: .value("Steps", day.stepCount))
                   .interpolationMethod(.catmullRom)
                   .foregroundStyle(currentTheme.text.opacity(0.5))
                   .lineStyle(StrokeStyle(lineWidth: 2))
                   .symbol {
                       
                       if Calendar.current.isDate(day.date, inSameDayAs: Date()) {
                           ZStack {
                               Circle()
                                   .strokeBorder(currentTheme.hightlightColor, lineWidth: 2)
                                   .frame(width: 20)
                               
                               
                               Circle()
                                   .frame(width: 10)
                                   .foregroundColor(currentTheme.hightlightColor)
                           }
                       } else {
                           Circle()
                               .frame(width: 6)
                               .foregroundColor(currentTheme.text)
                       }
                   }
            }
            
        }
        .chartYScale(range: .plotDimension(padding: 10))
        .chartXScale(range: .plotDimension(padding: 20))
        .chartLegend(.hidden)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .frame(height: 50)
    }
}

struct WidgetContentChartDataSnapShotWeekCompair {
    var id = UUID()
    var date: Date
    var stepCount: Double
}

struct WidgetContentLogoView: View {
    var body: some View {
        Image("SnapShotLogo")
            .resizable()
            .scaledToFit()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }
}
// WIDGETCONTENTVIEW

// SNAPSHOT VIEWS
extension SnapShotView {
    @ViewBuilder func AnimatedScrollView() -> some View {
        ScrollView(.vertical, showsIndicators: false, content: {
            
        })
        .coordinateSpace(name: "SCROLL")
        .ignoresSafeArea(.container, edges: .vertical)
    }
    
    @ViewBuilder func AnimatedHeader() -> some View {
        GeometryReader { proxy in
            
            let minY = proxy.frame(in: .named("SCROLL")).minY
            let size = proxy.size
            let height = (size.height + minY)
            
            Rectangle()
                .fill(currentTheme.gradientBackground(nil))
                .frame(width: size.width, height: height, alignment: .top)
                .overlay(content: {
                    ZStack {
                        
                        currentTheme.gradientBackground(nil)
                        
                        FloatingClouds(speed: 1.0, opacity: 0.8)
                        
                        LinearGradient(
                            colors: [
                                currentTheme.backgroundColor,
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                    
                     AnimatedHeaderContent()
                        .blur(radius: abs(minY / 100 * 2))
                        .offset(y: minY.sign == .minus ? minY * 1.5 : 0)
                        //.opacity(calcOpacity(minY))
                    
                })
                .cornerRadius(20)
                .offset(y: minY)
            
        }
        .frame(height: 250)
    }
    
    @ViewBuilder func AnimatedHeaderContent() -> some View {
        VStack {
            Switcher()
                .foregroundColor(currentTheme.text)
        }
        .padding()
        .background(currentTheme.text.ignoresSafeArea())
        //.saveSize(in: $dynamicSheet)
    }
    
    @ViewBuilder func Switcher(width: CGFloat? = nil) -> some View {
        VStack {

            Picker("", selection: $editView) {
                ForEach(SnapShot.SnapshotBackground.allCases, id: \.self) { edge in
                    Text(edge.rawValue).tag(edge)
                }
           }
           .pickerStyle(.segmented)
            
            TabView(selection: $editView, content: {
                BackgroundEdit().tag(SnapShot.SnapshotBackground.background)
                ContentEdit().tag(SnapShot.SnapshotBackground.content)
            })
                
           
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder func BackgroundEdit() -> some View {
        VStack(spacing: 15) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                ForEach(images, id: \.self) { image in
                    
                    Button(action: {
                        withAnimation(.easeInOut) {
                            selectedBackgroundImage = image
                        }
                    }, label: {
                        Image(image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .border(currentTheme.hightlightColor, width: selectedBackgroundImage == image ? 2 : 0)
                            .animation(.easeInOut, value: selectedBackgroundImage)
                    })
                    
                    
                }
            }

            ToggleRow(text: "Darken the upper background", state: $topGradient, slider: true, value: $topGradientOpacity, decimal: 1, sliderText: "\( topGradientOpacity, specifier: "%.1f") Darkness")
            
            ToggleRow(text: "Darken the bottom background", state: $bottomGradient, slider: true, value: $bottomGradientOpacity, decimal: 1, sliderText: "\( topGradientOpacity, specifier: "%.1f") Darkness")
            
            ToggleRow(text: "Background Overlay", state: enviromentAppState ? $showBgOverlay : .constant(true) , slider: false, value: .constant(0))
            
            Spacer()
        }
        .background(currentTheme.text)
    }
    
    @ViewBuilder func ContentEdit() -> some View {
        VStack(spacing: 15) {
            

            Picker("", selection: $contentEditView) {
                ForEach(SnapShot.SnapshotEdge.allCases, id: \.self) { edge in
                    Text(edge.rawValue).tag(edge)
                }
            }
            .pickerStyle(.segmented)
            
            TabView(selection: $contentEditView, content: {
                VStack(spacing: 15) {
                    let edge = TL
                    
                    ViewSwitcher(state: "TL")
                    
                    FontSizePicker(state: edge, contains: [.stepsToday, .dateToday])
                    
                    DatePickerRow(state: edge, contains: [.stepsToday, .dateToday])
                    
                    StepsTodayTextSize(state: edge, contains: [.stepsToday])
                    
                    DateTodayTextSize(state: edge, contains: [.dateToday])
                    
                    Spacer()
                }
                .tag(SnapShot.SnapshotEdge.topLeft)
                .background(currentTheme.text)
                
                VStack(spacing: 15) {
                    let edge = TR
                    
                    ViewSwitcher(state: "TR")
                    
                    FontSizePicker(state: edge, contains: [.stepsToday, .dateToday])
                    
                    DatePickerRow(state: edge, contains: [.stepsToday, .dateToday])
                    
                    StepsTodayTextSize(state: edge, contains: [.stepsToday])
                    
                    DateTodayTextSize(state: edge, contains: [.dateToday])
                    
                    Spacer()
                }
                .tag(SnapShot.SnapshotEdge.topRight)
                .background(currentTheme.text)
                
                ZStack {
                    VStack(spacing: 15) {
                        let edge = BL
                        
                        ViewSwitcher(state: "BL")
                            .blur(radius: enviromentAppState ? 0 : 2)
                        
                        FontSizePicker(state: edge, contains: [.stepsToday, .dateToday])
                            .blur(radius: enviromentAppState ? 0 : 2)
                        DatePickerRow(state: edge, contains: [.stepsToday, .dateToday])
                            .blur(radius: enviromentAppState ? 0 : 2)
                        StepsTodayTextSize(state: edge, contains: [.stepsToday])
                            .blur(radius: enviromentAppState ? 0 : 2)
                        DateTodayTextSize(state: edge, contains: [.dateToday])
                            .blur(radius: enviromentAppState ? 0 : 2)
                        Spacer()
                    }
                    .padding(enviromentAppState ? 0 : 2)
                    
                   
                    Button(action: {
                        isShopSheep.toggle()
                    }, label: {
                        TextBadge(padding: 15, text: "Get Pro", font: .title3.bold())
                    })
                    .sheetModifier(showAds: false, isSheet: $isShopSheep, sheetContent: {
                        ShopSheet(isSheet: $isShopSheep)
                    })
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .show(!enviromentAppState)
                  
                        
                }
                .tag(SnapShot.SnapshotEdge.bottomLeft)
                .background(currentTheme.text)
                
                VStack(spacing: 15) {
                    let edge = BR
                    
                    ViewSwitcher(state: "BR")

                    FontSizePicker(state: edge, contains: [.stepsToday, .dateToday])
                    
                    DatePickerRow(state: edge, contains: [.stepsToday, .dateToday])
                    
                    StepsTodayTextSize(state: edge, contains: [.stepsToday])
                    
                    DateTodayTextSize(state: edge, contains: [.dateToday])
                    
                    Spacer()
                }
                .tag(SnapShot.SnapshotEdge.bottomRight)
                .background(currentTheme.text)
            })
        }
        .background(currentTheme.text)
    }
    
    @ViewBuilder func ViewSwitcher(state: String) -> some View {
        let steps = SnapShot.SnapshotViews.stepsToday
        let stepDistance = SnapShot.SnapshotViews.stepDistance
        let stepsWeek = SnapShot.SnapshotViews.stepsWeek
        let date = SnapShot.SnapshotViews.dateToday
        let logo = SnapShot.SnapshotViews.logo
        let none = SnapShot.SnapshotViews.none
        
        HStack {
            Text("Element").font(.body.bold())
            
            Spacer()
            
            Menu(content: {
                Button(steps.rawValue, action: {
                    switch state {
                        case "TL": self.TL = steps
                        case "TR": self.TR = steps
                        case "BL": self.BL = steps
                        case "BR": self.BR = steps
                        default: return
                    }
                })
         
                Button(stepsWeek.rawValue, action: {
                    switch state {
                        case "TL": self.TL = stepsWeek
                        case "TR": self.TR = stepsWeek
                        case "BL": self.BL = stepsWeek
                        case "BR": self.BR = stepsWeek
                        default: return
                    }
                })
                Button(stepDistance.rawValue, action: {
                    switch state {
                        case "TL": self.TL = stepDistance
                        case "TR": self.TR = stepDistance
                        case "BL": self.BL = stepDistance
                        case "BR": self.BR = stepDistance
                        default: return
                    }
                })
                Button(date.rawValue, action: {
                    switch state {
                        case "TL": self.TL = date
                        case "TR": self.TR = date
                        case "BL": self.BL = date
                        case "BR": self.BR = date
                        default: return
                    }
                })
                
                Button(logo.rawValue, action: {
                    switch state {
                        case "TL": self.TL = logo
                        case "TR": self.TR = logo
                        case "BL": self.BL = logo
                        case "BR": self.BR = logo
                        default: return
                    }
                })
                
                Button(none.rawValue, action: {
                    switch state {
                        case "TL": self.TL = none
                        case "TR": self.TR = none
                        case "BL": self.BL = none
                        case "BR": self.BR = none
                        default: return
                    }
                })
            }, label: {
                
                switch state {
                    case "TL": Text(self.TL.rawValue).font(.body.bold()).foregroundColor(currentTheme.text)
                    case "TR": Text(self.TR.rawValue).font(.body.bold()).foregroundColor(currentTheme.text)
                    case "BL": Text(self.BL.rawValue).font(.body.bold()).foregroundColor(currentTheme.text)
                    case "BR": Text(self.BR.rawValue).font(.body.bold()).foregroundColor(currentTheme.text)
                    default: Text("NONE")
                }
 
            })
            .padding(10)
            .background(currentTheme.backgroundColor)
            .cornerRadius(15)
        }
    }
    
    @ViewBuilder func DatePickerRow(state: SnapShot.SnapshotViews , contains: [SnapShot.SnapshotViews]) -> some View {
        ForEach(contains, id: \.hashValue) { item in // Steps, Date
            if state == SnapShot.SnapshotViews(rawValue: item.rawValue) {
                HStack {
                    Text("Date").font(.body.bold())
                    Spacer()
                    DatePicker("", selection: $datePicker, displayedComponents: .date)
                        .background(currentTheme.backgroundColor)
                        .font(.body)
                        .cornerRadius(10)
                        .labelsHidden()
                }
            }
        }
        
    }
    
    @ViewBuilder func StepsTodayTextSize(state: SnapShot.SnapshotViews , contains: [SnapShot.SnapshotViews]) -> some View {
        ForEach(contains, id: \.hashValue) { item in // Steps, Date
            if state == SnapShot.SnapshotViews(rawValue: item.rawValue) {
                VStack {
                    Slider(value: $textSizeSteps, in: 20...50, step: 5)
                    Text("Fontsize: \( textSizeSteps, specifier: "%.0f") px")
                }
            }
        }
        
    }
    
    @ViewBuilder func DateTodayTextSize(state: SnapShot.SnapshotViews , contains: [SnapShot.SnapshotViews]) -> some View {
        ForEach(contains, id: \.hashValue) { item in // Steps, Date
            if state == SnapShot.SnapshotViews(rawValue: item.rawValue) {
                VStack {
                    Slider(value: $textSizeDate, in: 20...50, step: 5)
                    Text("Fontsize: \( textSizeDate, specifier: "%.0f") px")
                }
            }
        }
        
    }
    
    @ViewBuilder func FontSizePicker(state: SnapShot.SnapshotViews , contains: [SnapShot.SnapshotViews]) -> some View {
        
        ForEach(contains, id: \.hashValue) { item in // Steps, Date
            if state == SnapShot.SnapshotViews(rawValue: item.rawValue) {
                HStack {
                    Text("Font Weigt").font(.body.bold())
                    
                    Spacer()
                    
                    Menu(content: {
                        Button("Thin", action: {
                            fontWeight = .thin
                        })
                        Button("Regular", action: {
                            fontWeight = .regular
                        })
                        Button("Bold", action: {
                            fontWeight = .bold
                        })
                    }, label: {
                        
                        switch fontWeight {
                            case .thin: Text("Thin").font(.body.bold()).foregroundColor(currentTheme.text)
                            case .regular: Text("Regular").font(.body.bold()).foregroundColor(currentTheme.text)
                            case .bold: Text("Bold").font(.body.bold()).foregroundColor(currentTheme.text)
                            default: Text("Unknown").font(.body.bold()).foregroundColor(currentTheme.text)
                        }
         
                    })
                    .padding(10)
                    .background(currentTheme.backgroundColor)
                    .cornerRadius(15)
                }
            }
        }
        
        
    }
    
    @ViewBuilder func ToggleRow(text: LocalizedStringKey, state: Binding<Bool>, slider: Bool? = nil, value: Binding<Double>, decimal: Int? = nil, sliderText: LocalizedStringKey? = nil) -> some View {
        VStack {
            Toggle(text, isOn: state)
            
            if slider ?? false {
                if state.wrappedValue {
                    VStack {
                        Slider(value: value, in: 0.1...0.6)
                        Text(sliderText ?? "").font(.footnote)
                    }
                }
            }
        }.padding(.horizontal, 2)
    }
}
// SNAPSHOT VIEWS

// MODELS
struct ChartDataSnapShotWeekCompair {
    var id = UUID()
    var date: Date
    var stepCount: Double
}

enum SnapShot {
    enum SnapshotBackground: LocalizedStringKey, CaseIterable, Hashable {
        case background = "Background"
        case content = "Content"
    }
    
    enum SnapshotViews: LocalizedStringKey, CaseIterable, Hashable {
        case stepsToday = "Steps"
        case stepsWeek = "Week Step"
        case dateToday = "Date"
        case stepDistance = "Distance"
        case logo = "Logo"
        case none = "Empty"
    }
    
    enum SnapshotEdge: LocalizedStringKey, CaseIterable {
        case topLeft = "Top-Left"
        case topRight = "Top-Right"
        case bottomLeft = "Bottom-Left"
        case bottomRight = "Bottom-Right"
    }
}
// MODELS

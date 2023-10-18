//
//  ContentView.swift
//  Drawing App
//
//  Created by Shubham on 10/17/23.
//

import SwiftUI


// MARK: CheckerBoard
struct CheckerBoard: Shape {
    var rows: Int
    var columns: Int
    
    var animatableData: AnimatablePair<Double,Double> {
        get {
            AnimatablePair(Double(rows), Double(columns))
        }
        
        set {
            rows = Int(newValue.first)
            columns = Int(newValue.second)
        }
    }
    
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        var rowSize = rect.height / Double(rows)
        var columnSize = rect.width / Double (columns)
        
        for row in 0..<rows {
            for col in 0..<columns {
                if (row + col).isMultiple(of: 2) {
                    let startX = columnSize * Double(col)
                    let startY = rowSize * Double(row)
                    
                    let rect = CGRect(x: startX, y: startY, width: columnSize, height: rowSize)
                    path.addRect(rect)
                }
            }
        }
        
        return path
    }
}

// MARK: Trapezoid
struct Trapezoid: Shape {
    var insetAmount: Double
    var animatableData: Double {
        get { insetAmount }
        set { insetAmount = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: insetAmount, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - insetAmount, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        
        return path
    }
}


// MARK: Metal Tutorial
struct ColorCylingCircle: View {
    var amount = 0.0
    var steps = 100
    
    var body: some View {
        ZStack {
            ForEach(0..<steps) { value in
                Circle()
                    .inset(by: Double(value))
                    .strokeBorder(
                        LinearGradient(colors: [
                            color(for: value, brightness: 1),
                            color(for: value, brightness: 0.5)
                        ], startPoint: .top, endPoint: .bottom)
                        , lineWidth: 2
                    )
            }
        }
        .drawingGroup() // Does metal thing move to background view and then shows it
    }
    
    func color(for value: Int, brightness: Double) -> Color {
        var targetHue = Double(value) / Double(steps) + amount
        
        if targetHue > 1 {
            targetHue -= 1
        }

        return Color(hue: targetHue, saturation: 1, brightness: brightness)
    }
}

// MARK: Flower Shape
struct Flower: Shape {
    var petalOffset = -20.0
    var petalWidth = 100.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        
        for number in stride(from: 0, to: Double.pi * 2, by: Double.pi / 8) {
            let rotation = CGAffineTransform(rotationAngle: number)
            let postion = rotation.concatenating(CGAffineTransform(translationX: rect.width / 2, y: rect.height / 2))
            
            let originalPetal = Path(ellipseIn: CGRect(x: petalOffset, y: 0, width: petalWidth, height: rect.width / 2))
            let rotatedPetal = originalPetal.applying(postion)
            
            path.addPath(rotatedPetal)
        }
        
        return path
    }
}

// MARK: Triangle Shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        
        return path
    }
}

// MARK: Arc Shape
struct Arc: InsettableShape {
    
    let startAngle: Angle
    let endAngle: Angle
    let clockwise: Bool
    var insetAmount = 0.0
    
    func path(in rect: CGRect) -> Path {
        let rotationAdjustment = Angle.degrees(90)
        let modifiedStart = startAngle - rotationAdjustment
        let modifiedEnd = endAngle - rotationAdjustment
        
        var path = Path()
        
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2 - insetAmount, startAngle: modifiedStart, endAngle: modifiedEnd, clockwise: !clockwise)
        
        return path
    }
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }
}


// MARK: Spirograph
struct Spirograph: Shape {
    let innerRadius: Int
    let outerRadius: Int
    let distance: Int
    let amount: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let divisor = gdc(innerRadius, outerRadius)
        let outerRadius = Double(self.outerRadius)
        let innerRadius = Double(self.innerRadius)
        let distance = Double(self.distance)
        let difference = innerRadius - outerRadius
        let endPoint = ceil(2 * Double.pi * outerRadius / Double(divisor)) * amount
        
        for theta in stride(from: 0, through: endPoint, by: 0.01) {
            var x = difference * cos(theta) + distance * cos(difference / outerRadius * theta)
            var y = difference * sin(theta) + distance * sin(difference / outerRadius * theta)
            
            x += rect.width / 2
            y += rect.height / 2
            
            if theta == 0 {
                path.move(to: CGPointMake(x, y))
            } else {
                path.addLine(to: CGPointMake(x, y))
            }
        }
        
        return path
    }
    
    func gdc(_ a: Int, _ b : Int) -> Int {
        var a = a
        var b = b
        
        while b != 0 {
            let temp = b
            b = a % b
            a = temp
        }
        
        return a
    }
}


struct Arrow: Shape {
    var yOffset: CGFloat
    var xOffset: CGFloat
    
    var animatableData: AnimatablePair<CFloat, CGFloat> {
        get {
            AnimatablePair(CFloat(yOffset), CGFloat(xOffset))
        }
        
        set {
            yOffset = CGFloat(newValue.first)
            xOffset = CGFloat(newValue.second)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY - yOffset))
        
        path.addLine(to: CGPoint(x: rect.midX - xOffset, y: rect.midY - yOffset))
        path.addLine(to: CGPoint(x: rect.midX - xOffset, y: rect.maxY))
        
        path.addLine(to: CGPoint(x: rect.midX + xOffset, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX + xOffset, y: rect.midY - yOffset))
        
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY - yOffset))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        
        return path
    }
}

struct ColorCylingRect: View {
    var colorCycle = 0.0
    var steps = 100
    
    var body: some View {
        ZStack {
            ForEach(0..<steps) { value in
                Rectangle()
                    .inset(by: Double(value))
                    .strokeBorder(
                        LinearGradient(colors: [
                            color(for: value, brightness: 1),
                            color(for: value, brightness: 0.5)
                        ], startPoint: .top, endPoint: .bottom)
                        , lineWidth: 2
                    )
            }
        }
        .drawingGroup() // Does metal thing move to background view and then shows it
    }
    
    func color(for value: Int, brightness: Double) -> Color {
        var targetHue = Double(value) / Double(steps) + colorCycle
        
        if targetHue > 1 {
            targetHue -= 1
        }
        
        return Color(hue: targetHue, saturation: 1, brightness: brightness)
    }
}


struct ContentView: View {
    //    @State private var petalOffset = -20.0
    //    @State private var petalWidth = 100.0
    //    @State private var colorCycle = 0.0
    //    @State private var amount = 0.0
    //    @State private var insetAmount = 50.0
    //    @State private var rows = 4
    //    @State private var columns = 4
    //    @State private var innerRadius = 125.0
    //    @State private var outerRadius = 75.0
    //    @State private var distance = 25.0
    //    @State private var amount = 1.0
    //    @State private var hue = 0.6
    //    @State private var yOffset = 20.0
    //    @State private var xOffset = 40.0
    @State private var colorCycle = 0.0
    @State private var useGradient = true
    @State private var locX = 50.0
    @State private var locY = 50.0
    
    var body: some View {
        VStack {
            Toggle("Use gradient?", isOn: $useGradient)
            ZStack {
                GeometryReader { geometery in
                    let w = geometery.size.width
                    let h = geometery.size.height
                    let m = min(w, h)
                    let centerX = locX
                    let centerY = locY
                    
                    VStack {
                        if useGradient {
                            let center = UnitPoint(x: centerX / w, y: centerY / h)
                            RoundedRectangle(cornerRadius: 20.0)
                            ColorCylingRect(colorCycle: colorCycle)
                                .frame(width: 300, height: 300)
                            Slider(value: $colorCycle)
                                .padding()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

//ColorCylingCircle(amount: colorCycle)
//    .frame(width: 300, height: 300)
//Slider(value: $colorCycle)


//Arrow(yOffset: yOffset, xOffset: xOffset)
//    .frame(width: 300, height: 500)
//    .foregroundStyle(.green)
//
//Spacer()
//
//Group {
//    Text("yOffset")
//    Slider(value: $yOffset, in: 0...100)
//        .tint(.red)
//        .padding()
//    
//    Text("xOffset")
//    Slider(value: $xOffset, in: 20...80)
//        .tint(.red)
//        .padding()
//}


//VStack(spacing: 0) {
//    Spacer()
//
//    Spirograph(innerRadius: Int(innerRadius), outerRadius: Int(outerRadius), distance: Int(distance), amount: amount)
//        .stroke(Color(hue: hue, saturation: 1.0, brightness: 1.0), lineWidth: 1.0)
//        .frame(width: 300, height: 300)
//
//    Spacer()
//
//    Group {
//        Text("Inner Radius: \(Int(innerRadius))")
//        Slider(value: $innerRadius, in: 10...150, step: 1)
//            .padding([.horizontal, .bottom])
//
//        Text("Outer Radius: \(Int(outerRadius))")
//        Slider(value: $outerRadius, in: 10...150, step: 1)
//            .padding([.horizontal, .bottom])
//
//        Text("Distance: \(Int(distance))")
//        Slider(value: $distance, in: 1...150, step: 1)
//            .padding([.horizontal, .bottom])
//
//        Text("Amount: \(amount, format: .number.precision(.fractionLength(2)))")
//        Slider(value: $amount)
//            .padding([.horizontal, .bottom])
//
//        Text("Color")
//        Slider(value: $hue)
//            .padding(.horizontal)
//    }
//}


//CheckerBoard(rows: rows, columns: columns)
//    .onTapGesture {
//        withAnimation(.linear(duration: 3)) {
//            rows = 8
//            columns = 16
//        }
//    }



//VStack {
//    Trapezoid(insetAmount: insetAmount)
//        .frame(width: 200.0, height: 200.0)
//        .onTapGesture {
//            withAnimation {
//                insetAmount = Double.random(in: 10...90)
//            }
//        }
//          Slider(value: $insetAmount)
//                .padding()
//}


//VStack {
//    ZStack {
//        Circle()
//            .fill(Color(red: 1.0, green: 0.0, blue: 0.0))
//            .frame(width: 200 * amount)
//            .offset(x: -50, y: -80)
//            .blendMode(.screen)
//
//        Circle()
//            .fill(Color(red: 0.0, green: 1.0, blue: 0.0))
//            .frame(width: 200 * amount)
//            .offset(x: 50, y: -80)
//            .blendMode(.screen)
//
//        Circle()
//            .fill(Color(red: 0.0, green: 0.0, blue: 1.0))
//            .frame(width: 200 * amount)
//            .blendMode(.screen)
//
//    }
//    .frame(width: 300, height: 300)
//
//    Slider(value: $amount)
//        .padding()
//}
//.frame(maxWidth: .infinity, maxHeight: .infinity)
//.background(.black)
//.ignoresSafeArea()


//Text("SwiftUI Vs UIKit")
//    .frame(width: 300, height: 300)
//    .border(ImagePaint(image: Image(systemName: "mail.fill"), scale: 0.1), width: 25)


//VStack {
//    Flower(petalOffset: petalOffset, petalWidth: petalWidth)
//        .fill(.red, style: FillStyle(eoFill: true, antialiased: true))
////                .stroke(.blue, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
//
//    Text("Offset")
//    Slider(value: $petalOffset, in: -40...40)
//        .padding([.horizontal, .bottom])
//
//    Text("Width")
//    Slider(value: $petalWidth, in: 0...100)
//        .padding(.horizontal)
//}


//Arc(startAngle: .degrees(0), endAngle: .degrees(180), clockwise: true)
//    .strokeBorder(.indigo, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))


//Arc(startAngle: .degrees(0), endAngle: .degrees(90), clockwise: true)
//    .stroke(.red, lineWidth: 10)
//    .frame(width: 300, height: 300)



//Group {
//    Path { path in
//        path.move(to: CGPoint(x: 100, y: 100))
//        path.addLine(to: CGPoint(x: 100, y: 100))
//        path.addLine(to: CGPoint(x: 100, y: 300))
//        path.addLine(to: CGPoint(x: 300, y: 300))
//        path.addLine(to: CGPoint(x: 300, y: 100))
//        path.closeSubpath()
//    }
//    .fill(Color.black)
//.stroke(.pink, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
//}

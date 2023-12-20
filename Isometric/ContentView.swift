//
//  ContentView.swift
//  Isometric
//
//  Created by Prathamesh on 20/12/23.
//

import SwiftUI

struct ContentView: View {
    @State var b: CGFloat = 0  //-0.2
    @State var c : CGFloat = 0 // -0.3
    @State var animate: Bool = false
//
    var body: some View {
        ZStack{
            VStack{
                Spacer()
                IsometricView(depth: animate ? 25 : 0) {
                    ImageView()
                } bottom: {
                    ImageView()
                } right: {
                    ImageView()
                } left: {
                    ImageView()
                }
                .frame(width: 180,height: 330)
                .shadow(color: .black.opacity((b == 0) ? 0 : 0.75), radius: 12,x: 8, y: 20)
                .modifier(CustomProjection(b: b, c: c))
                .rotation3DEffect(
                    .init(degrees: animate ? 45 : 0),
                    axis: (x: 0.0, y: 0.0, z: 1)
                )
                .scaleEffect(0.7)
                .offset(x: animate ? 12 : 0)
                Spacer()
                HStack{Spacer()
                    Button("Animate"){
                        withAnimation(.easeInOut(duration: 1)) {
                            animate = true
                            b = -0.2
                            c = -0.3
                        }
                    }
                    Spacer()
                    Button("Reset"){
                        withAnimation(.easeInOut(duration: 0.3)) {
                            animate = false
                            b = 0
                            c = 0
                        }
                       
                    }
                    Spacer()
                }
                Spacer()
            }
            
        }
        .frame(maxHeight: .infinity,alignment: .top)
    }
        
}

@ViewBuilder
func ImageView()->some View{
    Image("Pic 1")
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: 180,height: 330)
        .clipped()
}

struct CustomProjection: GeometryEffect{
    
    var b : CGFloat
    var c : CGFloat
    
    var animatableData: AnimatablePair<CGFloat,CGFloat>{
        get{
            AnimatablePair(b, c)
        }
        set{
            b = newValue.first
            c = newValue.second
        }
    }

     
    func effectValue(size: CGSize) -> ProjectionTransform {
        return .init(.init(1,b,c,1,0,0))
        
    }
}

#Preview {
    ContentView()
}

struct IsometricView<Content: View, Bottom: View, Right: View,Left: View>: View{
    var content : Content
    var bottom : Bottom
    var right : Right
    var left : Left
    var depth : CGFloat
    
    init(depth:CGFloat,@ViewBuilder content: @escaping()->Content,@ViewBuilder bottom: @escaping()->Bottom,@ViewBuilder right: @escaping()->Right,@ViewBuilder left: @escaping()->Left) {
        self.depth = depth
        self.content = content()
        self.bottom = bottom()
        self.right = right()
        self.left = left()
    }
    
    var body: some View{
        Color.clear
        
            .overlay {
                GeometryReader{
                    let size = $0.size
                    ZStack{
                        content
                        DepthView(sides: .bottom,size: size)
                        DepthView(sides: .right,size: size)
//                        DepthView(sides: .left,size: size)
                    }
                    .frame(width: size.width,height: size.height)
                    
                }
            }
    }
 
    @ViewBuilder
    func DepthView(sides: Sides,size: CGSize)-> some View{
        ZStack{
            switch sides{
            case .bottom:
                bottom
                    .scaleEffect(y: depth,anchor: .bottom)
                    .frame(height: depth,alignment: .bottom)
                    .overlay(content: {
                        Rectangle()
                            .fill(.black.opacity(0.35))
                            .blur(radius: 2.5)
                    })
                    .clipped()
                    .projectionEffect(.init(.init(a: 1, b:0, c:1, d:1, tx: 0, ty: 0)))
                    .offset(y:depth)
                    .frame(maxHeight: .infinity,alignment: .bottom)
                
            case .right:
                right
                    .scaleEffect(x: depth,anchor: .trailing)
                    .frame(width:depth,alignment: .trailing)
                    .overlay(content: {
                        Rectangle()
                            .fill(.black.opacity(0.35))
                            .blur(radius: 2.5)
                    })
                    .clipped()
                    .projectionEffect(.init(.init(a: 1, b: 1, c: 0, d:1, tx: 0, ty: 0)))
                    .offset(x:depth)
                    .frame(maxWidth: .infinity,alignment: .trailing)
                
            case .left:
                left
                    .scaleEffect(x: depth,anchor: .trailing)
                    .frame(width:depth,alignment: .trailing)
                    .overlay(content: {
                        Rectangle()
                            .fill(.black.opacity(0.35))
                            .blur(radius: 2.5)
                    })
                    .clipped()
                    .projectionEffect(.init(.init(a: 1, b: -1, c: 0, d:1, tx: 0, ty: 0)))
                    .offset(x:-depth,y: depth)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    
            default:
               Text("sorry")
            }
        }
    }
}


enum Sides{
    case left
    case right
    case top
    case bottom
}

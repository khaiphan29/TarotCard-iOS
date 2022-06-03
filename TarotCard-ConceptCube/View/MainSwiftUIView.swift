//
//  MainSwiftUIView.swift
//  TarotCard-ConceptCube
//
//  Created by Phan Khai on 03/06/2022.
//

import SwiftUI

struct MainSwiftUIView: View {
    @State var posistion = CGSize.zero
    var body: some View {
        ZStack {
            Color(.gray)
            Image("bb")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 200)
                .offset(posistion)
            
                .gesture(
                    DragGesture()
                        .onChanged({ value in
                            posistion = value.translation
                        })
                        .onEnded({ value in
                            
                        }))
        }
        }
        
}

struct MainSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        MainSwiftUIView()
    }
}

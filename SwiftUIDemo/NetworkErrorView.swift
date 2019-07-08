//
//  NetworkErrorView.swift
//  SwiftUIDemo
//
//  Created by Fengwei Liu on 7/7/19.
//  Copyright © 2019 Fengwei Liu. All rights reserved.
//

import SwiftUI

struct NetworkErrorView : View {
    let error: URLError
    let retryAction: (() -> Void)

    init(error: URLError, retryAction: @escaping (() -> Void)) {
        self.error = error
        self.retryAction = retryAction
    }

    var body: some View {
        VStack {
            Text("NETWORK ERROR")
                .font(.largeTitle)
                .color(.gray)
                .padding(0)
            Text(self.error.localizedDescription)
                .color(.gray)
                .font(.caption)
                .lineLimit(2)
                .padding([.leading, .trailing], 50)
                .padding([.top, .bottom], 10)
            Button(action: self.retryAction) {
                Text("Retry").color(.gray)
            }.padding(
                EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20)
            ).border(Color.gray, cornerRadius: 8)

        }
    }
}

#if DEBUG
struct NetworkErrorView_Previews : PreviewProvider {
    static var previews: some View {
        return NetworkErrorView(error: URLError(.badServerResponse)) {

        }
    }
}
#endif

//
//  ContentView.swift
//  SwiftUIDemo
//
//  Created by Fengwei Liu on 7/1/19.
//  Copyright © 2019 Fengwei Liu. All rights reserved.
//

import SwiftUI
import SafariServices

struct ContentView : View {
    @State var selectedTimeRange = TimeRange.daily
    @EnvironmentObject var store: GitHubTrendingStore

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
                timeRangeSegmentControl.padding()
                trendingView
            }
            .navigationBarTitle("\(self.store.currentLanguage.title) Trending")
                .navigationBarItems(leading: languagePickerButton, trailing: refreshButton)
        }
    }

    var trendingView: some View {
        GeometryReader { proxy in
            TrendingView(timeRange: self.$selectedTimeRange)
                .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    var timeRangeSegmentControl : some View {
        SegmentedControl(selection: self.$selectedTimeRange) {
            ForEach(TimeRange.allCases.identified(by: \.self)) { tm in
                Text(tm.rawValue.capitalized).tag(tm)
            }
        }
    }

    var languagePickerButton : some View {
        PresentationLink(destination: LanguagePickerView(selectedLanguage: $store.currentLanguage)) {
            Image(systemName: "list.dash").accentColor(.gray)
        }
    }

    var refreshButton: some View {
        Button(action: {
            self.store.reloadItems(in: self.selectedTimeRange)
        }) {
            Image(systemName: "arrow.counterclockwise").accentColor(.gray)
        }
    }
}

struct TrendingView : View {
    @Binding var timeRange: TimeRange
    @EnvironmentObject var store: GitHubTrendingStore

    var body: AnyView {
        switch store.items(in: timeRange) {
        case .failed(let error):
            return NetworkErrorView(error: error) {
                self.store.reloadItems(in: self.timeRange)
            }.eraseToAnyView()
        case .loaded(let items):
            return TrendingListView(items: items).eraseToAnyView()
        case .loading:
            return LoadingView(isLoading: .constant(true)).eraseToAnyView()
        }
    }
}

struct LanguagePickerView : View {
    @Binding var selectedLanguage: Language
    @Environment(\.isPresented) var isPresented: Binding<Bool>?

    var body: some View {
        List(Language.allCases.identified(by: \.self), action: { lang in
            self.selectedLanguage = lang
            self.isPresented?.value = false
        }) { lang in
            Text(lang.title).tag(lang)
                .padding()
        }
    }
}

struct DetailView : View {
    @Environment(\.isPresented) var isPresented: Binding<Bool>?

    var body: Group<TupleView<(Text, Button<Text>?)>> {
        let view = Group {
            Text("Detail view")
            if (isPresented?.value == true) {
                dismissButton
            }
        }
        return view
    }

    var dismissButton: Button<Text> {
        return Button(action: {
            self.isPresented?.value = false
        }) {
            Text("Dismiss")
        }
    }
}

struct TrendingListView : View {
    @State var selectedIndex = -1
    let items: [GitHubTrendingItem]

    var body: some View {
        List(items) { item in
            PresentationLink(destination: SafariView(url: item.url)) {
                TrendingItemView(item: item)
                    .padding([.leading, .trailing])
            }
        }
    }
}

struct TrendingItemView : View {
    let item: GitHubTrendingItem

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("@\(item.author) / \(item.name)")
                    .fontWeight(.bold)
                Spacer()
                Text("\(item.stars)")
                    .color(.gray)
                Image(systemName: "star.fill")
                    .resizable()
                    .frame(width: 16, height: 16, alignment: .center)
                    .offset(x: 0, y: -1)
                    .foregroundColor(.yellow)
            }
            Text(item.description)
                .font(.subheadline)
                .color(.gray)
                .lineLimit(nil)
                .padding([.top, .bottom], 4)
        }
    }
}

struct LoadingView : UIViewRepresentable {
    @Binding var isLoading: Bool

    func makeUIView(context: UIViewRepresentableContext<LoadingView>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: .large)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<LoadingView>) {
        if isLoading {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
    }
}

struct SafariView : UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: UIViewControllerRepresentableContext<SafariView>
    ) {
        		
    }
}

extension GitHubTrendingItem : Identifiable {
    var id: URL {
        url
    }
}

extension Language {
    var title: String {
        rawValue.capitalized
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var store: GitHubTrendingStore {
        GitHubTrendingStore(storage: [
            .daily : .loaded([
                GitHubTrendingItem(
                    author: "apple",
                    name: "swift",
                    description: "The Swift Programming Language https://swift.org",
                    url: URL(string: "https://github.com/apple/swift")!,
                    stars: 12354
                )
            ]),
            .weekly : .loading,
            .monthly : .failed(URLError(.badURL)),
        ])
    }

    static var previews: some View {
        return ContentView().environmentObject(store)
    }
}
#endif

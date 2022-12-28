//
//  ContentView.swift
//  FinalNewsApp1
//
//  Created by Ravnish Singh on 27/12/22.
//

import SwiftUI
import SwiftyJSON
import SDWebImageSwiftUI
import WebKit

struct ContentView: View {
    var body: some View {
        
        Home()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Home : View {
    
    @State var index = 0
    @State var show = false
    
    var body : some View{
       
        VStack(spacing: 0){
            
            appBar(index: self.$index,show: self.$show)
            
            ZStack{
                
                NewsFeed(show: self.$show).opacity(self.index == 0 ? 1 : 0)
                
                TopHeadline(show: self.$show).opacity(self.index == 1 ? 1 : 0)
                
            }

            
        }.edgesIgnoringSafeArea(.top)
    }
}

struct appBar : View {
    
    @Binding var index : Int
    @Binding var show : Bool
    
    var body : some View{
        
        VStack(spacing: 25){
            
            if self.show {
                HStack(spacing: 25){
                    
                    Text("NEWS")
                        .fontWeight(.bold)
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Spacer(minLength: 0)
                    
                    .padding(.leading)
                }
            
        }
            HStack{
                
                Button(action: {
                    
                    self.index = 0
                    
                }) {
                    
                    VStack{
                        
                        Text("News Feed")
                            .foregroundColor(.white)
                            .fontWeight(self.index == 0 ? .bold : .none)
                        
                        Capsule().fill(self.index == 0 ? Color.white : Color.clear)
                        .frame(height: 4)
                    }
                }
                
                Button(action: {
                    
                    self.index = 1
                    
                }) {
                    
                    VStack{
                        
                        Text("Top Headline")
                            .foregroundColor(.white)
                            .fontWeight(self.index == 1 ? .bold : .none)
                        
                        Capsule().fill(self.index == 1 ? Color.white : Color.clear)
                        .frame(height: 4)
                    }
                }
                
            }.padding(.bottom, 10)
            
            
        }.padding(.horizontal)
        .padding(.top, (UIApplication.shared.windows.first?.safeAreaInsets.top)! + 10)
        .background(Color("Color"))
    }
}

struct NewsFeed : View {
    
    @Binding var show : Bool
    var body : some View{
            NF()
        
    }
}


struct TopHeadline : View {
    @Binding var show : Bool
    var body : some View{
        
        TH()
    }
}

class Host : UIHostingController<ContentView>{
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        
        return .lightContent
    }
}



//News feed

struct dataType : Identifiable {
    var id: String
    var title: String
    var desc: String
    var url: String
    var image: String
}

//source is newsfeed
class getData: ObservableObject {
    @Published var datas = [dataType]()
    
    init() {
        let source="https://newsapi.org/v2/everything?apiKey=a2982a0eb8d24333b28a725c4bf8102e&q=india&page=1&pageSize=20";
        let url = URL(string: source)!
        let session = URLSession (configuration: .default)
        
        session.dataTask(with: url){(data, _, err) in
            if err != nil{
                print((err?.localizedDescription)!)
                return
            }
            let json = try! JSON(data: data!)
            for i in json["articles"]{
                let title = i.1["title"].stringValue
                let description = i.1["description"].stringValue
                let url = i.1["url"].stringValue
                let image = i.1["urlToImage"].stringValue
                let id = i.1["publishedAt"].stringValue
                
                
                DispatchQueue.main.async {
                    self.datas.append(dataType(id: id, title: title, desc: description, url: url, image: image))
                }
            }
        }.resume()
    }
}

//source is Top Headlines
class getData2: ObservableObject {
    @Published var datas = [dataType]()
    
    init() {
        let source="https://newsapi.org/v2/top-headlines?country=in&apiKey=a2982a0eb8d24333b28a725c4bf8102e&page=1&pageSize=20";
        let url = URL(string: source)!
        let session = URLSession (configuration: .default)
        
        session.dataTask(with: url){(data, _, err) in
            if err != nil{
                print((err?.localizedDescription)!)
                return
            }
            let json = try! JSON(data: data!)
            for i in json["articles"]{
                let title = i.1["title"].stringValue
                let description = i.1["description"].stringValue
                let url = i.1["url"].stringValue
                let image = i.1["urlToImage"].stringValue
                let id = i.1["publishedAt"].stringValue
                
                
                DispatchQueue.main.async {
                    self.datas.append(dataType(id: id, title: title, desc: description, url: url, image: image))
                }
            }
        }.resume()
    }
}
 
//Implementing WebView
struct webView : UIViewRepresentable {
    
    var url : String
    func makeUIView(context: UIViewRepresentableContext<webView>) -> WKWebView{
        let view = WKWebView()
        view.load(URLRequest(url: URL(string: url)!))
        return view
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
}

//News Feed function
struct NF: View {
   @ObservedObject var list = getData()
    var body: some View {
        NavigationView{
            List(list.datas){i in
                NavigationLink(destination: webView(url: i.url)
                    .navigationBarTitle("",displayMode: .inline)){
                        HStack(spacing: 25){
                            VStack(alignment: .leading, spacing: 10){
                                Text(i.title).fontWeight(.heavy)
                                Text(i.desc).lineLimit(2)
                            }
                            
                            if i.image != ""{
                                WebImage(url: URL(string: i.image), options: .highPriority, context: nil).resizable().frame(width: 110, height: 135).cornerRadius(20)
                            }
                        }.padding(.vertical,15)
                    }
                    .navigationBarTitle("")
            }

        }
    }
}

//Top Heading function
struct TH: View {
   @ObservedObject var list = getData2()
    var body: some View {
        NavigationView{
            List(list.datas){i in
                NavigationLink(destination: webView(url: i.url)
                    .navigationBarTitle("",displayMode: .inline)){
                        HStack(spacing: 15){
                            VStack(alignment: .leading, spacing: 10){
                                Text(i.title).fontWeight(.heavy)
                                Text(i.desc).lineLimit(2)
                            }
                            
                            if i.image != ""{
                                WebImage(url: URL(string: i.image), options: .highPriority, context: nil).resizable().frame(width: 110, height: 135).cornerRadius(20)
                            }
                        }.padding(.vertical,15)
                    }
                    .navigationBarTitle("")
            }

        }
    }
}

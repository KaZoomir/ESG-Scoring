//
//  ContactView.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.03.06.
//

import SwiftUI

struct ContactView: View{
    var body: some View{
        ScrollView{
            VStack(alignment: .leading, spacing: 0){
                
                Text("Get in touch")
                    .font(.system(size:30, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 10)
                    .padding(.top, 8)
                
                Spacer().frame(height: 16)
                
                // Email
                ContactItem(icon: "envelope.fill", title: "Email", content: "scoringesg@gmail.com")
                Divider().frame(height:2).overlay(Color(.systemGray4))
                
                ContactItem(icon:"phone.fill", title: "Phone", content: "8(705)808-61-96")
                Divider().frame(height: 2).overlay(Color(.systemGray4))
                
                ContactItem(icon: "Location.fill", title: "Location", content: "Tole Bi 59")
                
                Spacer().frame(height: 16)
                
                Button{
                    if let url = URL(string: "tel:8(705)808-61-96"){
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Call us now")
                        .font(.system(size:20, weight: .light))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.primaryGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                
                Button{
                    let subject = "Inquiry about ESG Scoring"
                    let urlString = "mailto:scoringesg@gmail.com?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                    if let url = URL(string: urlString){
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Send us an Email")
                        .font(.system(size: 20, weight: .light))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.primaryGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .padding(.horizontal, 16)
            }
        }
        .navigationTitle("Contact us")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ContactItem: View{
    let icon: String
    let title: String
    let content: String
    
    var body: some View{
        VStack(alignment:.leading, spacing: 4){
            HStack(spacing: 8){
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(Color.primaryGreen)
                    .frame(width: 24, height: 24)
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.primaryGreen)
            }
            Text(content)
                .font(.system(size: 15))
                .foregroundStyle(.black)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
    }
}

#Preview{
    ContentView()
}

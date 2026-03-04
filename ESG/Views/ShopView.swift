//
//  ShopView.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.03.03.
//

import SwiftUI

struct ShopView: View {
    @StateObject private var viewModel = ShopViewModel()
    @State private var showTypeMenu = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {

                    // MARK: - Header
                    VStack(spacing: 4) {
                        Text("Shop")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundStyle(.black)

                        Text("Your Points: \(viewModel.userPoints)")
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 16)

                    // MARK: - Type Dropdown
                    Menu {
                        ForEach(viewModel.availableTypes, id: \.self) { type in
                            Button {
                                viewModel.setSelectedType(type)
                            } label: {
                                HStack {
                                    Text(type)
                                        .foregroundStyle(viewModel.selectedType == type ? Color.primaryGreen : .black)
                                    if viewModel.selectedType == type {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(Color.primaryGreen)
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.selectedType)
                                .font(.system(size: 20))
                                .foregroundStyle(.black)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.gray)
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.primaryGreen, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 16)

                    Spacer().frame(height: 24)

                    // MARK: - Items list
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else if viewModel.filteredItems.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "bag")
                                .font(.system(size: 48))
                                .foregroundStyle(Color(.systemGray3))
                            Text("No items available")
                                .foregroundStyle(.gray)
                        }
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.filteredItems) { item in
                                    ShopItemCard(
                                        item: item,
                                        userPoints: viewModel.userPoints,
                                        onBuy: { viewModel.purchaseItem(item) }
                                    )
                                }
                                Color.clear.frame(height: 80)
                            }
                            .padding(.horizontal, 16)
                        }
                        .refreshable { viewModel.refresh() }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .overlay(alignment: .bottom) {
            if let toast = viewModel.toast {
                Text(toast)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule().fill(toast.hasPrefix("✅") ? Color.primaryGreen : Color.red.opacity(0.85))
                    )
                    .padding(.bottom, 100)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation { viewModel.toast = nil }
                        }
                    }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.toast)
    }
}

struct ShopItemCard: View{
    let item: ShopItem
    let userPoints: Int
    let onBuy: () -> Void
    
    var canAfford: Bool {userPoints >= item.price}
    
    var body: some View{
        HStack(alignment: .top, spacing: 0){
            Image("event_picture")
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 112)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Spacer().frame(width: 28)
            
            VStack(alignment: .leading, spacing: 0){
                
                Spacer(minLength: 0)
                
                Text(item.name)
                    .font(.system(size:20, weight: .semibold))
                    .foregroundStyle(.black)
                    .lineLimit(2)
                
                Spacer().frame(height: 4)
                // Description
                Text(item.description)
                    .font(.system(size:13))
                    .foregroundStyle(.gray)
                    .lineLimit(3)
                
                Spacer(minLength: 0)
                
                //Buy Button + price
                HStack(spacing: 12){
                    ZStack{
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primaryGreen, lineWidth: 1)
                        Text("\(item.price) pts")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(canAfford ? Color.primaryGreen: Color(.systemGray3))
                            .clipShape(RoundedRectangle(cornerRadius:12))
                    }
                    .disabled(!canAfford)
                }
            }
            .frame(height: 112)
        }
        .padding(32)
        .background(Color(hex: "F2F2F2"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
    }
}

#Preview{
    ShopView()
}

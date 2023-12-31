//
//  WeekReviewRecipeThumbnail.swift
//  Food@Home
//
//  Created by Derek Howes on 1/5/24.
//

import SwiftUI

struct WeekReviewRecipeThumbnail: View {
    var meal: RecipeCD
    @Binding var path: NavigationPath
    
    var body: some View {
        HStack {
            Button(action: {
                path.append(Recipe(id: Int(meal.apiID), title: meal.name ?? "Unknown", image: meal.imageURL ?? "Unknown"))
            }, label: {
                HStack {
                    AsyncImage(
                        url: URL(string: meal.imageURL ?? "Unknown"),
                        content: { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 65, height: 65)
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 16.0)
                                )
                        },
                        placeholder: {
                            ProgressView()
                                .frame(width: 65, height: 65)
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 16.0)
                                )
                                .background(customGrey)
                        }
                    )
                    
                    VStack (alignment: .leading) {
                        Text(meal.name ?? "Unknown")
                            .font(.customSystem(size: 16, weight: .regular))
                        Text(meal.mealTime ?? "Unknown")
                            .foregroundStyle(darkGrey)
                            .font(.customSystem(size: 12, weight: .semibold))
                        
                        Spacer()
                    }
                }
                .frame(height: 65)
                .padding(.bottom, 16)
            })
            .buttonStyle(.plain)
        }
    }
}


//#Preview {
//    struct PreviewWrapper: View {
//        @FetchRequest(sortDescriptors: []) var meals: FetchedResults<RecipeCD>
//        var body: some View {
//            WeekReviewRecipeThumbnail(meal: meals.first,
//                                      path: Binding.constant(NavigationPath()))
//        }
//    }
//    return PreviewWrapper()
//}

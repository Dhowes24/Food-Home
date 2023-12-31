//
//  MealScheduler.swift
//  Food@Home
//
//  Created by Derek Howes on 12/1/23.
//

import SwiftUI

struct MealScheduler: View {
    @Environment(\.dismiss) var dismiss
    var selectedDate: Date
    @State private var timeSelectors: [timeSelectorObject] = []
    var recipe: Recipe
    
    @Binding var path: NavigationPath
    @Environment(\.managedObjectContext) var moc
    
    @State var dragAmount: CGSize = CGSize.zero
    
    var body: some View {
        
        GeometryReader { geo in
            VStack{
                VStack {
                    HStack {
                        Image(systemName: "arrow.backward")
                            .frame(width: 24, height: 24)
                            .onTapGesture {
                                dismiss()
                            }
                        Spacer()
                        
                        Text("Schedule Meal")
                            .font(.customSystem(size: 18, weight: .heavy))
                            .frame(width: 245, height: 24)
                        
                        Spacer()
                        
                        Rectangle()
                            .fill(.clear)
                            .frame(width: 24, height: 24)
                    }
                    .padding(.top, 31)
                    .padding(.bottom, 13)
                    
                }
                .padding(.horizontal, 17)
                
                SeparatorLine()
                
                VStack {
                    Text("Select the meal times you'd like to schedule your meal for.")
                        .font(.customSystem(size: 16, weight: .regular))
                        .padding(.vertical, 24)
                    
                    SeparatorLine()
                        .padding(.bottom, 25)
                    
                    ScrollView(.vertical) {
                        ForEach($timeSelectors) { selector in
                            
                            ZStack{
                                Group {
                                    TimeSelector(timeSelectorObject: selector)
                                    VStack {
                                        TrashLabel(offset: geo.size)
                                            .padding(.top, 10)
                                        Spacer()
                                    }
                                }
                                .modifier(timeSelectorViewModifier(
                                    deleteItem: deleteTimeSelector,
                                    isFirst: timeSelectors.first == selector.wrappedValue
                                    ,selectorReference: selector.wrappedValue)
                                )
                            }
                        }
                        Button("Click to add another meal time") {
                            timeSelectors.append(timeSelectorObject(date: selectedDate))
                        }
                    }
                }
                .padding(.horizontal, 17)
                
                Spacer()
                
                SeparatorLine()
                
                Button(action: {
                    
                    timeSelectors.forEach { daySelected in
                        daySelected.mealTimes.forEach { (time: String, selected: Bool) in
                            if selected {
                                let recipeCD = RecipeCD(context: moc)
                                recipeCD.apiID = Int32(recipe.id)
                                recipeCD.dateAssigned = daySelected.date
                                recipeCD.imageURL = recipe.image
                                recipeCD.mealTime = time
                                recipeCD.name = recipe.title
                                
                                try? moc.save()
                            }
                        }
                    }
                    
                    path = NavigationPath()
                }, label: {
                    Text("Done")
                        .button(color: "black")
                })
                .buttonStyle(.plain)
                .disabled(noTimesSelected())
                
            }
            .onAppear {
                self.timeSelectors.append(timeSelectorObject(date: selectedDate))
            }
        }
    }
    
    func noTimesSelected() -> Bool {
        var returnValue = false
        timeSelectors.forEach { timeSelectorObject in
            if !timeSelectorObject.mealTimes.values.contains(true) {
                returnValue = true
            }
        }
        return returnValue
    }
    
    func deleteTimeSelector(selector: timeSelectorObject) {
        timeSelectors.removeAll { toRemove in
            toRemove == selector
        }
    }
}

#Preview {
    MealScheduler(selectedDate: Date(), recipe: Recipe(id: 1, title: "Recipe Name", image: ""), path: Binding.constant(NavigationPath()))
    
}

struct timeSelectorViewModifier: ViewModifier {
    var deleteItem: ((timeSelectorObject) -> Void)?
    @State var drag: CGSize = CGSize.zero
    var isFirst: Bool
    var selectorReference: timeSelectorObject
    
    func body(content: Content) -> some View {
        if isFirst {
            content
        } else {
            content
                .offset(x: drag.width, y: 0)
                .simultaneousGesture(
                    DragGesture()
                        .onChanged({
                            if $0.translation.width < 0 {
                                drag = abs($0.translation.width) > 55 ?
                                CGSize(width: -55, height: 0) :
                                $0.translation
                            }
                        })
                        .onEnded({ _ in
                            withAnimation(Animation.linear(duration: 0.3)) {
                                if drag.width <= -55 {
                                    if let deleteItem = deleteItem {
                                        deleteItem(selectorReference)
                                    }
                                }
                                drag = .zero
                            }
                        })
                )
        }
    }
}

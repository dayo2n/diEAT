//
//  CustomDatePicker.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/07.
//

import SwiftUI

struct CustomDatePicker: View {
    
    var today: Date = Date()
    @Binding var currentDate: Date
    @Binding var selectedDate: Date
    
    // Month update on arrow button clicks
    @State var currentMonth: Int = 0
    @Environment(\.colorScheme) var scheme
    
    @ObservedObject var viewModel: FetchPostViewModel
    
    // Days
    let days: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    // Months
    let months: [String : String] = ["January": "01", "February": "02", "March": "03",
                                     "April": "04", "May": "05", "June": "06",
                                     "July": "07", "August": "08", "September": "09",
                                     "October": "10", "November": "11", "December": "12"]
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(extraDate()[0])
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Text(extraDate()[1])
                        .font(.title.bold())
                }
                
                // go to today
                Button(action: {
                    selectedDate = Date()
                    viewModel.fetchPost(selectedDate: selectedDate)
                    currentMonth = 0
                }) {
                    Text("TODAY")
                        .font(.system(size: 15, weight: .semibold, design: .monospaced))
                        .padding(.all, 10)
                        .foregroundColor(Theme.textColor(scheme))
                        .border(Theme.defaultColor(scheme), width: 0.7)
                }
                
                Spacer(minLength: 0)
                
                Button(action: {
                    withAnimation { currentMonth -= 1 }
                }, label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                })
                
                Button(action: {
                    withAnimation { currentMonth += 1 }
                }, label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                })
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            // Day View
            HStack() {
                ForEach(days, id: \.self) {day in
                    Text(day)
                        .font(.system(size: 15, weight: .semibold, design: .monospaced))
                        .frame(maxWidth: .infinity) // 자동 간격 최대
                }
            }
            // Dates
            // Lazy Grid
            let columns = Array(repeating: GridItem() , count: 7)
            
            LazyVGrid(columns: columns) {
                ForEach(extractDate()) { value in
                    ZStack {
                        if value.date == selectedDate {
                            Circle()
                                .frame(height: 35)
                        }
                        
                        if Date2OnlyDate(date: UTC2KST(date: value.date)) == Date2OnlyDate(date: UTC2KST(date: today)) && value.day != -1 {
                            Circle()
                                .frame(height: 35)
                                .foregroundColor(.gray)
                        }
                        
                        CardView(value: value)
                            .frame(height: 35)
                            .onTapGesture {
                                selectedDate = value.date
                                viewModel.fetchPost(selectedDate: selectedDate)
                            }
                            .foregroundColor(value.date == selectedDate ? Theme.bgColor(scheme) : Theme.textColor(scheme))
                    }
                }
            }
        }
        .onChange(of: currentMonth) { newValue in
            // updating Month
            currentDate = getCurrentMonth()
        }
    }
    
    @ViewBuilder
    func CardView(value: DateValue) -> some View {
        HStack {
            if value.day != -1 {
                Text("\(value.day)")
                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                    .padding(10)
            }
        }
    }
    
    // extraction Year and Month for display
    func extraDate() -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY MMMM"
        
        let date = formatter.string(from: currentDate)
        
        return date.components(separatedBy: " ")
        // extraDate()[0]이면 "YYYY"년
        // extraDate()[1]이면 "MMMM"월
    }
    
    func getCurrentMonth() -> Date {
        let calendar = Calendar.current
        
        // Getting current month date
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else { return Date() }
        return currentMonth
    }
    
    func extractDate() -> [DateValue] {
        
        let calendar = Calendar.current
        
        //Getting Current Month Date
        let currentMonth = getCurrentMonth()
        
        var days = currentMonth.getAllDates().compactMap { date ->
            DateValue in
            
            //getting day
            let day = calendar.component(.day, from: date)
            return DateValue(day: day, date: date)
        }
        
        // adding offset dys to get exact week day
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
        
        for _ in (0..<(firstWeekday - 1)) {
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        return days
    }
}

// Extending Date to get Current Month Dates
extension Date {
    func getAllDates() -> [Date] {
        let calendar = Calendar.current
        
        // getting start date
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
        
        let range = calendar.range(of: .day, in: .month, for: self)!
        
        // getting date
        return range.compactMap { day -> Date in
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
}


struct DateValue: Identifiable {
    var id = UUID().uuidString
    var day: Int
    var date: Date
}

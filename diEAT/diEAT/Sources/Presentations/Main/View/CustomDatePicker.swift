//
//  CustomDatePicker.swift
//  diEAT
//
//  Created by 문다 on 2022/10/07.
//

import SwiftUI

struct CustomDatePicker: View {
    
    let today = Date()
    @Binding var currentDate: Date
    @Binding var selectedDate: Date
    @Binding var viewType: ViewType
    
    // Month update on arrow button clicks
    @State var currentMonth = 0
    @Environment(\.colorScheme) var scheme
    
    @ObservedObject var viewModel: FetchPostViewModel
    
    // Days
 
    var body: some View {
        VStack(spacing: 5) {
            HStack(spacing: 2) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(extraDate()[0])
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Text(extraDate()[1])
                        .font(.title.bold())
                }
                .padding(.top, 5)
                
                
                Spacer(minLength: 0)
                
                Button {
                    currentMonth -= 1
                } label: {
                    Image(systemName: String.chevronLeft)
                        .font(.headline)
                }
                .buttonStyle(BorderedButtonStyle())
                
                Button {
                    selectedDate = today
                    currentMonth = 0
                } label: {
                    Text(String.today)
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                }
                .buttonStyle(BorderedButtonStyle())
                
                Button {
                    currentMonth += 1
                } label: {
                    Image(systemName: String.chevronRight)
                        .font(.headline)
                }
                .buttonStyle(BorderedButtonStyle())
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 8)
            
            if viewType == .day {
                // Day View
                HStack() {
                    ForEach(0..<String.days.count, id: \.self) { index in
                        Text(String.days[index])
                            .font(.system(size: 15, weight: .semibold, design: .monospaced))
                            .frame(maxWidth: .infinity) // 자동 간격 최대
                            .foregroundColor(index % 7 == 6 ? Theme.saturdayTextColor : (index % 7 == 0 ? Theme.sundayTextColor : Theme.textColor(scheme)))
                    }
                }
                // Dates
                // Lazy Grid
                let columns = Array(repeating: GridItem() , count: 7)
                let extractedDate = extractDate()
                
                LazyVGrid(columns: columns) {
                    ForEach(
                        Array(extractedDate.enumerated()),
                        id: \.element
                    ) { index, value in
                        
                        let valueDate = value.date.utc2kst.date2OnlyDate
                        
                        ZStack {
                            if value.day != -1 {
                                if valueDate == selectedDate.utc2kst.date2OnlyDate {
                                    Circle()
                                        .frame(height: 35)
                                        .foregroundStyle(Color.accentColor)
                                } else if valueDate == today.utc2kst.date2OnlyDate {
                                    Circle()
                                        .frame(height: 35)
                                        .foregroundColor(.gray)
                                } else if viewModel.postedDates.contains(valueDate) {
                                    Circle()
                                        .frame(height: 5)
                                        .foregroundStyle(Color.accentColor)
                                        .offset(y: 15)
                                }
                            }
                            CardView(value: value)
                                .frame(height: 35)
                                .onTapGesture {
                                    selectedDate = value.date
                                }
                                .foregroundColor((value.date == selectedDate ? Theme.bgColor(scheme) : Theme.textColor(scheme)))
                        }
                    }
                }
            }
        }
        .onChange(of: currentMonth) { newValue in
            currentDate = getCurrentMonth()
            viewModel.fetchPostByMonth(selectedDate: currentDate)
        }
        .onChange(of: selectedDate) { _ in
            viewModel.fetchPostByDate(selectedDate: selectedDate)
        }
        
        .gesture(
            DragGesture(
                minimumDistance: 10,
                coordinateSpace: .local
            )
            .onEnded { value in
                currentMonth += value.translation.width < 0 ? 1 : -1
            }
        )
    }
    
    @ViewBuilder
    func CardView(value: DateValue) -> some View {
        if value.day != -1 {
            Text(value.day.description)
                .font(.system(size: 14, weight: .regular, design: .monospaced))
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
        guard let currentMonth = calendar.date(
            byAdding: .month,
            value: self.currentMonth,
            to: Date()
        ) else { return Date() }
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
        let startDate = calendar.date(
            from: Calendar.current.dateComponents(
                [.year, .month],
                from: self
            )
        )!
        
        let range = calendar.range(of: .day, in: .month, for: self)!
        
        // getting date
        return range.compactMap { day -> Date in
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
}

struct DateValue: Identifiable, Hashable {
    var id = UUID().uuidString
    var day: Int
    var date: Date
}

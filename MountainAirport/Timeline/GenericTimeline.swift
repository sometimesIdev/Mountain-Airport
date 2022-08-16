

import SwiftUI

struct GenericTimeline<Content, T>: View where Content: View {
	var events: [T]
	let content: (T) -> Content
	let timeProperty: KeyPath<T, Date>

	init(
	  events: [T],
	  timeProperty: KeyPath<T, Date>,
	  @ViewBuilder content: @escaping (T) -> Content
	) {
	  self.events = events
	  self.content = content
	  self.timeProperty = timeProperty
	}
	var earliestHour: Int {
	  let flightsAscending = events.sorted {
		 $0[keyPath: timeProperty] < $1[keyPath: timeProperty]
	  }

	  guard let firstFlight = flightsAscending.first else {
		 return 0
	  }
	  let hour = Calendar.current.component(
		 .hour,
		 from: firstFlight[keyPath: timeProperty]
	  )
	  return hour
	}

	var latestHour: Int {
	  let flightsAscending = events.sorted {
		 $0[keyPath: timeProperty] > $1[keyPath: timeProperty]
	  }

	  guard let firstFlight = flightsAscending.first else {
		 return 24
	  }
	  let hour = Calendar.current.component(
		 .hour,
		 from: firstFlight[keyPath: timeProperty]
	  )
	  return hour + 1
	}

	func eventsInHour(_ hour: Int) -> [T] {
	  let filteredEvents = events
		 .filter {
			let flightHour =
			  Calendar.current.component(
				 .hour,
				 from: $0[keyPath: timeProperty]
			  )
			let match = flightHour == hour
			return match
		 }
	  return filteredEvents
	}

	func hourString(_ hour: Int) -> String {
	  let tcmp = DateComponents(hour: hour)
	  if let time = Calendar.current.date(from: tcmp) {
		 return shortTimeFormatter.string(from: time)
	  }
	  return "Unknown"
	}

	var body: some View {
	  ScrollView {
		 VStack(alignment: .leading) {
			// 1
			ForEach(earliestHour..<latestHour) { hour in
			  // 2
			  let hourFlights = eventsInHour(hour)
			  // 3
			  Text(hourString(hour))
				 .font(.title2)
			  // 4
			  ForEach(hourFlights.indices) { index in
				 self.content(hourFlights[index])
			  }
			}
		 }
	  }
	}
 }

 struct GenericTimeline_Previews: PreviewProvider {
	static var previews: some View {
	  GenericTimeline(
		 events: FlightData.generateTestFlights(
			date: Date()
		 ),
		 timeProperty: \.localTime
	  ) { flight in
		 FlightCardView(flight: flight)
	  }
	}
 }

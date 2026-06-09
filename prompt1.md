		for _, r := range ageRanges {
			switch r {
			case "<16":
				ageQuery = ageQuery.Or(`events.min_age < ?`, 16)
			case "16-20":
				ageQuery = ageQuery.Or(`(events.max_age >= ? OR events.max_age >= ?) AND (events.min_age <= ? OR events.min_age <= ?) OR (events.min_age <= ? AND events.max_age = 0)`, 16, 20, 16, 20, 16)
			case "21-30":
				ageQuery = ageQuery.Or(`(events.max_age >= ? OR events.max_age >= ?) AND (events.min_age <= ? OR events.min_age <= ?) OR (events.min_age <= ? AND events.max_age = 0)`, 21, 30, 21, 30, 21)
			case "31-45":
				ageQuery = ageQuery.Or(`(events.max_age >= ? OR events.max_age >= ?) AND (events.min_age <= ? OR events.min_age <= ?) OR (events.min_age <= ? AND events.max_age = 0)`, 31, 45, 31, 45, 31)
			case ">45":
				ageQuery = ageQuery.Or(`events.max_age > ? OR events.max_age = 0`, 45)
			}
		}
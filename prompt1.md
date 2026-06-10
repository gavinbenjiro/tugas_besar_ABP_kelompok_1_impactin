# my api context for u to understand

## age range

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

## api
- http://localhost:8080/api/user/events?age=16-20&age=21-30
{
    "data": [
        {
            "event_id": 2,
            "title": "Public Speaking Bootcamp",
            "category": "Education",
            "cover_image": "https://res.cloudinary.com/dscz9j9ui/image/upload/v1780921253/ebwmrlhhkwihlsz4vaci.jpg",
            "start_date": "2026-07-15T07:00:00+07:00",
            "location": "Bandung, Indonesia",
            "host_name": "tes"
        },
        {
            "event_id": 3,
            "title": "Teaching Volunteer Program",
            "category": "Education",
            "cover_image": "https://res.cloudinary.com/dscz9j9ui/image/upload/v1780921253/ebwmrlhhkwihlsz4vaci.jpg",
            "start_date": "2026-07-20T07:00:00+07:00",
            "location": "Yogyakarta, Indonesia",
            "host_name": "tes"
        },
        {
            "event_id": 4,
            "title": "Community Clean Up Day",
            "category": "Community",
            "cover_image": "https://res.cloudinary.com/dscz9j9ui/image/upload/v1780921253/ebwmrlhhkwihlsz4vaci.jpg",
            "start_date": "2026-07-08T07:00:00+07:00",
            "location": "Surabaya, Indonesia",
            "host_name": "tes"
        },
        {
            "event_id": 5,
            "title": "Youth Leadership Camp",
            "category": "Community",
            "cover_image": "https://res.cloudinary.com/dscz9j9ui/image/upload/v1780921253/ebwmrlhhkwihlsz4vaci.jpg",
            "start_date": "2026-07-18T07:00:00+07:00",
            "location": "Bogor, Indonesia",
            "host_name": "tes"
        },
        {
            "event_id": 6,
            "title": "Local Culture Festival",
            "category": "Community",
            "cover_image": "https://res.cloudinary.com/dscz9j9ui/image/upload/v1780921253/ebwmrlhhkwihlsz4vaci.jpg",
            "start_date": "2026-07-25T07:00:00+07:00",
            "location": "Solo, Indonesia",
            "host_name": "tes"
        },
        {
            "event_id": 7,
            "title": "Blood Donation Campaign",
            "category": "Health",
            "cover_image": "https://res.cloudinary.com/dscz9j9ui/image/upload/v1780921253/ebwmrlhhkwihlsz4vaci.jpg",
            "start_date": "2026-07-09T07:00:00+07:00",
            "location": "Jakarta, Indonesia",
            "host_name": "tes"
        },
        {
            "event_id": 9,
            "title": "Healthy Lifestyle Workshop",
            "category": "Health",
            "cover_image": "https://res.cloudinary.com/dscz9j9ui/image/upload/v1780921253/ebwmrlhhkwihlsz4vaci.jpg",
            "start_date": "2026-07-28T07:00:00+07:00",
            "location": "Semarang, Indonesia",
            "host_name": "tes"
        },

- http://localhost:8080/api/user/events?search=ca
{
    "data": [
        {
            "event_id": 2,
            "title": "Public Speaking Bootcamp",
            "category": "Education",
            "cover_image": "https://res.cloudinary.com/dscz9j9ui/image/upload/v1780921253/ebwmrlhhkwihlsz4vaci.jpg",
            "start_date": "2026-07-15T07:00:00+07:00",
            "location": "Bandung, Indonesia",
            "host_name": "tes"
        },
        {
            "event_id": 3,
            "title": "Teaching Volunteer Program",
            "category": "Education",
            "cover_image": "https://res.cloudinary.com/dscz9j9ui/image/upload/v1780921253/ebwmrlhhkwihlsz4vaci.jpg",
            "start_date": "2026-07-20T07:00:00+07:00",
            "location": "Yogyakarta, Indonesia",
            "host_name": "tes"
        },
        {
            "event_id": 5,
            "title": "Youth Leadership Camp",
            "category": "Community",
            "cover_image": "https://res.cloudinary.com/dscz9j9ui/image/upload/v1780921253/ebwmrlhhkwihlsz4vaci.jpg",
            "start_date": "2026-07-18T07:00:00+07:00",
            "location": "Bogor, Indonesia",
            "host_name": "tes"
        },
        {
            "event_id": 6,
            "title": "Local Culture Festival",
            "category": "Community",
            "cover_image": "https://res.cloudinary.com/dscz9j9ui/image/upload/v1780921253/ebwmrlhhkwihlsz4vaci.jpg",
            "start_date": "2026-07-25T07:00:00+07:00",
            "location": "Solo, Indonesia",
            "host_name": "tes"
        },
        {
            "event_id": 7,
            "title": "Blood Donation Campaign",
            "category": "Health",
            "cover_image": "https://res.cloudinary.com/dscz9j9ui/image/upload/v1780921253/ebwmrlhhkwihlsz4vaci.jpg",
            "start_date": "2026-07-09T07:00:00+07:00",
            "location": "Jakarta, Indonesia",
            "host_name": "tes"
        },
        {
            "event_id": 13,
            "title": "Career Development Workshop",
            "category": "Education",
            "cover_image": "https://res.cloudinary.com/dscz9j9ui/image/upload/v1780921253/ebwmrlhhkwihlsz4vaci.jpg",
            "start_date": "2026-08-05T07:00:00+07:00",
            "location": "Bandung, Indonesia",
            "host_name": "tes"
        },
        {
            "event_id": 21,
            "title": "tez2",
            "category": "Education",
            "cover_image": "hwuja",
            "start_date": "2026-06-09T07:00:00+07:00",
            "location": "uushsjsj",
            "host_name": "Gavin Benjiro Ramadhan"
        }
    ],
    "message": "events retrieved"
}


## some codes
- controller
func (c *EventController) GetAllEvents(ctx *gin.Context) {
	category := ctx.Query("category")
	search := ctx.Query("search")
	ageRanges := ctx.QueryArray("age")

	resp, err := c.eventService.GetAllEvents(category, search, ageRanges)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{
			"error": err.Error(),
		})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"message": "events retrieved",
		"data":    resp,
	})
}

- repository
func (r *eventRepository) GetAllEvents(category, search string, ageRanges []string) ([]response.EventListResponseDto, error) {
	var events []response.EventListResponseDto

	query := r.db.Table("events").
		Select(`
			events.id AS event_id,
			events.title,
			events.category,
			events.cover_image,
			events.start_date,
			events.location,
			profiles.name AS host_name
		`).
		Joins("JOIN profiles ON profiles.user_id = events.user_id").
		Where("events.status = ?", "approved").
		Where("events.sub_status IN ?", []string{"opened", "closed"})

	if category != "" {
		query = query.Where("LOWER(events.category) = LOWER(?)", category)
	}

	if search != "" {
		keyword := "%" + strings.ToLower(search) + "%"
		query = query.Where(`
		(
			LOWER(events.title) LIKE ? OR
			LOWER(events.category) LIKE ? OR
			LOWER(events.location) LIKE ? OR
			LOWER(profiles.name) LIKE ?
		)
		`, keyword, keyword, keyword, keyword)
	}

	if len(ageRanges) > 0 {
		ageQuery := r.db.Where("events.min_age = 0 AND events.max_age = 0")

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
		query = query.Where(ageQuery)
	}

	err := query.Order("events.id ASC").Scan(&events).Error

	return events, err
}
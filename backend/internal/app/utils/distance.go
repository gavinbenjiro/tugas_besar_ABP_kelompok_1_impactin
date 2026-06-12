package utils

import "math"

func CalculateDistanceKM(
	lat1, lon1,
	lat2, lon2 float64,
) float64 {

	const earthRadius = 6371.0 // KM

	dLat := degreesToRadians(lat2 - lat1)
	dLon := degreesToRadians(lon2 - lon1)

	a :=
		math.Sin(dLat/2)*math.Sin(dLat/2) +
			math.Cos(degreesToRadians(lat1))*
				math.Cos(degreesToRadians(lat2))*
				math.Sin(dLon/2)*math.Sin(dLon/2)

	c := 2 * math.Atan2(
		math.Sqrt(a),
		math.Sqrt(1-a),
	)

	return earthRadius * c
}

func degreesToRadians(deg float64) float64 {
	return deg * math.Pi / 180
}

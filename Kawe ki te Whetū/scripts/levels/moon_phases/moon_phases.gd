extends Node3D

enum MoonPhases {
	NEW_MOON,
	WAXING_CRESCENT,
	FIRST_QUARTER,
	WAXING_GIBBOUS,
	FULL_MOON,
	WANING_GIBBOUS,
	LAST_QUARTER,
	WANING_CRESCENT
}

const QUESTION_FORMAT := "Q : %s"

const QA_KEY := {
	1 : {
		"question" : "Which Moon phase is almost invisible from Earth and marks the beginning of many maramataka lunar months?",
		"ans" : MoonPhases.NEW_MOON
	},
	2 : {
		"question" : "Which Moon phase occurs when the Moon's sunlit side faces mostly away from Earth?",
		"ans" : MoonPhases.NEW_MOON
	},
	3 : {
		"question" : "Which phase appears as a thin, growing sliver of light after the New Moon?",
		"ans" : MoonPhases.WAXING_CRESCENT
	},
	4 : {
		"question" : "Which Moon phase is beginning to brighten as the lunar month progresses?",
		"ans" : MoonPhases.WAXING_CRESCENT
	},
	5 : {
		"question" : "Which phase shows approximately half of the Moon illuminated as it grows brighter?",
		"ans" : MoonPhases.FIRST_QUARTER
	},
	6 : {
		"question" : "Which phase comes after the Waxing Crescent and before the Waxing Gibbous?",
		"ans" : MoonPhases.FIRST_QUARTER
	},
	7 : {
		"question" : "Which phase has more than half of its visible surface illuminated and is still growing?",
		"ans" : MoonPhases.WAXING_GIBBOUS
	},
	8 : {
		"question" : "Which phase appears just before the Full Moon as the bright area continues to increase?",
		"ans" : MoonPhases.WAXING_GIBBOUS
	},
	9 : {
		"question" : "Which phase shows the Moon's Earth-facing side almost completely illuminated?",
		"ans" : MoonPhases.FULL_MOON
	},
	10 : {
		"question" : "Which phase is associated with Rākaunui, a traditional Māori name for the Full Moon?",
		"ans" : MoonPhases.FULL_MOON
	},
	11 : {
		"question" : "Which phase has more than half of its visible surface illuminated, but is beginning to shrink?",
		"ans" : MoonPhases.WANING_GIBBOUS
	},
	12 : {
		"question" : "Which phase follows the Full Moon as the illuminated area starts decreasing?",
		"ans" : MoonPhases.WANING_GIBBOUS
	},
	13 : {
		"question" : "Which phase shows approximately half of the Moon illuminated as it gets darker?",
		"ans" : MoonPhases.LAST_QUARTER
	},
	14 : {
		"question" : "Which phase occurs between the Waning Gibbous and Waning Crescent?",
		"ans" : MoonPhases.LAST_QUARTER
	},
	15 : {
		"question" : "Which phase appears as a thin, shrinking crescent before the next New Moon?",
		"ans" : MoonPhases.WANING_CRESCENT
	},
	16 : {
		"question" : "Which phase comes just before the Moon becomes almost invisible again?",
		"ans" : MoonPhases.WANING_CRESCENT
	}
}

var question_index := 0


func generate_random_question_order() -> Array:
	var order := []
	for i in range(1, 17, 2):
		order.append(i + (randi() % 2))
		
	order.shuffle()
	return order

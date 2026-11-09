RUNONCEPATH("Ryu_kos_lib/maneuvers.ks").
PRINT "Starting launch sequence...".

SET throttle_level TO 0.

WAIT 1 .
PRINT "Ignition in T-minus 30 seconds...".
WAIT 20 .
PRINT "Ignition in T-minus 10 seconds...".
WAIT 5 .
PRINT "Ignition in T-minus 5 seconds...".
WAIT 2 .
PRINT "Ignition in T-minus 3 seconds...".
WAIT 1 .
PRINT "Ignition in T-minus 2 seconds...".
WAIT 1 .
PRINT "Ignition in T-minus 1 second...".
WAIT 1 .

STAGE.
PRINT "Ignition!".
WAIT 0.5.

LOCK THROTTLE TO throttle_level.
SET throttle_level TO gentleThrottleUp(throttle_level, 0.2).
WAIT 1.

STAGE.
WAIT 0.1.
LOCAL start_solid_fuel IS STAGE:SOLIDFUEL.
PRINT "Liftoff!".
//WAIT 0.5.

LOCK STEERING TO HEADING(0, 90).
WAIT 0.5.
PRINT "Rolling...".
FROM { SET deg TO 90. } UNTIL deg <= 88 STEP { SET deg TO deg -1. } DO {
	LOCK STEERING TO HEADING(90, deg, 0).
	WAIT 0.1.
}
WAIT 6.
PRINT "Locking heading to surface prograde.".
adjustRoll().

PRINT "Standing by for using 95% of solid fuel...".
WAIT UNTIL STAGE:SOLIDFUEL <= (start_solid_fuel * 0.05).
PRINT "Throttle up!".
SET throttle_level TO gentleThrottleUp(throttle_level, 0.9).
adjustRoll().
WAIT UNTIL STAGE:SOLIDFUEL <= 0.
WAIT 0.5.
STAGE.
PRINT "Stage separated.".
adjustRoll().

WAIT 15.
PRINT "Throttle down to 80%...".
SET throttle_level TO gentleThrottleDown(throttle_level, throttle_level - 0.1).

WAIT 18.
PRINT "Throttle down to 70%...".
SET throttle_level TO gentleThrottleDown(throttle_level, throttle_level - 0.1).

WAIT 20.
PRINT "Throttle down to 60%...".
SET throttle_level TO gentleThrottleDown(throttle_level, throttle_level - 0.1).

WAIT 23.
PRINT "Throttle down to 50%...".
SET throttle_level TO gentleThrottleDown(throttle_level, throttle_level - 0.1).

WAIT 3.
PRINT "Setting heading to prograde.".
LOCK STEERING TO PROGRADE.

WAIT 4.

SET previous_ap TO SHIP:ORBIT:APOAPSIS.
SET target_ap TO 80 * 1000.
UNTIL getCurrentPitch() >= 1 {
	SET deg TO getCurrentPitch().
	SET adjust_angle TO getApAdjustAngle(target_ap, previous_ap) / 5.
	SET deg TO deg + adjust_angle.
	set previous_ap TO SHIP:ORBIT:APOAPSIS.
	LOCK STEERING TO HEADING(90, deg, 0).
	WAIT 0.2.
}

PRINT "Pitch down complete.".

SET throttle_level TO gentleThrottleUp(throttle_level, 0.8).

SET previous_ap TO SHIP:ORBIT:APOAPSIS.
UNTIL STAGE:LIQUIDFUEL <= 1 {
	SET deg TO getCurrentPitch().
	SET adjust_angle TO getApAdjustAngle(target_ap, previous_ap).
	SET deg TO deg + adjust_angle.
	set previous_ap TO SHIP:ORBIT:APOAPSIS.
	//PRINT previous_ap + " / " + adjust_angle.
	LOCK STEERING TO HEADING(90, deg, 0).
	WAIT 0.2.
}

PRINT "Preparing for stage separation...".
SET throttle_level TO gentleThrottleDown(throttle_level, 0.05).
STAGE.
PRINT "Lower stage separated.".
WAIT 3.

SET throttle_level TO gentleThrottleUp(throttle_level, 1.0).

SET previous_ap TO SHIP:ORBIT:APOAPSIS.
FROM { SET t TO 0. } UNTIL t >= 30 STEP { SET t TO t + 0.2. } DO {
	SET deg TO getCurrentPitch().
	SET adjust_angle TO getApAdjustAngle(target_ap, previous_ap).
	SET deg TO deg + adjust_angle.
	set previous_ap TO SHIP:ORBIT:APOAPSIS.
	//PRINT previous_ap + " / " + adjust_angle.
	LOCK STEERING TO HEADING(90, deg, 0).
	WAIT 0.2.
}

SET throttle_level TO gentleThrottleDown(throttle_level, 0.5).

SET previous_ap TO SHIP:ORBIT:APOAPSIS.
FROM { SET t TO 0. } UNTIL t >= 20 STEP { SET t TO t + 0.2. } DO {
	SET deg TO getCurrentPitch().
	SET adjust_angle TO getApAdjustAngle(target_ap, previous_ap).
	SET deg TO deg + adjust_angle.
	set previous_ap TO SHIP:ORBIT:APOAPSIS.
	LOCK STEERING TO HEADING(90, deg, 0).
	WAIT 0.2.
}

SET throttle_level TO gentleThrottleDown(throttle_level, 0.3).

SET previous_ap TO SHIP:ORBIT:APOAPSIS.
UNTIL SHIP:ORBIT:PERIAPSIS >= -100 * 1000 {
	SET deg TO getCurrentPitch().
	SET adjust_angle TO getApAdjustAngle(target_ap, previous_ap).
	SET deg TO deg + adjust_angle.
	set previous_ap TO SHIP:ORBIT:APOAPSIS.
	LOCK STEERING TO HEADING(90, deg, 0).
	WAIT 0.2.
}

SET throttle_level TO gentleThrottleDown(throttle_level, 0.1).

SET previous_ap TO SHIP:ORBIT:APOAPSIS.
UNTIL SHIP:ORBIT:PERIAPSIS >= 78 * 1000 {
	SET deg TO getCurrentPitch().
	SET adjust_angle TO getApAdjustAngle(target_ap, previous_ap).
	SET deg TO deg + adjust_angle.
	set previous_ap TO SHIP:ORBIT:APOAPSIS.
	LOCK STEERING TO HEADING(90, deg, 0).
	WAIT 0.2.
}

SET throttle_level TO gentleThrottleDown(throttle_level, 0.0).
PRINT "Orbit complete.".

adjustRoll().
WAIT 5.

DECLARE FUNCTION adjustRoll {
	LOCK STEERING TO HEADING(90, getCurrentPitch(), 0).
	WAIT 0.5.
	LOCK STEERING TO SHIP:VELOCITY:SURFACE.
}
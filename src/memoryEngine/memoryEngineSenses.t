#charset "us-ascii"
//
// memoryEngineSenses.t
//
//	Extends the base adv3 sense memory model to include senses other
//	than sight.
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

#ifndef MEMORY_ENGINE_NO_SENSES

// Define a method (on Actor) to flag an object as sensed via the given sense.
modify sight senseMethod = &setSeen;
modify sound senseMethod = &setHeard;
modify smell senseMethod = &setSmelled;
modify touch senseMethod = &setTocuhed;

// Create a Sense instance for taste.
taste: Sense
	thruProp = &tasteThru
	sizeProp = &tasteSize
	presenceProp = &tastePresence
	senseMethod = &setTasted
;

// Extend our Memory class to include flags for all the senses.
modify Memory
	heard = nil
	smelled = nil
	tasted = nil
	touched = nil

	clearMemory() {
		inherited();

		heard = nil;
		smelled = nil;
		tasted = nil;
		touched = nil;
	}

	copyFrom(obj, clear?) {
		if(inherited(obj) == nil)
			return(nil);

		if(obj.heard != nil) heard = obj.heard;
		if(obj.smelled != nil) smelled = obj.smelled;
		if(obj.tasted != nil) tasted = obj.tasted;
		if(obj.touched != nil) touched = obj.touched;

		return(true);
	}
;

// Add convenience methods for accessing the new sense properties
// to MemoryEngine.
modify MemoryEngine
	getHeard(obj) { return(_getProp(obj, &heard)); }
	setHeard(obj) { return(_setSenseProp(obj, &heard, true)); }

	getSmelled(obj) { return(_getProp(obj, &smelled)); }
	setSmelled(obj) { return(_setSenseProp(obj, &smelled, true)); }

	getTasted(obj) { return(_getProp(obj, &tasted)); }
	setTasted(obj) { return(_setSenseProp(obj, &tasted, true)); }

	getTouched(obj) { return(_getProp(obj, &touched)); }
	setTouched(obj) { return(_setSenseProp(obj, &touched, true)); }
;

modify Actor
	// Methods for accessing the new sense properties.
	getHeard(obj) { return(_getMemoryProp(&getHeard, obj)); }
	setHeard(obj) { return(_getMemoryProp(&setHeard, obj)); }

	getSmelled(obj) { return(_getMemoryProp(&getSmelled, obj)); }
	setSmelled(obj) { return(_getMemoryProp(&setSmelled, obj)); }

	getTasted(obj) { return(_getMemoryProp(&getTasted, obj)); }
	setTasted(obj) { return(_getMemoryProp(&setTasted, obj)); }

	getTouched(obj) { return(_getMemoryProp(&getTouched, obj)); }
	setTouched(obj) { return(_getMemoryProp(&setTouched, obj)); }

	// Generic sense handler.
	// By default we'll only ever be called by Thing.lookAroundWithinSense()
	// for sound and smell, but we handle all the defined senses just
	// for completeness.
	setSensed(obj, sense) {
		// If we've sensed something, we know about it.
		setKnowsAbout(obj);

		self.(sense.senseMethod)(obj);
	}
;

// Update Thing to auto-flag more senses.
modify Thing
	// Flags analogous to suppressAutoSeen for other "broadcast"
	// senses.  We don't do this for touch or taste because those
	// senses by default are never applied automatically by something in
	// the ambient environment.
	suppressAutoHeard = nil
	suppressAutoSmelled = nil

	// Equivalents for noteSeenBy().
	noteHeardBy(actor, prop) { actor.setHeard(self); }
	noteSmelledBy(actor, prop) { actor.setSmelled(self); }
	noteTastedBy(actor, prop) { actor.setTasted(self); }
	noteTouchedBy(actor, prop) { actor.setTouched(self); }

	setAllHeardBy(infoTab, actor) {
		infoTab.forEachAssoc(function(obj, info) {
			if(!obj.suppressAutoHeard)
				actor.setHeard(obj);
		});
	}

	setAllSmelledBy(infoTab, actor) {
		infoTab.forEachAssoc(function(obj, info) {
			if(!obj.suppressAutoSmelled)
				actor.setSmelled(obj);
		});
	}

	// Replacement for the stock adv3 lookAroundWithinSense().
	// This version is functionally identical to adv3's except
	// that we call actor.setSensed() inside the presenceList loop
	// and adv3's just calls actor.setKnowsAbout().
	lookAroundWithinSense(actor, pov, sense, lister) {
		local infoTab, presenceList;

		infoTab = pov.senseInfoTable(sense);

		presenceList = senseInfoTableSubset(infoTab, {
			obj, info: obj.(sense.presenceProp) && !obj.isIn(actor)
		});
		presenceList.forEach(function(cur) {
			actor.setSensed(cur, sense);
		});
		lister.showList(pov, nil, presenceList, 0, 0, infoTab, nil,
			examinee: self);
	}
;

#endif // MEMORY_ENGINE_SENSES

#charset "us-ascii"
//
// memoryEngineSenses.t
//
#include <adv3.h>
#include <en_us.h>

#include "memoryEngine.h"

modify sight senseMethod = &setSeen;
modify sound senseMethod = &setHeard;
modify smell senseMethod = &setSmelled;
modify touch senseMethod = &setTocuhed;

taste: Sense
	thruProp = &tasteThru
	sizeProp = &tasteSize
	presenceProp = &tastePresence
	senseMethod = &setTasted
;

modify Memory
	heard = nil
	smelled = nil
	tasted = nil
	touched = nil
;

modify MemoryEngine
	getHeard(obj) { return(_getProp(obj, &heard)); }
	setHeard(obj) { return(_setProp(obj, &heard, true)); }

	getSmelled(obj) { return(_getProp(obj, &smelled)); }
	setSmelled(obj) { return(_setProp(obj, &smelled, true)); }

	getTasted(obj) { return(_getProp(obj, &tasted)); }
	setTasted(obj) { return(_setProp(obj, &tasted, true)); }

	getTouched(obj) { return(_getProp(obj, &touched)); }
	setTouched(obj) { return(_setProp(obj, &touched, true)); }
;

modify Actor
	getHeard(obj) { return(memoryEngine.getHeard(obj)); }
	setHeard(obj) { return(memoryEngine.setHeard(obj)); }

	getSmelled(obj) { return(memoryEngine.getSmelled(obj)); }
	setSmelled(obj) { return(memoryEngine.setSmelled(obj)); }

	getTasted(obj) { return(memoryEngine.getTasted(obj)); }
	setTasted(obj) { return(memoryEngine.setTasted(obj)); }

	getTouched(obj) { return(memoryEngine.getTouched(obj)); }
	setTouched(obj) { return(memoryEngine.setTouched(obj)); }

	// Generic sense handler.
	// By default we'll only ever be called by Thing.lookAroundWithinSense()
	// for sound and smell, but we handle all the defined senses just
	// for completeness.
	setSensed(obj, sense) {
		// If we've sensed something, we know about it.
		setKnowsAbout(obj);

		self.(sense.senseMethod)(obj);
/*
		switch(sense) {
			case sight:
				setSeen(obj);
				break;
			case sound:
				setHeard(obj);
				break;
			case smell:
				setSmelled(obj);
				break;
			case touch:
				setTouched(obj);
				break;
			case taste:
				setTasted(obj);
				break;
		}
*/
	}
;

modify Thing
	suppressAutoHeard = nil
	suppressAutoSmelled = nil

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

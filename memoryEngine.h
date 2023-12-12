//
// memoryEngine.h
//

// Uncomment to enable debugging options.
//#define __DEBUG_MEMORY_ENGINE

#undef gRevealed
#define gRevealed(id) (memoryEngine.getRevealed(gActor, id))

#undef gReveal
#define gReveal(id) (memoryEngine.setRevealed(gActor, id))

#define gKnowsAbout(id) (memoryEngine.getKnown(gActor, id))
#define gLearnAbout(id) (memoryEngine.setKnown(gActor, id))

#define gHasSeen(id) (memoryEngine.getSeen(gActor, id))
#define gSee(id) (memoryEngine.setSeen(gActor, id))

#define MEMORY_ENGINE_H

// Case 1: Write Miss, Dirty = 0
loadi 0 0x09      // R0 = 0x09 (data to store)
loadi 1 0x01      // R1 = 0x01 (address)
swd 0 1           // MEM[R1] = R0 → Write miss, dirty=0, fills block



// Case 2: Write Miss, Dirty = 1
loadi 0 0x0A      // R0 = 0x0A
loadi 1 0x05      // R1 = 0x05
swd 0 1           // MEM[5] = 0x0A → Write miss (clean), now dirty

loadi 2 0x0B      // R2 = 0x0B
loadi 3 0x01      // R3 = 0x01
swd 2 3           // MEM[1] = 0x0B → Write miss, triggers write-back of dirty block at 0x05


// Case 3: Write Hit
loadi 0 0x0C      // R0 = 0x0C (new data)
loadi 1 0x05      // R1 = 0x05 (should be in cache from previous)
swd 0 1           // MEM[5] = 0x0C → Write hit (block already in cache)



// Case 4: Read Miss, Dirty = 0
loadi 0 0x10      // R0 = 0x10 (address)
lwi 1 0x10        // Load MEM[0x10] into R1 → read miss, dirty=0



// Case 5: Read Miss, Dirty = 1
loadi 0 0x55      // R0 = 0x55 (some data)
swi 0 0x11        // MEM[0x11] = 0x55 → Write miss, clean → now dirty
lwi 1 0x10        // Read from MEM[0x10] again → read miss, triggers write-back of MEM[0x11]



// Case 6: Read Hit
lwi 2 0x10        // Read from MEM[0x10] → Read hit (already cached in Case 5)

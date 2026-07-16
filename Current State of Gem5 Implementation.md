### **Things which are not implemented:**

**APSTATUS:**

- Version/Revision Number

- AP Count

**APCTRL:**

- pending (flag)

- privilege mask (deprioritized)

### **Things which have been verified:**

APLASTEX: ??

APCTRL:

PRIVILEGE MASK : unimportant

**Misc Notes:**

The privilege mask alone would prevent interference between processes, and it would be necessarily for system-level process management to handle the anticipation mechanism properly in context switching. The idea that system-level process management could result in situations where anticipation points might be occupied by the system/machine level, and _claimed_ by such programs could greatly interfere with the user-level. Perhaps this is reason to believe there should be independent implementations for each privilege level.
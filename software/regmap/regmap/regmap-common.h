#ifndef REGMAP_COMMON_H
#define REGMAP_COMMON_H

#ifdef __KERNEL__
  #include <linux/types.h>
#else
  #include <sys/types.h>
#endif

/* Register Map version number, same format as in Firmware: 0xMAmi (major, minor) */
#define REGMAP_VERSION 0x0200

/* Max number entries of Groups */
#define MAX_ENTRIES_IN_GROUP 1000

#endif /* REGMAP_COMMON_H */

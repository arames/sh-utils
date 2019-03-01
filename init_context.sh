# shellcheck disable=SC2039
local outer_SH_UTILS_DRY_RUN
outer_SH_UTILS_DRY_RUN=$SH_UTILS_DRY_RUN

# shellcheck disable=SC2034
local SH_UTILS_DRY_RUN

# shellcheck disable=SC2034
local SH_UTILS_ERRORS
SH_UTILS_ERRORS=0
SH_UTILS_DRY_RUN=${outer_SH_UTILS_DRY_RUN:-"false"}

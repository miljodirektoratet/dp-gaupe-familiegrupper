# Declare global variables to avoid R CMD check NOTEs
# These are column names used with non-standard evaluation in dplyr functions
utils::globalVariables(c(
  "X_cent",                    # Used in create_centerpoints()
  "Y_cent",                    # Used in create_centerpoints()
  "prey_class1",               # Used in apply_distance_rules()
  "prey_class2",               # Used in apply_distance_rules()
  "temporal_distance_days"     # Used in apply_distance_rules()
))

# Description: This file contains the API calls for the scan hooks.  
# This hook sets the scan policy strength to 'high' and threshold to 'low'.
# This active scan settings matches the what is used by the NCC
# Note: this scan will take longer to complete and should therefore be run at off-peak times.

def zap_active_scan(zap, target, policy):
    policy = 'St-Ins-Th-Low'
    return zap, target, policy 
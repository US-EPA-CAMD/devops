# Description: This file contains the API calls for the scan hooks.  
# This hook sets the scan policy strength to 'high' and threshold to 'low'.
# This active scan settings matches the what is used by the NCC
# Note: this scan will take longer to complete and should therefore be run at off-peak times.
import os


def zap_active_scan(zap, target, policy):
    # Log the incoming parameters
    print('Incoming policy: ' + str(policy))
    # Read the zap scan policy from an environment variable
    policy = os.getenv('ZAP_SCAN_POLICY')
    print('Outgoing policy: ' + str(policy))
    return zap, target, policy
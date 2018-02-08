import os
from checks import AgentCheck

class FailoverCheck(AgentCheck):
    def check(self, instance):
        clustergrp = os.popen('powershell.exe Get-ClusterGroup -Name SQLAG1').read().strip().lower()
        hostname = os.popen('powershell.exe hostname').read().strip().lower()

        if hostname in clustergrp:
            # Found matching hostname - server is primary
            self.gauge('sql.server.primary', 1)
        else:
            # Didn't find matching hostname - server is not primary
            self.gauge('sql.server.primary', 0)

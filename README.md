# WhenIdleRun
Use WhenIdleRun to execute an arbitrary snippet of script code / commands after an idle timeout has elapsed. If you fork a call to this command, any subsequent calls to the same command (with the same job id) will update the idle time stamp, thus resettinging the idle time period.

# Usage
```
whenidlerun.sh -i|--id job_id [-t|--timeout seconds] -c|--command command
  -i, --id       Unique string ID for this job
  -t, --timeout  Idle timeout in seconds (default 10)
  -c, --command  Command to run after idle timeout
```

## Example
```
whenidlerun.sh -i my-job -t 4 -c "cd ~/some/path; git-sync"
```

# License
WhenIdleRun is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

WhenIdleRun is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with WhenIdleRun.  If not, see <http://www.gnu.org/licenses/>.

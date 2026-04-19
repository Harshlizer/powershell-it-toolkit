# Power Automate for Inactive Guest User Cleanup

## Overview

Power Automate can be used to identify and process inactive Microsoft 365 guest users without requiring a full guest governance licensing model.

## What the Flow Does

- Finds guest users inactive for 90 or more days through Microsoft Graph
- Writes the findings to a SharePoint list
- Lets administrators choose `Keep`, `Disable`, or `Delete`
- Waits for a review period before taking action
- Sends a final CSV report

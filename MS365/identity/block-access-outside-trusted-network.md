# Block Access Outside a Trusted Network

## Goal

Allow sign-in only from trusted networks and block access from every other location.

## Recommended Configuration

1. Open `Microsoft Entra admin center -> Protection -> Conditional Access`.
2. Create a new policy such as `Block access outside trusted network`.
3. Assign the target users or groups.
4. Target all resources unless a narrower scope is required.
5. Include any network or location.
6. Exclude all trusted networks and locations.
7. Set access control to `Block access`.
8. Start in `Report-only` and validate in sign-in logs.

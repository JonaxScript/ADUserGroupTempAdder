# Group Membership Manager - PowerShell Script

This PowerShell script provides a graphical user interface (GUI) for managing Active Directory group memberships. It allows administrators to add users to groups temporarily, with an automatic scheduled task to remove them at a specified date and time.

## Features

- **Search and select groups**: Search for Active Directory groups by name.
- **Search and select users**: Search for users by username (SamAccountName) and select them for addition to a group.
- **Temporary group membership**: Add a user to a group temporarily, with an automatic removal at a specified end date and time.
- **Scheduled task creation**: The script creates a scheduled task that will remove the user from the group at the set time.
- **PowerShell script**: The script is written in PowerShell, leveraging the `ActiveDirectory` module for interacting with AD.

## Requirements

- Windows Server or Windows 10/11 with **Active Directory** module installed.
- PowerShell 5.1 or higher.
- Administrative privileges to interact with Active Directory.

## Installation

1. Open the `GroupMembershipManager.ps1` script in your PowerShell environment.
2. Run the script with administrator privileges.

## Usage

1. **Search for a Group**: Enter a search term in the "Search Group" box and click **Search**. The groups that match the search term will be displayed in the "Select Group" dropdown.
   
2. **Search for Users**: Enter a search term in the "Search Users" box and click **Search**. Users matching the search term will be displayed in the "Select Users" dropdown. You can add users to a selected group temporarily.

3. **Set the End Date & Time**: Choose the end date and time when the user should be removed from the group using the DateTime picker.

4. **Add User Temporarily**: After selecting the group and user, click **Add User Temporarily**. This will add the user to the group and schedule a task to remove them at the specified end date and time.

5. **Close the Application**: If you wish to exit, click **Close**.

## Example

After selecting a group, a user, and setting an end date/time, the script will automatically:

- Add the user to the selected group.
- Schedule a task to remove the user at the specified end date/time.

## Error Handling

The script will show error messages for the following scenarios:
- No search term entered.
- Group or user not selected.
- User already a member of the selected group.
- Errors when scheduling the task or modifying group memberships.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- Thanks to the PowerShell community for their invaluable resources.
- Special thanks to the Active Directory module developers for simplifying interaction with AD.

---

Let me know if you'd like further adjustments!

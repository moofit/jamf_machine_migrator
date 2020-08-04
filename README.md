![Logo](https://x1llu7x4a4-flywheel.netdna-ssl.com/wp-content/themes/moof/images/logo.svg)

# Jamf Machine Migrator

## Table of Contents

- [Jamf Machine Migrator](#Jamf Machine Migrator)
  - [Purpose](#purpose)
  - [Includes](#includes)
  - [How to contribute](#how-to-contribute)
  - [Support](#support)
  - [License](#license)
  
## Purpose

If you are replacing a user's Mac or doing a larger hardware refresh, this is a tool to migrate the static inventory information of one Mac JSS record to another.

## How to use

This script can migrate all text field Extension Attributes, drop-down menu Extension Attributes and user and location information from one JSS computer record to another.  The script can be run on a single line to move one record to another:

	`./jamfMachineMigrator -v -s Moof-123 -d Moof-321 -c https://jss.moof.co.uk:8443 -u darren -p 'password'`

It can also be used with a tab delimited file to migrate the data for multiple records at once

	`./jamfMachineMigrator -v -c https://jss.moof.co.uk:8443 -u darren -p 'password' -f /Users/Shared/TabFile`

Running the script with no options will display the below help information:

	Usage: $0 [-v] -s SourceComputer [-h] [-d DestinationComputer] [-c CasperURL] [-u APIUsername] [-p APIPassword | -P] [-n] [-f PathToFile]
	
	-v						Verbose mode. Output all the things
	-s SourceComputer		Supply an identifier to use as the source of the information.
							This can be Computer Name, Serial Number, Asset Number or another unique identifier.
							If this finds more than one match it will exit.
	-d DestinationComputer 	Supply an identifier to use as the destination of the information to import the source computer's details into.
	-c CasperURL			Supply the Casper URL to contact for the work. if not specified, then the default set 
							in the script will be used.
	-u APIUsername			Supply the API username to access the Casper server and carry out the work.
	-p APIPassword 			Supply the API Password to access the Casper server and carry out the work.
							ENCLOSE ALL PASSWORDS IN SINGLE QUOTES ' ' TO ENSURE CHARACTERS ARE PASSED CORRECTLY!
							Also please do not use the following characters for passwords:
							\ 	' 	£ 	" 	` 	% 	~
	-P						The API Password will be requested.
	-n						Do not prompt to carry out the export/import, just do it!
	-f PathToFile			Use a tab delimited file to specify multiple source and destination Macs to work on.
	-h						This help message
	
	
	API PERMISSIONS:	These MUST be allowed for the specified API user:
					-	'JSS Objects'	-]
			-	'Computer Extension Attributes' - Allow 'Read'
			-	'Computers'	- Allow 'Read' & 'Update'

Below is an example of the tab delimited file required for batch migrations (Source Destination on each single line):

	00001	00002
	00001	00003
	00001	00004

Notes:

- Static group assignments aren't currently migrated (this is on the to-do list)
- Script populated EAs aren't migrated as they are dynamically generated during inventory collections
- If more than one result is found for either the source or destination computer, the script will exit	

## How to contribute

1. Fork this project, if required
2. Create a new branch (`git checkout -b myNewBranch`)
3. Make changes, and commit (`git commit -am "myChanges"`)
4. Push to the new branch (`git push origin myNewBranch`)
5. Create new pull request

## Support

Use at your own risk. Moof IT will accept no responsibility for loss or damage caused by these scripts. Contact Moof IT if you need a custom script tailored to your environment.

## License

This work is licensed under http://creativecommons.org/licenses/by/4.0/.

These scripts may be freely modified for personal or commercial purposes but may not be republished for profit without prior consent.